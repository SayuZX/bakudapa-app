import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/camera/kamera.dart';
import '../../../../core/camera/pratinjau_kamera_isi.dart';
import '../../../../core/dialogs/dialog_aplikasi.dart';
import '../../../../core/extensions/konteks.dart';
import '../../../../core/liveness/layanan_deteksi_wajah.dart';
import '../../../../core/liveness/layanan_liveness.dart';
import '../../../../core/liveness/model_tantangan_liveness.dart';
import '../../../../core/liveness/penghalus_gerak.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/network/penjaga_jaringan.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/system/penjaga_maintenance.dart';
import '../../../../core/security/layanan_integritas_perangkat.dart';
import '../../../../core/storage/berkas_sementara.dart';
import '../../../../shared/providers/penyedia_muat_global.dart';
import '../../data/model/data_registrasi.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/bingkai_wajah_liveness.dart';
import '../widgets/filter_pratinjau.dart';
import '../widgets/teks_instruksi_liveness.dart';

enum _Tahap { persiapan, merekam, selesai }

enum _KualitasPersiapan {
  menyiapkan,
  tidakAda,
  banyakWajah,
  cahayaKurang,
  terlaluJauh,
  terlaluDekat,
  geserKeTengah,
  siap,
}

class HalamanLiveness extends ConsumerStatefulWidget {
  const HalamanLiveness({super.key});

  @override
  ConsumerState<HalamanLiveness> createState() => _HalamanLivenessState();
}

