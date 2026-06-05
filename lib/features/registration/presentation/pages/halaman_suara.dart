import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/network/penjaga_jaringan.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/system/penjaga_maintenance.dart';
import '../../../../core/storage/berkas_sementara.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../core/voice/perekam_suara.dart';
import '../../../../shared/providers/penyedia_muat_global.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/panel_rekam_suara.dart';
import '../widgets/stepper_registrasi.dart';
import '../widgets/teks_tantangan_suara.dart';

class HalamanSuara extends ConsumerStatefulWidget {
  const HalamanSuara({super.key});

  @override
  ConsumerState<HalamanSuara> createState() => _HalamanSuaraState();
}

enum _StatusKalimat { memuat, tersedia, kosong, jaringan, galat }

class _HalamanSuaraState extends ConsumerState<HalamanSuara>
    with WidgetsBindingObserver {
  static const double _ambangBicara = 0.18;
  static const int _tikPerKata = 2;
  static const Duration _intervalTik = Duration(milliseconds: 200);
  static const double _ambangCakupanKata = 0.8;
  static const int _minDetikRekam = 2;

  bool _sedangMerekam = false;
  int _detik = 0;
  int _tikSubDetik = 0;
  double _amplitudo = 0;
  Timer? _pencacah;
  String? _jalurAudio;
  _StatusKalimat _statusKalimat = _StatusKalimat.memuat;
  int _kataTerdeteksiSaatRekam = 0;

  int _indeksKata = 0;
  int _tikSejakKataTerakhir = 0;

  int get _jumlahKata {
    final kalimat = ref.read(penyediaRegistrasi).sesi.kalimatSuara ?? '';
    if (kalimat.isEmpty) return 0;
    return kalimat.split(RegExp(r'\s+')).where((k) => k.isNotEmpty).length;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_muatKalimat);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pencacah?.cancel();
    PerekamSuara.instance.batal();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _sedangMerekam) {
      _batalkanRekam();
    }
  }

  Future<void> _muatKalimat() async {
    final ada = ref.read(penyediaRegistrasi).sesi.kalimatSuara;
    if (ada != null && ada.isNotEmpty) {
      if (mounted) setState(() => _statusKalimat = _StatusKalimat.tersedia);
      return;
    }
    if (mounted) setState(() => _statusKalimat = _StatusKalimat.memuat);
    final hasil =
        await ref.read(penyediaRegistrasi.notifier).ambilTantanganSuara();
    if (!mounted) return;
    setState(() {
      switch (hasil) {
        case HasilAmbilTantanganSuara.sukses:
          _statusKalimat = _StatusKalimat.tersedia;
        case HasilAmbilTantanganSuara.kosong:
          _statusKalimat = _StatusKalimat.kosong;
        case HasilAmbilTantanganSuara.jaringan:
          _statusKalimat = _StatusKalimat.jaringan;
        case HasilAmbilTantanganSuara.galat:
          _statusKalimat = _StatusKalimat.galat;
      }
    });
  }

  Future<void> _toggleRekam() async {
    if (_sedangMerekam) {
      await _selesaiRekam();
    } else {
      await _mulaiRekam();
    }
  }

  Future<void> _mulaiRekam() async {
    final t = ref.read(teksProvider);
    if (_statusKalimat != _StatusKalimat.tersedia) {
      context.tampilkanGalat(t.tantanganSuaraBelumDimuat);
      return;
    }
    try {
      final izin = await PerekamSuara.instance.izinDiberikan();
      if (!izin) {
        if (!mounted) return;
        context.tampilkanGalat(t.izinMikrofonBelumDiberikan);
        return;
      }
      await PerekamSuara.instance.mulai(
        onAmplitudo: (level) {
          if (mounted) setState(() => _amplitudo = level);
        },
      );
      _detik = 0;
      _tikSubDetik = 0;
      _indeksKata = 0;
      _tikSejakKataTerakhir = 0;
      _pencacah?.cancel();
      _pencacah = Timer.periodic(_intervalTik, (_) {
        if (!mounted) return;
        setState(() {
          _tikSubDetik++;
          if (_tikSubDetik >= 5) {
            _tikSubDetik = 0;
            _detik++;
          }
          if (_amplitudo > _ambangBicara && _indeksKata < _jumlahKata) {
            _tikSejakKataTerakhir++;
            if (_tikSejakKataTerakhir >= _tikPerKata) {
              _tikSejakKataTerakhir = 0;
              _indeksKata++;
            }
          }
        });
      });
      if (!mounted) return;
      setState(() => _sedangMerekam = true);
    } catch (_) {
      if (!mounted) return;
      context.tampilkanGalat(t.gagalMemulaiPerekamanSuara);
    }
  }

  Future<void> _selesaiRekam() async {
    _pencacah?.cancel();
    final kataTerdeteksi = _indeksKata;
    final jalur = await PerekamSuara.instance.selesai();
    if (!mounted) return;
    setState(() {
      _sedangMerekam = false;
      _amplitudo = 0;
      _jalurAudio = jalur;
      _kataTerdeteksiSaatRekam = kataTerdeteksi;
    });
  }

  Future<void> _batalkanRekam() async {
    _pencacah?.cancel();
    await PerekamSuara.instance.batal();
    if (!mounted) return;
    setState(() {
      _sedangMerekam = false;
      _amplitudo = 0;
      _detik = 0;
      _indeksKata = 0;
      _tikSejakKataTerakhir = 0;
      _tikSubDetik = 0;
    });
  }

  Future<void> _ulangi() async {
    final lama = _jalurAudio;
    setState(() {
      _jalurAudio = null;
      _detik = 0;
      _indeksKata = 0;
      _tikSejakKataTerakhir = 0;
      _tikSubDetik = 0;
      _kataTerdeteksiSaatRekam = 0;
    });
    await BerkasSementara.instance.hapus(lama);
  }

  bool get _rekamanCocokKalimat {
    final total = _jumlahKata;
    if (total == 0) return false;
    if (_detik < _minDetikRekam) return false;
    final rasio = _kataTerdeteksiSaatRekam / total;
    return rasio >= _ambangCakupanKata;
  }

  Future<void> _lanjut() async {
    final jalur = _jalurAudio;
    if (jalur == null) return;
    final t = ref.read(teksProvider);
    if (_statusKalimat != _StatusKalimat.tersedia) {
      context.tampilkanGalat(t.tantanganSuaraBelumDimuat);
      return;
    }
    if (!_rekamanCocokKalimat) {
      context.tampilkanGalat(t.rekamanBelumCocokKalimat);
      return;
    }
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
      () => ref.read(penyediaRegistrasi.notifier).simpanSuara(jalur),
      judul: t.mohonTunggu,
      pesan: t.mengunggahSuara,
    );
    if (!mounted) return;
    if (ok) {
      ref
          .read(penyediaRegistrasi.notifier)
          .ubahLangkah(LangkahRegistrasi.sidikJari);
      context.push(NamaRute.daftarPersetujuanSidikJari);
    } else {
      final p = ref.read(penyediaRegistrasi).pesanGalat ??
          t.rekamanBelumTerdengarJelas;
      context.tampilkanGalat(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kondisi = ref.watch(penyediaRegistrasi);
    final t = ref.watch(teksProvider);
    final kalimat = kondisi.sesi.kalimatSuara ?? '';
    final kode = kondisi.sesi.kodeSuara;

    return Scaffold(
      backgroundColor: Warna.permukaan,
      appBar: AppBar(
        title: Text(t.verifikasiSuara),
        leading: IconButton(
          onPressed: () async {
            await _batalkanRekam();
            if (context.mounted) context.pop();
          },
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: Column(
        children: [
          StepperRegistrasi(
            langkahAktif: LangkahRegistrasi.suara,
            judulLangkah: t.verifikasiSuara,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Text(
                  t.ucapkanKalimatBerikut,
                  style: context.teks.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.tekanTombolRekam,
                  style: context.teks.bodySmall?.copyWith(
                    color: Warna.teksKedua,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: Jarak.lg),
                _KartuKalimat(
                  status: _statusKalimat,
                  kalimat: kalimat,
                  kode: kode,
                  indeksKata: _indeksKata,
                  sedangMerekam: _sedangMerekam,
                  jalurAudio: _jalurAudio,
                  saatCobaLagi: _muatKalimat,
                ),
                const SizedBox(height: Jarak.xxl),
                Center(
                  child: PanelRekamSuara(
                    sedangMerekam: _sedangMerekam,
                    detik: _detik,
                    amplitudo: _amplitudo,
                    aktif: _statusKalimat == _StatusKalimat.tersedia &&
                        (_jalurAudio == null || _sedangMerekam),
                    saatTekanRekam: _toggleRekam,
                  ),
                ),
                if (_jalurAudio != null) ...[
                  const SizedBox(height: Jarak.xl),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Warna.suksesLembut,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            HugeIcons.strokeRoundedCheckmarkCircle02,
                            color: Warna.sukses,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t.rekamanTersedia,
                            style: context.teks.labelSmall?.copyWith(
                              color: Warna.sukses,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _bangunAksiBawah(t, kondisi.memuat),
            ),
          ),
        ],
      ),
    );
  }
}

extension on _HalamanSuaraState {
  Widget _bangunAksiBawah(Teks t, bool memuat) {
    if (_statusKalimat == _StatusKalimat.kosong) {
      return SizedBox(
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () => context.push(NamaRute.bantuan),
          icon: const Icon(HugeIcons.strokeRoundedCustomerService, size: 18),
          label: Text(t.hubungiDisdukcapilCta),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Warna.garisTegas, width: 1.2),
            foregroundColor: Warna.teksUtama,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }
    if (_statusKalimat == _StatusKalimat.jaringan ||
        _statusKalimat == _StatusKalimat.galat) {
      return SizedBox(
        height: 52,
        child: FilledButton.icon(
          onPressed: _muatKalimat,
          icon: const Icon(HugeIcons.strokeRoundedReload, size: 18),
          label: Text(t.cobaLagi),
          style: FilledButton.styleFrom(
            backgroundColor: Warna.merahUtama,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    if (_jalurAudio == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Warna.netral50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Warna.garis),
        ),
        child: Row(
          children: [
            const Icon(
              HugeIcons.strokeRoundedInformationCircle,
              color: Warna.info,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t.rekamSuaraMinimal,
                style: context.teks.bodySmall?.copyWith(
                  color: Warna.teksKedua,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final lanjutAktif = !memuat && _rekamanCocokKalimat;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: memuat ? null : _ulangi,
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
              onPressed: lanjutAktif ? _lanjut : null,
              style: FilledButton.styleFrom(
                backgroundColor: Warna.merahUtama,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Warna.netral200,
                disabledForegroundColor: Warna.teksKedua,
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
                        color: Colors.white,
                      ),
                    )
                  : Text(t.lanjut),
            ),
          ),
        ),
      ],
    );
  }
}

class _KartuKalimat extends ConsumerWidget {
  const _KartuKalimat({
    required this.status,
    required this.kalimat,
    required this.kode,
    required this.indeksKata,
    required this.sedangMerekam,
    required this.jalurAudio,
    required this.saatCobaLagi,
  });

  final _StatusKalimat status;
  final String kalimat;
  final String? kode;
  final int indeksKata;
  final bool sedangMerekam;
  final String? jalurAudio;
  final VoidCallback saatCobaLagi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    switch (status) {
      case _StatusKalimat.memuat:
        return const _SkeletonKalimat();
      case _StatusKalimat.kosong:
        return _BannerKalimat(
          ikon: HugeIcons.strokeRoundedAlert02,
          warnaIkon: Warna.peringatan,
          warnaLatar: Warna.peringatanLembut,
          judul: t.tantanganSuaraKosongJudul,
          pesan: t.tantanganSuaraKosongPesan,
        );
      case _StatusKalimat.jaringan:
        return _BannerKalimat(
          ikon: HugeIcons.strokeRoundedCellularNetworkOffline,
          warnaIkon: Warna.peringatan,
          warnaLatar: Warna.peringatanLembut,
          judul: t.jaringanBermasalah,
          pesan: t.tantanganSuaraGagalMuat,
          aksiLabel: t.cobaLagi,
          saatAksi: saatCobaLagi,
        );
      case _StatusKalimat.galat:
        return _BannerKalimat(
          ikon: HugeIcons.strokeRoundedAlert02,
          warnaIkon: Warna.bahaya,
          warnaLatar: Warna.bahayaLembut,
          judul: t.terjadiKesalahan,
          pesan: t.tantanganSuaraGagalMuat,
          aksiLabel: t.cobaLagi,
          saatAksi: saatCobaLagi,
        );
      case _StatusKalimat.tersedia:
        return Container(
          padding: const EdgeInsets.all(Jarak.lg),
          decoration: BoxDecoration(
            color: Warna.netral50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Warna.garis),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kode != null) ...[
                Text(
                  '${t.kodeVerifikasi} : $kode',
                  style: context.teks.labelSmall?.copyWith(
                    color: Warna.merahUtama,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              TeksTantanganSuara(
                kalimat: kalimat,
                indeksKata: indeksKata,
                kunci: '$sedangMerekam-$jalurAudio',
              ),
            ],
          ),
        );
    }
  }
}

class _BannerKalimat extends StatelessWidget {
  const _BannerKalimat({
    required this.ikon,
    required this.warnaIkon,
    required this.warnaLatar,
    required this.judul,
    required this.pesan,
    this.aksiLabel,
    this.saatAksi,
  });

  final IconData ikon;
  final Color warnaIkon;
  final Color warnaLatar;
  final String judul;
  final String pesan;
  final String? aksiLabel;
  final VoidCallback? saatAksi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Jarak.lg),
      decoration: BoxDecoration(
        color: warnaLatar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warnaIkon.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, color: warnaIkon, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  judul,
                  style: context.teks.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Warna.teksUtama,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pesan,
            style: context.teks.bodySmall?.copyWith(
              color: Warna.teksKedua,
              height: 1.45,
            ),
          ),
          if (aksiLabel != null && saatAksi != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: saatAksi,
                icon: const Icon(HugeIcons.strokeRoundedReload, size: 16),
                label: Text(aksiLabel!),
                style: TextButton.styleFrom(
                  foregroundColor: warnaIkon,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkeletonKalimat extends StatelessWidget {
  const _SkeletonKalimat();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Jarak.lg),
      decoration: BoxDecoration(
        color: Warna.netral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Warna.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 120, height: 10, color: Warna.netral200),
          const SizedBox(height: 12),
          Container(width: double.infinity, height: 14, color: Warna.netral100),
          const SizedBox(height: 8),
          Container(width: 220, height: 14, color: Warna.netral100),
        ],
      ),
    );
  }
}
