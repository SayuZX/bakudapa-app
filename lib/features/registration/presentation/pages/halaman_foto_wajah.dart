import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import 'dart:async';

import '../../../../core/camera/kamera.dart';
import '../../../../core/camera/penilai_foto.dart';
import '../../../../core/camera/pratinjau_kamera_isi.dart';
import '../../../../core/extensions/konteks.dart';
import '../../../../core/liveness/layanan_deteksi_wajah.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/network/penjaga_jaringan.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/system/penjaga_maintenance.dart';
import '../../../../core/security/layanan_integritas_perangkat.dart';
import '../../../../core/sensors/sensor_gerak_perangkat.dart';
import '../../../../core/storage/berkas_sementara.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../shared/providers/penyedia_muat_global.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/bingkai_wajah_liveness.dart';
import '../widgets/lencana_status_liveness.dart';
import '../widgets/stepper_registrasi.dart';

class HalamanFotoWajah extends ConsumerStatefulWidget {
  const HalamanFotoWajah({super.key});

  @override
  ConsumerState<HalamanFotoWajah> createState() => _HalamanFotoWajahState();
}

enum _StatusWajah {
  menyiapkan,
  izinDitolak,
  tidakAda,
  cahayaKurang,
  terlaluJauh,
  terlaluDekat,
  geserKeTengah,
  kameraGoyang,
  siap,
}