class _HalamanLivenessState extends ConsumerState<HalamanLiveness>
    with WidgetsBindingObserver {
  static const Color _latar = Color(0xFF0B0D11);
  static const double _derajatNormalisasi = 30.0;
  static const double _ambangCahaya = 55;
  static const int _detikTimedTantangan = 5;

  CameraController? _kontroler;
  bool _siapKamera = false;
  bool _kameraDitolak = false;
  bool _adalahEmulator = false;
  bool _streamAktif = false;
  int _hitunganFrame = 0;
  HasilDeteksiWajah _wajah = HasilDeteksiWajah.tidakAda;

  final PenghalusEma _yaw = PenghalusEma(alpha: 0.32);
  final PenghalusEma _pitch = PenghalusEma(alpha: 0.32);

  _Tahap _tahap = _Tahap.persiapan;
  int _indeksTantangan = 0;
  int _detikSisa = 0;
  Timer? _pencacah;
  Timer? _jedaTangkap;
  List<TantanganLiveness> _tantangan = const [];
  String? _jalurVideo;

  final GlobalKey _kunciKamera = GlobalKey();
  DateTime? _waktuMulaiRekam;
  DateTime? _waktuMulaiTantangan;
  final List<TangkapTantangan> _tangkapan = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: _latar,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    _tantangan = LayananLiveness.instance.acakTantangan(jumlah: 3);
    _periksaPerangkat();
    _siapkanKamera();
  }

  Future<void> _periksaPerangkat() async {
    final hasil = await LayananIntegritasPerangkat.instance.periksa();
    if (!mounted) return;
    setState(() => _adalahEmulator = hasil.emulator);
  }

  Future<void> _mulaiStreamWajah(CameraController c) async {
    if (_streamAktif) return;
    try {
      await c.startImageStream(_prosesFrameWajah);
      if (mounted) setState(() => _streamAktif = true);
    } catch (_) {}
  }

  Future<void> _hentikanStreamWajah() async {
    if (!_streamAktif) return;
    final c = _kontroler;
    if (c == null) return;
    try {
      await c.stopImageStream();
    } catch (_) {}
    _streamAktif = false;
  }

  Future<void> _prosesFrameWajah(CameraImage gambar) async {
    _hitunganFrame++;
    if (_hitunganFrame % 4 != 0) return;
    final c = _kontroler;
    if (c == null) return;
    final hasil = await LayananDeteksiWajah.instance.prosesFrame(
      gambar,
      c.description,
    );
    if (!mounted) return;
    final yawBaru = hasil.ada
        ? ((hasil.sudutY ?? 0) / _derajatNormalisasi).clamp(-1.0, 1.0)
        : 0.0;
    final pitchBaru = hasil.ada
        ? ((hasil.sudutX ?? 0) / _derajatNormalisasi).clamp(-1.0, 1.0)
        : 0.0;
    _yaw.terapkan(yawBaru);
    _pitch.terapkan(pitchBaru);
    setState(() => _wajah = hasil);
  }

  Future<void> _tangkapTantangan() async {
    final mulaiRekam = _waktuMulaiRekam;
    final mulaiTantangan = _waktuMulaiTantangan;
    if (mulaiRekam == null || mulaiTantangan == null) return;
    if (_indeksTantangan >= _tantangan.length) return;
    final tantangan = _tantangan[_indeksTantangan];
    final sekarang = DateTime.now();
    final dimulaiMs = mulaiTantangan.difference(mulaiRekam).inMilliseconds;
    final selesaiMs = sekarang.difference(mulaiRekam).inMilliseconds;
    final filter = FilterPratinjauX.untukIndeks(_indeksTantangan);
    try {
      final boundary = _kunciKamera.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) return;
      final gambar = await boundary.toImage(pixelRatio: 2);
      final byte = await gambar.toByteData(format: ui.ImageByteFormat.png);
      gambar.dispose();
      if (byte == null) return;
      final dasar = await BerkasSementara.instance.jalurBaru(
        'liveness-snap-${tantangan.kode}',
      );
      final jalur = '$dasar.png';
      await File(jalur).writeAsBytes(byte.buffer.asUint8List());
      _tangkapan.add(
        TangkapTantangan(
          kodeTantangan: tantangan.kode,
          jalurFoto: jalur,
          dimulaiMs: dimulaiMs,
          selesaiMs: selesaiMs,
          namaFilter: filter.nama,
        ),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pencacah?.cancel();
    _jedaTangkap?.cancel();
    _hentikanStreamWajah();
    LayananDeteksiWajah.instance.buang();
    LayananKamera.instance.tutup(_kontroler);
    _kontroler = null;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_kontroler == null) return;
    if (state != AppLifecycleState.resumed) {
      _hentikanRekam(buang: true);
      LayananKamera.instance.tutup(_kontroler);
      _kontroler = null;
      if (mounted) setState(() => _siapKamera = false);
    } else {
      _siapkanKamera();
    }
  }

  Future<void> _siapkanKamera() async {
    try {
      final k = await LayananKamera.instance.buat(
        arah: ArahKamera.depan,
        aktifkanAudio: true,
        resolusi: ResolutionPreset.medium,
        formatGambar: LayananKamera.formatDeteksiWajah,
      );
      if (!mounted) {
        await LayananKamera.instance.tutup(k);
        return;
      }
      setState(() {
        _kontroler = k;
        _siapKamera = k != null;
        _kameraDitolak = k == null;
      });
      if (k != null && !_adalahEmulator) {
        _mulaiStreamWajah(k);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _siapKamera = false;
        _kameraDitolak = true;
      });
      final t = ref.read(teksProvider);
      await DialogAplikasi.tampilkanAlert<void>(
        context: context,
        judul: t.aksesKameraDitolak,
        pesan: t.bukaPengaturanKamera,
        nada: NadaDialog.peringatan,
      );
    }
  }

  Future<void> _mulaiRekam() async {
    final c = _kontroler;
    if (c == null || _tahap == _Tahap.merekam || !_bolehMulai) return;
    try {
      await _hentikanStreamWajah();
      for (final t in _tangkapan) {
        await BerkasSementara.instance.hapus(t.jalurFoto);
      }
      _tangkapan.clear();
      await c.startVideoRecording();
      if (!mounted) return;
      _waktuMulaiRekam = DateTime.now();
      setState(() {
        _tahap = _Tahap.merekam;
        _indeksTantangan = 0;
      });
      _mulaiTantangan();
    } catch (_) {
      if (!mounted) return;
      final cc = _kontroler;
      if (cc != null && !_adalahEmulator) _mulaiStreamWajah(cc);
      context.tampilkanGalat(ref.read(teksProvider).gagalMemulaiPerekaman);
    }
  }

  void _mulaiTantangan() {
    if (_indeksTantangan >= _tantangan.length) {
      _selesaikanRekam();
      return;
    }
    _detikSisa = _detikTimedTantangan;
    _waktuMulaiTantangan = DateTime.now();
    if (mounted) setState(() {});
    _jedaTangkap?.cancel();
    _jedaTangkap = Timer(
      const Duration(milliseconds: _detikTimedTantangan * 500),
      () => unawaited(_tangkapTantangan()),
    );
    _pencacah?.cancel();
    _pencacah = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_detikSisa <= 1) {
        timer.cancel();
        setState(() => _detikSisa = 0);
        _indeksTantangan++;
        _mulaiTantangan();
      } else {
        setState(() => _detikSisa--);
      }
    });
  }

  double _kemajuanTimed() {
    if (_tahap != _Tahap.merekam) return 0;
    return ((_detikTimedTantangan - _detikSisa) / _detikTimedTantangan)
        .clamp(0.0, 1.0);
  }

  Future<void> _selesaikanRekam() async {
    final c = _kontroler;
    if (c == null || !c.value.isRecordingVideo) return;
    _pencacah?.cancel();
    try {
      final xf = await c.stopVideoRecording();
      final jalur = await BerkasSementara.instance.jalurBaru('liveness');
      final tujuan = '$jalur.mp4';
      await File(xf.path).copy(tujuan);
      await BerkasSementara.instance.hapus(xf.path);
      if (!mounted) return;
      setState(() {
        _tahap = _Tahap.selesai;
        _jalurVideo = tujuan;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _tahap = _Tahap.persiapan);
      context.tampilkanGalat(ref.read(teksProvider).gagalMenyimpanVideoLiveness);
    }
  }

  Future<void> _hentikanRekam({bool buang = false}) async {
    _pencacah?.cancel();
    _jedaTangkap?.cancel();
    final c = _kontroler;
    if (c == null) return;
    try {
      if (c.value.isRecordingVideo) {
        final xf = await c.stopVideoRecording();
        if (buang) await BerkasSementara.instance.hapus(xf.path);
      }
    } catch (_) {}
    if (mounted) setState(() => _tahap = _Tahap.persiapan);
  }

  Future<void> _ulangi() async {
    final lama = _jalurVideo;
    setState(() {
      _tahap = _Tahap.persiapan;
      _jalurVideo = null;
      _indeksTantangan = 0;
      _tantangan = LayananLiveness.instance.acakTantangan(jumlah: 3);
    });
    await BerkasSementara.instance.hapus(lama);
    final c = _kontroler;
    if (c != null && !_adalahEmulator) _mulaiStreamWajah(c);
  }

  Future<void> _lanjut() async {
    final jalur = _jalurVideo;
    if (jalur == null) return;
    final t = ref.read(teksProvider);
    final jaringanOk = await PenjagaJaringan.cekUntukAksi(
      context: context,
      ref: ref,
      kekakuan: TingkatKekakuanJaringan.ketat,
    );
    if (!mounted || !jaringanOk) return;
    final maintenanceOk = await PenjagaMaintenance.cekUntukAksi(
      context: context,
      ref: ref,
    );
    if (!mounted || !maintenanceOk) return;
    final ok = await ref.read(penyediaMuatGlobal.notifier).jalankan<bool>(
      () => ref.read(penyediaRegistrasi.notifier).simpanLiveness(
            jalurVideo: jalur,
            tantangan: _tantangan,
            tangkapan: List.unmodifiable(_tangkapan),
          ),
      judul: t.mohonTunggu,
      pesan: t.mengunggahLiveness,
    );
    if (!mounted) return;
    if (ok) {
      ref
          .read(penyediaRegistrasi.notifier)
          .ubahLangkah(LangkahRegistrasi.suara);
      context.push(NamaRute.daftarSuara);
    } else {
      final p =
          ref.read(penyediaRegistrasi).pesanGalat ??
          t.verifikasiWajahBelumBerhasilPesan;
      if (!mounted) return;
      await DialogAplikasi.tampilkanAlert<void>(
        context: context,
        judul: t.verifikasiGagal,
        pesan: p,
        nada: NadaDialog.peringatan,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final memuat = ref.watch(penyediaRegistrasi).memuat;
    return Scaffold(
      backgroundColor: _latar,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _BarAtas(
              saatKembali: () async {
                await _hentikanRekam(buang: true);
                if (!mounted) return;
                if (!context.mounted) return;
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(NamaRute.daftarFotoWajah);
                }
              },
            ),
            const _CapPoweredByGatech(),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_siapKamera || _kontroler == null)
                    const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: Colors.white70,
                          strokeWidth: 2.4,
                        ),
                      ),
                    )
                  else
                    BingkaiWajahLiveness(
                      kondisi: _kondisiBingkai(),
                      offsetWajah: _wajah.pusatRelatif,
                      wajahTerdeteksi: _wajah.ada,
                      yawNorm: _yaw.nilai,
                      pitchNorm: _pitch.nilai,
                      arahAktif: _arahAktif(),
                      kemajuanTantangan: _kemajuanTimed(),
                      anak: RepaintBoundary(
                        key: _kunciKamera,
                        child: FilterKameraOverlay(
                          aktif: _tahap == _Tahap.merekam,
                          indeks: _indeksTantangan,
                          child: PratinjauKameraIsi(kontroler: _kontroler!),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: TeksInstruksiLiveness(
                kunciAnimasi: _kunciInstruksi(),
                utama: _judulInstruksi(),
                pendukung: _subInstruksi(),
              ),
            ),
            const SizedBox(height: 28),
            _BarBawah(
              tahap: _tahap,
              siap: _siapKamera && !_kameraDitolak,
              mulaiAktif: _bolehMulai,
              memuat: memuat,
              saatMulai: _mulaiRekam,
              saatUlangi: _ulangi,
              saatLanjut: _lanjut,
              saatBukaPengaturan: () {
                final t = ref.read(teksProvider);
                DialogAplikasi.tampilkanAlert<void>(
                  context: context,
                  judul: t.bukaPengaturan,
                  pesan: t.bukaPengaturanKamera,
                  nada: NadaDialog.info,
                );
              },
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
          ],
        ),
      ),
    );
  }

  ArahTantangan _arahAktif() {
    if (_tahap != _Tahap.merekam) return ArahTantangan.tidakAda;
    if (_indeksTantangan >= _tantangan.length) return ArahTantangan.tidakAda;
    return _tantangan[_indeksTantangan].arahUtama;
  }

  _KualitasPersiapan _kualitasPersiapan() {
    if (_adalahEmulator) return _KualitasPersiapan.siap;
    if (!_siapKamera || _kontroler == null) return _KualitasPersiapan.menyiapkan;
    final w = _wajah;
    final lum = w.luminansi;
    final gelap = lum != null && lum < _ambangCahaya;
    if (w.jumlahWajah > 1) return _KualitasPersiapan.banyakWajah;
    if (!w.ada) {
      return gelap ? _KualitasPersiapan.cahayaKurang : _KualitasPersiapan.tidakAda;
    }
    final box = w.boundingBox;
    final uk = w.ukuranGambar;
    if (box != null && uk != null && uk.width > 0 && uk.height > 0) {
      final sisi = uk.width > uk.height ? uk.width : uk.height;
      final f = box.height / sisi;
      if (f < 0.12) return _KualitasPersiapan.terlaluJauh;
      if (f > 0.75) return _KualitasPersiapan.terlaluDekat;
    }
    if (gelap) return _KualitasPersiapan.cahayaKurang;
    if (w.pusatRelatif.distance > 0.6) return _KualitasPersiapan.geserKeTengah;
    return _KualitasPersiapan.siap;
  }

  bool get _bolehMulai =>
      _adalahEmulator || _kualitasPersiapan() == _KualitasPersiapan.siap;

  String _judulPersiapan(Teks t) {
    switch (_kualitasPersiapan()) {
      case _KualitasPersiapan.menyiapkan:
        return t.menyiapkanKamera;
      case _KualitasPersiapan.tidakAda:
        return t.posisikanWajahDiLingkaran;
      case _KualitasPersiapan.banyakWajah:
        return t.arahanSatuWajah;
      case _KualitasPersiapan.cahayaKurang:
        return t.cahayaKurangArahan;
      case _KualitasPersiapan.terlaluJauh:
        return t.arahanTerlaluJauh;
      case _KualitasPersiapan.terlaluDekat:
        return t.arahanTerlaluDekat;
      case _KualitasPersiapan.geserKeTengah:
        return t.arahanPosisikanWajah;
      case _KualitasPersiapan.siap:
        return t.siapVerifikasiWajah;
    }
  }

  String? _subPersiapan(Teks t) {
    final q = _kualitasPersiapan();
    if (q == _KualitasPersiapan.tidakAda || q == _KualitasPersiapan.siap) {
      return t.pastikanWajahJelas;
    }
    return null;
  }

  String _judulInstruksi() {
    final t = ref.read(teksProvider);
    if (_kameraDitolak) return t.aksesKameraDiperlukan;
    if (!_siapKamera) return t.persiapanKamera;
    switch (_tahap) {
      case _Tahap.persiapan:
        return _judulPersiapan(t);
      case _Tahap.merekam:
        if (_indeksTantangan < _tantangan.length) {
          return _tantangan[_indeksTantangan].instruksi;
        }
        return t.menyelesaikan;
      case _Tahap.selesai:
        return t.verifikasiWajahSelesai;
    }
  }

  String? _subInstruksi() {
    final t = ref.read(teksProvider);
    if (_kameraDitolak) {
      return t.bukaPengaturanKamera;
    }
    switch (_tahap) {
      case _Tahap.persiapan:
        return _subPersiapan(t);
      case _Tahap.merekam:
        if (_indeksTantangan < _tantangan.length) {
          return t.instruksiUmumLiveness;
        }
        return null;
      case _Tahap.selesai:
        return t.lanjutkanKeVerifikasiSuara;
    }
  }

  String _kunciInstruksi() {
    if (_kameraDitolak) return 'ditolak';
    if (!_siapKamera) return 'memuat';
    if (_tahap == _Tahap.persiapan) {
      return 'persiapan-${_kualitasPersiapan().name}';
    }
    if (_tahap == _Tahap.selesai) return 'selesai';
    if (_indeksTantangan < _tantangan.length) {
      return 'tantangan-${_tantangan[_indeksTantangan].kode}';
    }
    return 'memproses';
  }

  KondisiBingkaiWajah _kondisiBingkai() {
    if (_tahap == _Tahap.selesai) return KondisiBingkaiWajah.sukses;
    if (_tahap == _Tahap.merekam) {
      return KondisiBingkaiWajah.deteksi;
    }
    switch (_kualitasPersiapan()) {
      case _KualitasPersiapan.siap:
        return KondisiBingkaiWajah.sukses;
      case _KualitasPersiapan.menyiapkan:
      case _KualitasPersiapan.tidakAda:
        return KondisiBingkaiWajah.netral;
      case _KualitasPersiapan.banyakWajah:
      case _KualitasPersiapan.cahayaKurang:
      case _KualitasPersiapan.terlaluJauh:
      case _KualitasPersiapan.terlaluDekat:
      case _KualitasPersiapan.geserKeTengah:
        return KondisiBingkaiWajah.peringatan;
    }
  }

}