class _HalamanFotoWajahState extends ConsumerState<HalamanFotoWajah>
    with WidgetsBindingObserver {
  CameraController? _kontroler;
  bool _siap = false;
  bool _menangkap = false;
  bool _memeriksa = false;
  String? _pratinjau;
  HasilPenilaianFoto? _hasilPenilaian;

  bool _adalahEmulator = false;
  bool _izinDitolak = false;
  bool _streamAktif = false;
  int _hitunganFrame = 0;
  HasilDeteksiWajah _wajah = HasilDeteksiWajah.tidakAda;
  bool _kameraGoyang = false;
  StreamSubscription<HasilGerakPerangkat>? _langganGerak;

  static const double _ambangCahayaRendah = 55;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _periksaPerangkat();
    _siapkanKamera();
    SensorGerakPerangkat.instance.mulai();
    _langganGerak = SensorGerakPerangkat.instance.aliran.listen((h) {
      if (!mounted) return;
      if (h.goyang != _kameraGoyang) {
        setState(() => _kameraGoyang = h.goyang);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _langganGerak?.cancel();
    SensorGerakPerangkat.instance.hentikan();
    _hentikanStream();
    LayananKamera.instance.tutup(_kontroler);
    _kontroler = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_kontroler == null) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _hentikanStream();
      LayananKamera.instance.tutup(_kontroler);
      _kontroler = null;
      if (mounted) setState(() => _siap = false);
    } else if (state == AppLifecycleState.resumed) {
      _siapkanKamera();
    }
  }

  Future<void> _periksaPerangkat() async {
    final hasil = await LayananIntegritasPerangkat.instance.periksa();
    if (!mounted) return;
    setState(() => _adalahEmulator = hasil.emulator);
  }

  Future<void> _siapkanKamera() async {
    try {
      final k = await LayananKamera.instance.buat(
        arah: ArahKamera.depan,
        resolusi: ResolutionPreset.medium,
        formatGambar: LayananKamera.formatDeteksiWajah,
      );
      if (!mounted) {
        await LayananKamera.instance.tutup(k);
        return;
      }
      setState(() {
        _kontroler = k;
        _siap = k != null;
        _izinDitolak = false;
      });
      if (k != null && !_adalahEmulator && _pratinjau == null) {
        _mulaiStream(k);
      }
    } on CameraException catch (e) {
      if (!mounted) return;
      final ditolak = e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted';
      setState(() {
        _siap = false;
        _izinDitolak = ditolak;
      });
      if (!ditolak) {
        context.tampilkanGalat(ref.read(teksProvider).tidakDapatBukaKameraDepan);
      }
    } catch (_) {
      if (!mounted) return;
      context.tampilkanGalat(ref.read(teksProvider).tidakDapatBukaKameraDepan);
    }
  }

  Future<void> _mulaiStream(CameraController c) async {
    if (_streamAktif) return;
    try {
      await c.startImageStream(_prosesFrame);
      if (mounted) setState(() => _streamAktif = true);
    } catch (_) {}
  }

  Future<void> _hentikanStream() async {
    if (!_streamAktif) return;
    final c = _kontroler;
    if (c == null) return;
    try {
      await c.stopImageStream();
    } catch (_) {}
    _streamAktif = false;
  }

  Future<void> _prosesFrame(CameraImage gambar) async {
    _hitunganFrame++;
    if (_hitunganFrame % 4 != 0) return;
    final c = _kontroler;
    if (c == null) return;
    final hasil = await LayananDeteksiWajah.instance.prosesFrame(
      gambar,
      c.description,
    );
    if (!mounted) return;
    setState(() => _wajah = hasil);
  }

  _StatusWajah _statusWajah() {
    if (_adalahEmulator || _pratinjau != null) return _StatusWajah.siap;
    if (_izinDitolak) return _StatusWajah.izinDitolak;
    if (!_siap || _kontroler == null) return _StatusWajah.menyiapkan;

    final lum = _wajah.luminansi;
    final gelap = lum != null && lum < _ambangCahayaRendah;

    if (!_wajah.ada) {
      return gelap ? _StatusWajah.cahayaKurang : _StatusWajah.tidakAda;
    }

    final box = _wajah.boundingBox;
    final ukuran = _wajah.ukuranGambar;
    if (box != null && ukuran != null && ukuran.width > 0 && ukuran.height > 0) {
      final sisiPanjang = ukuran.width > ukuran.height ? ukuran.width : ukuran.height;
      final tinggiFraksi = box.height / sisiPanjang;
      if (tinggiFraksi < 0.12) return _StatusWajah.terlaluJauh;
      if (tinggiFraksi > 0.75) return _StatusWajah.terlaluDekat;
    }

    if (gelap) return _StatusWajah.cahayaKurang;
    final magnitudo = _wajah.pusatRelatif.distance;
    if (magnitudo > 0.6) return _StatusWajah.geserKeTengah;
    if (_kameraGoyang) return _StatusWajah.kameraGoyang;
    return _StatusWajah.siap;
  }

  String _pesanArahan(_StatusWajah s, Teks t) {
    switch (s) {
      case _StatusWajah.menyiapkan:
        return t.menyiapkanKamera;
      case _StatusWajah.izinDitolak:
        return t.izinKameraArahan;
      case _StatusWajah.tidakAda:
        return t.arahanPosisikanWajah;
      case _StatusWajah.cahayaKurang:
        return t.cahayaKurangArahan;
      case _StatusWajah.terlaluJauh:
        return t.arahanTerlaluJauh;
      case _StatusWajah.terlaluDekat:
        return t.arahanTerlaluDekat;
      case _StatusWajah.geserKeTengah:
        return t.arahanPosisikanWajah;
      case _StatusWajah.kameraGoyang:
        return t.tahanStabil;
      case _StatusWajah.siap:
        return t.wajahSiap;
    }
  }

  KondisiBingkaiWajah _kondisiBingkai(_StatusWajah s) {
    switch (s) {
      case _StatusWajah.siap:
        return KondisiBingkaiWajah.sukses;
      case _StatusWajah.menyiapkan:
      case _StatusWajah.izinDitolak:
      case _StatusWajah.tidakAda:
        return KondisiBingkaiWajah.netral;
      case _StatusWajah.cahayaKurang:
      case _StatusWajah.terlaluJauh:
      case _StatusWajah.terlaluDekat:
      case _StatusWajah.geserKeTengah:
      case _StatusWajah.kameraGoyang:
        return KondisiBingkaiWajah.peringatan;
    }
  }

  NadaStatusLiveness _nadaStatus(_StatusWajah s) {
    switch (s) {
      case _StatusWajah.siap:
        return NadaStatusLiveness.sukses;
      case _StatusWajah.menyiapkan:
      case _StatusWajah.izinDitolak:
      case _StatusWajah.tidakAda:
        return NadaStatusLiveness.netral;
      case _StatusWajah.cahayaKurang:
      case _StatusWajah.terlaluJauh:
      case _StatusWajah.terlaluDekat:
      case _StatusWajah.geserKeTengah:
      case _StatusWajah.kameraGoyang:
        return NadaStatusLiveness.peringatan;
    }
  }

  IconData _ikonStatus(_StatusWajah s) {
    switch (s) {
      case _StatusWajah.siap:
        return HugeIcons.strokeRoundedCheckmarkCircle02;
      case _StatusWajah.menyiapkan:
        return HugeIcons.strokeRoundedReload;
      case _StatusWajah.tidakAda:
        return HugeIcons.strokeRoundedSearch01;
      case _StatusWajah.izinDitolak:
      case _StatusWajah.cahayaKurang:
      case _StatusWajah.terlaluJauh:
      case _StatusWajah.terlaluDekat:
      case _StatusWajah.geserKeTengah:
      case _StatusWajah.kameraGoyang:
        return HugeIcons.strokeRoundedAlert02;
    }
  }

  String _labelStatus(_StatusWajah s, Teks t) {
    switch (s) {
      case _StatusWajah.menyiapkan:
        return t.menyiapkanKamera;
      case _StatusWajah.izinDitolak:
        return t.izinKamera;
      case _StatusWajah.tidakAda:
        return t.cariWajah;
      case _StatusWajah.cahayaKurang:
        return t.cahayaKurang;
      case _StatusWajah.terlaluJauh:
        return t.terlaluJauh;
      case _StatusWajah.terlaluDekat:
        return t.terlaluDekat;
      case _StatusWajah.geserKeTengah:
        return t.geserKeTengah;
      case _StatusWajah.kameraGoyang:
        return t.tahanStabil;
      case _StatusWajah.siap:
        return t.wajahSiap;
    }
  }

  Future<void> _ambil() async {
    final c = _kontroler;
    if (c == null || !c.value.isInitialized || _menangkap) return;

    await _hentikanStream();
    setState(() => _menangkap = true);
    String? tujuan;
    try {
      final xf = await c.takePicture();
      final jalur = await BerkasSementara.instance.jalurBaru('wajah');
      tujuan = '$jalur.jpg';
      await File(xf.path).copy(tujuan);
      await BerkasSementara.instance.hapus(xf.path);
      if (!mounted) return;
      setState(() => _memeriksa = true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _menangkap = false;
        _memeriksa = false;
      });
      context.tampilkanGalat(ref.read(teksProvider).gagalMengambilFoto);
      return;
    }

    final hasil = await PenilaiFoto.instance.nilai(tujuan);
    if (!mounted) return;
    setState(() {
      _menangkap = false;
      _memeriksa = false;
    });

    if (hasil.layak) {
      setState(() {
        _pratinjau = tujuan;
        _hasilPenilaian = hasil;
      });
    } else {
      await BerkasSementara.instance.hapus(tujuan);
      ref.read(penyediaRegistrasi.notifier).catatGagalFotoWajah();
      if (!mounted) return;
      final percobaan = ref.read(penyediaRegistrasi).percobaanFotoWajah;
      final perluPanduan =
          percobaan >= KondisiRegistrasi.ambangPercobaanGagal ||
              percobaan >= KondisiRegistrasi.maksPercobaanFotoWajah;
      if (perluPanduan) {
        context.go(NamaRute.daftarGagalFotoWajah, extra: hasil.pesan);
      } else {
        context.tampilkanGalat(hasil.pesan);
      }
    }
  }

  Future<void> _ulangi() async {
    final lama = _pratinjau;
    setState(() {
      _pratinjau = null;
      _hasilPenilaian = null;
    });
    await BerkasSementara.instance.hapus(lama);
    final c = _kontroler;
    if (c != null && !_adalahEmulator) {
      _mulaiStream(c);
    }
  }

  Future<void> _lanjut() async {
    final jalur = _pratinjau;
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
      () => ref.read(penyediaRegistrasi.notifier).simpanFotoWajah(jalur),
      judul: t.mohonTunggu,
      pesan: t.mengunggahFotoWajah,
    );
    if (!mounted) return;
    if (ok) {
      ref.read(penyediaRegistrasi.notifier).resetPercobaanFotoWajah();
      ref.read(penyediaRegistrasi.notifier).ubahLangkah(LangkahRegistrasi.liveness);
      context.push(NamaRute.daftarLiveness);
    } else {
      final p = ref.read(penyediaRegistrasi).pesanGalat ?? t.gagalMengunggahFoto;
      context.tampilkanGalat(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kondisi = ref.watch(penyediaRegistrasi);
    final t = ref.watch(teksProvider);
    final percobaan = kondisi.percobaanFotoWajah;
    final sisa = (KondisiRegistrasi.maksPercobaanFotoWajah - percobaan)
        .clamp(0, KondisiRegistrasi.maksPercobaanFotoWajah);

    return Scaffold(
      backgroundColor: Warna.permukaan,
      appBar: AppBar(
        title: Text(t.fotoWajah),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: Column(
        children: [
          StepperRegistrasi(
            langkahAktif: LangkahRegistrasi.fotoWajah,
            judulLangkah: t.fotoWajah,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _pratinjau == null
                            ? t.ambilFotoWajah
                            : t.periksaFotoWajah,
                        style: context.teks.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (_pratinjau == null && !_adalahEmulator) ...[
                      LencanaStatusLiveness(
                        teks: _labelStatus(_statusWajah(), t),
                        nada: _nadaStatus(_statusWajah()),
                        ikon: _ikonStatus(_statusWajah()),
                      ),
                    ] else if (_pratinjau == null && percobaan > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Warna.netral100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${t.sisaPercobaan} $sisa/${KondisiRegistrasi.maksPercobaanFotoWajah}',
                          style: context.teks.labelSmall?.copyWith(
                            color: Warna.teksKedua,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    _pratinjau != null
                        ? '${t.periksaFotoWajah}. ${t.gunakanFotoIni}.'
                        : _adalahEmulator
                            ? '${t.posisikanWajahDiLingkaran}. ${t.pastikanWajahJelas}'
                            : _pesanArahan(_statusWajah(), t),
                    key: ValueKey(
                      _pratinjau != null
                          ? 'pratinjau'
                          : 'arahan-${_statusWajah().name}',
                    ),
                    style: context.teks.bodySmall?.copyWith(
                      color: Warna.teksKedua,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Jarak.lg),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Warna.netral900,
                  child: _pratinjau != null
                      ? Image.file(File(_pratinjau!), fit: BoxFit.cover)
                      : _izinDitolak
                          ? _PesanKamera(
                              pesan: t.izinKameraArahan,
                              labelAksi: t.ulangi,
                              saatAksi: _siapkanKamera,
                            )
                          : !_siap || _kontroler == null
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Warna.merahUtama, strokeWidth: 2.4),
                            )
                          : BingkaiWajahLiveness(
                              kondisi: _kondisiBingkai(_statusWajah()),
                              offsetWajah: _wajah.pusatRelatif,
                              wajahTerdeteksi: _wajah.ada,
                              yawNorm: ((_wajah.sudutY ?? 0) / 30).clamp(-1.0, 1.0),
                              pitchNorm: ((_wajah.sudutX ?? 0) / 30).clamp(-1.0, 1.0),
                              anak: PratinjauKameraIsi(
                                kontroler: _kontroler!,
                                mode: ModePratinjauKamera.fokusWajah,
                              ),
                            ),
                ),
              ),
            ),
          ),
          if (_hasilPenilaian != null && _pratinjau != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(HugeIcons.strokeRoundedCheckmarkCircle02,
                      color: Warna.sukses, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    t.kualitasFotoBaik,
                    style: context.teks.labelSmall?.copyWith(
                      color: Warna.sukses,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: _pratinjau == null
                  ? _BarisAmbil(
                      menangkap: _menangkap || _memeriksa,
                      siap: _adalahEmulator ||
                          _statusWajah() == _StatusWajah.siap,
                      label: (_menangkap || _memeriksa)
                          ? t.memproses
                          : (_adalahEmulator ||
                                  _statusWajah() == _StatusWajah.siap)
                              ? t.ambilFoto
                              : t.posisikanWajah,
                      saatAmbil: _ambil,
                    )
                  : _BarisLanjut(
                      memuat: kondisi.memuat,
                      saatUlangi: _ulangi,
                      saatLanjut: _lanjut,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarisAmbil extends StatelessWidget {
  const _BarisAmbil({
    required this.menangkap,
    required this.siap,
    required this.saatAmbil,
    required this.label,
  });
  final bool menangkap;
  final bool siap;
  final String label;
  final VoidCallback saatAmbil;

  @override
  Widget build(BuildContext context) {
    final aktif = !menangkap && siap;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: aktif ? saatAmbil : null,
        style: FilledButton.styleFrom(
          backgroundColor: Warna.merahUtama,
          disabledBackgroundColor: Warna.netral200,
          foregroundColor: Colors.white,
          disabledForegroundColor: Warna.teksKetiga,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (menangkap)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Colors.white),
              )
            else
              Icon(
                siap
                    ? HugeIcons.strokeRoundedCheckmarkCircle02
                    : HugeIcons.strokeRoundedUserCircle,
                size: 20,
              ),
            const SizedBox(width: 8),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

class _PesanKamera extends StatelessWidget {
  const _PesanKamera({
    required this.pesan,
    required this.labelAksi,
    required this.saatAksi,
  });
  final String pesan;
  final String labelAksi;
  final VoidCallback saatAksi;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(HugeIcons.strokeRoundedAlert02,
                color: Colors.white, size: 36),
            const SizedBox(height: 14),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: saatAksi,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                shape: const StadiumBorder(),
              ),
              child: Text(labelAksi),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarisLanjut extends ConsumerWidget {
  const _BarisLanjut({
    required this.memuat,
    required this.saatUlangi,
    required this.saatLanjut,
  });
  final bool memuat;
  final VoidCallback saatUlangi;
  final VoidCallback saatLanjut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: memuat ? null : saatUlangi,
              icon: const Icon(HugeIcons.strokeRoundedReload, size: 18),
              label: Text(t.ulangi),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Warna.garisTegas, width: 1.2),
                foregroundColor: Warna.teksUtama,
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
                backgroundColor: Warna.merahUtama,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: memuat
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : Text(t.lanjutKeLiveness),
            ),
          ),
        ),
      ],
    );
  }
}