class _BarAtas extends ConsumerWidget {
  const _BarAtas({required this.saatKembali});

  final VoidCallback saatKembali;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: saatKembali,
            icon: const Icon(
              HugeIcons.strokeRoundedArrowLeft01,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              t.verifikasiWajah,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapPoweredByGatech extends StatelessWidget {
  const _CapPoweredByGatech();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Center(
        child: Text(
          'Powered By GATECH',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.18),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}

class _BarBawah extends ConsumerWidget {
  const _BarBawah({
    required this.tahap,
    required this.siap,
    required this.mulaiAktif,
    required this.memuat,
    required this.saatMulai,
    required this.saatUlangi,
    required this.saatLanjut,
    required this.saatBukaPengaturan,
  });

  final _Tahap tahap;
  final bool siap;
  final bool mulaiAktif;
  final bool memuat;
  final VoidCallback saatMulai;
  final VoidCallback saatUlangi;
  final VoidCallback saatLanjut;
  final VoidCallback saatBukaPengaturan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    Widget isi;
    if (!siap) {
      isi = SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: saatBukaPengaturan,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(t.bukaPengaturan),
        ),
      );
    } else if (tahap == _Tahap.persiapan) {
      isi = SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: mulaiAktif ? saatMulai : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
            foregroundColor: const Color(0xFF0B0D11),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(mulaiAktif ? t.mulaiVerifikasi : t.posisikanWajah),
        ),
      );
    } else if (tahap == _Tahap.merekam) {
      isi = Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B6B),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              t.sedangMerekam,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      isi = Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: memuat ? null : saatUlangi,
                icon: const Icon(HugeIcons.strokeRoundedReload, size: 18),
                label: Text(t.ulangi),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: memuat ? null : saatLanjut,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0B0D11),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: memuat
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Color(0xFF0B0D11),
                        ),
                      )
                    : Text(t.lanjutkan),
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: isi,
    );
  }
}

