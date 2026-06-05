import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/biometric/layanan_biometrik.dart';
import '../../../../core/biometric/model_hasil_biometrik.dart';
import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../shared/providers/penyedia_muat_global.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/stepper_registrasi.dart';

enum _Tahap { memeriksa, siap, tidakDidukung, memverifikasi, sukses, gagal }

class HalamanSidikJari extends ConsumerStatefulWidget {
  const HalamanSidikJari({super.key});

  @override
  ConsumerState<HalamanSidikJari> createState() => _HalamanSidikJariState();
}

class _HalamanSidikJariState extends ConsumerState<HalamanSidikJari> {
  _Tahap _tahap = _Tahap.memeriksa;
  HasilBiometrikSidikJari? _hasil;
  String? _pesan;

  @override
  void initState() {
    super.initState();
    Future.microtask(_periksaKetersediaan);
  }

  Future<void> _periksaKetersediaan() async {
    final t = ref.read(teksProvider);
    final ada = await LayananBiometrik.instance.punyaSensor();
    if (!mounted) return;
    if (!ada) {
      setState(() {
        _tahap = _Tahap.tidakDidukung;
        _pesan = t.perangkatTidakMendukungSidikJari;
      });
      return;
    }
    final adaSidikJari = await LayananBiometrik.instance.tersediaSidikJari();
    if (!mounted) return;
    if (!adaSidikJari) {
      setState(() {
        _tahap = _Tahap.tidakDidukung;
        _pesan = t.belumAdaSidikJari;
      });
      return;
    }
    setState(() => _tahap = _Tahap.siap);
  }

  Future<void> _verifikasi() async {
    // Cegah pemicuan ganda saat prompt biometrik sedang berjalan.
    if (_tahap == _Tahap.memverifikasi) return;
    setState(() => _tahap = _Tahap.memverifikasi);
    final hasil = await LayananBiometrik.instance.verifikasi();
    if (!mounted) return;
    setState(() {
      _hasil = hasil;
      _pesan = hasil.alasan;
      if (hasil.status == StatusBiometrik.diverifikasi) {
        _tahap = _Tahap.sukses;
      } else if (hasil.status == StatusBiometrik.tidakDidukung ||
          hasil.status == StatusBiometrik.belumTerdaftar) {
        _tahap = _Tahap.tidakDidukung;
      } else {
        _tahap = _Tahap.gagal;
      }
    });
    ref.read(penyediaRegistrasi.notifier).perbaruiSidikJari(hasil);
  }

  Future<void> _lanjut() async {
    final hasil = _hasil;
    if (hasil == null) return;
    final t = ref.read(teksProvider);
    final ok = await ref.read(penyediaMuatGlobal.notifier).jalankan<bool>(
      () => ref.read(penyediaRegistrasi.notifier).kirimSidikJari(hasil),
      judul: t.mohonTunggu,
      pesan: t.mengirimSidikJari,
    );
    if (!mounted) return;
    if (ok) {
      ref
          .read(penyediaRegistrasi.notifier)
          .ubahLangkah(LangkahRegistrasi.kebijakan);
      context.push(NamaRute.daftarKebijakan);
    } else {
      final p = ref.read(penyediaRegistrasi).pesanGalat ??
          t.gagalKirimStatusSidikJari;
      context.tampilkanGalat(p);
    }
  }

  Future<void> _lewati() async {
    final t = ref.read(teksProvider);
    final hasil = HasilBiometrikSidikJari(
      status: StatusBiometrik.dilewati,
      diverifikasiPada: DateTime.now(),
      tipeBiometrik: 'fingerprint',
      alasan: t.dilewatiPengguna,
    );
    ref.read(penyediaRegistrasi.notifier).perbaruiSidikJari(hasil);
    final ok = await ref.read(penyediaMuatGlobal.notifier).jalankan<bool>(
      () => ref.read(penyediaRegistrasi.notifier).kirimSidikJari(hasil),
      judul: t.mohonTunggu,
      pesan: t.mengirimSidikJari,
    );
    if (!mounted) return;
    if (ok) {
      ref
          .read(penyediaRegistrasi.notifier)
          .ubahLangkah(LangkahRegistrasi.kebijakan);
      context.push(NamaRute.daftarKebijakan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kondisi = ref.watch(penyediaRegistrasi);
    final t = ref.watch(teksProvider);

    return Scaffold(
      backgroundColor: Warna.permukaan,
      appBar: AppBar(
        title: Text(t.verifikasiSidikJari),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: Column(
        children: [
          StepperRegistrasi(
            langkahAktif: LangkahRegistrasi.sidikJari,
            judulLangkah: t.verifikasiSidikJari,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Text(
                  t.verifikasiSidikJari,
                  textAlign: TextAlign.center,
                  style: context.teks.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.gunakanSidikJariMemperkuat,
                  textAlign: TextAlign.center,
                  style: context.teks.bodyMedium?.copyWith(
                    color: Warna.teksKedua,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: Jarak.xxl),
                Center(child: _IkonBesar(tahap: _tahap)),
                const SizedBox(height: Jarak.xl),
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: Text(
                      _judul(),
                      key: ValueKey('judul-$_tahap'),
                      textAlign: TextAlign.center,
                      style: context.teks.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: Padding(
                      key: ValueKey('sub-$_tahap-${_pesan ?? ''}'),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        _subJudul(),
                        textAlign: TextAlign.center,
                        style: context.teks.bodySmall?.copyWith(
                          color: Warna.teksKedua,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Jarak.xl),
                Container(
                  decoration: BoxDecoration(
                    color: Warna.permukaan,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Warna.garis),
                  ),
                  child: Column(
                    children: [
                      _BarisInfo(
                        ikon: HugeIcons.strokeRoundedShieldUser,
                        teks: t.dataSidikJariTidakKirim,
                      ),
                      const Divider(height: 1, color: Warna.pemisah, indent: 52),
                      _BarisInfo(
                        ikon: HugeIcons.strokeRoundedFingerPrintScan,
                        teks: t.pastikanSensorAktif,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _Aksi(
                tahap: _tahap,
                memuat: kondisi.memuat,
                saatVerifikasi: _verifikasi,
                saatLanjut: _lanjut,
                saatCobaLagi: _verifikasi,
                saatLewati: _lewati,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _judul() {
    final t = ref.read(teksProvider);
    switch (_tahap) {
      case _Tahap.memeriksa:
        return t.memeriksaKetersediaan;
      case _Tahap.siap:
        return t.sensorSidikJariSiap;
      case _Tahap.tidakDidukung:
        return t.sidikJariTidakTersedia;
      case _Tahap.memverifikasi:
        return t.tempelkanJariSensor;
      case _Tahap.sukses:
        return t.sidikJariBerhasilDiverifikasi;
      case _Tahap.gagal:
        return t.verifikasiBelumBerhasil;
    }
  }

  String _subJudul() {
    final t = ref.read(teksProvider);
    switch (_tahap) {
      case _Tahap.memeriksa:
        return t.memeriksaKemampuanBiometrik;
      case _Tahap.siap:
        return t.tekanLaluTempelkanJari;
      case _Tahap.tidakDidukung:
        return _pesan ?? t.dapatLewatiJikaTidakWajib;
      case _Tahap.memverifikasi:
        return t.ikutiInstruksiPerangkat;
      case _Tahap.sukses:
        return t.statusVerifikasiDikirim;
      case _Tahap.gagal:
        return _pesan ?? t.cobaLagiAtauLewati;
    }
  }
}

class _IkonBesar extends StatelessWidget {
  const _IkonBesar({required this.tahap});
  final _Tahap tahap;

  Color get _warna {
    switch (tahap) {
      case _Tahap.sukses:
        return Warna.sukses;
      case _Tahap.tidakDidukung:
      case _Tahap.gagal:
        return Warna.peringatan;
      case _Tahap.memverifikasi:
        return Warna.merahUtama;
      case _Tahap.memeriksa:
      case _Tahap.siap:
        return Warna.teksUtama;
    }
  }

  IconData get _ikon {
    switch (tahap) {
      case _Tahap.sukses:
        return HugeIcons.strokeRoundedCheckmarkCircle02;
      case _Tahap.tidakDidukung:
        return HugeIcons.strokeRoundedAlert02;
      case _Tahap.gagal:
        return HugeIcons.strokeRoundedAlert02;
      default:
        return HugeIcons.strokeRoundedFingerPrintScan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Warna.netral50,
        shape: BoxShape.circle,
        border: Border.all(color: Warna.garis, width: 1.4),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: Warna.permukaan,
          shape: BoxShape.circle,
          border: Border.all(color: _warna, width: 1.6),
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Icon(
            _ikon,
            key: ValueKey('ikon-$tahap'),
            color: _warna,
            size: 44,
          ),
        ),
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  const _BarisInfo({required this.ikon, required this.teks});
  final IconData ikon;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Jarak.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Warna.netral100,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(ikon, size: 16, color: Warna.teksUtama),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              teks,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Warna.teksUtama,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Aksi extends ConsumerWidget {
  const _Aksi({
    required this.tahap,
    required this.memuat,
    required this.saatVerifikasi,
    required this.saatLanjut,
    required this.saatCobaLagi,
    required this.saatLewati,
  });

  final _Tahap tahap;
  final bool memuat;
  final VoidCallback saatVerifikasi;
  final VoidCallback saatLanjut;
  final VoidCallback saatCobaLagi;
  final VoidCallback saatLewati;

  ButtonStyle get _filled => FilledButton.styleFrom(
        backgroundColor: Warna.merahUtama,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      );

  ButtonStyle get _outline => OutlinedButton.styleFrom(
        side: const BorderSide(color: Warna.garisTegas, width: 1.2),
        foregroundColor: Warna.teksUtama,
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    switch (tahap) {
      case _Tahap.memeriksa:
      case _Tahap.memverifikasi:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: null,
            style: _filled,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.4, color: Colors.white),
            ),
          ),
        );
      case _Tahap.siap:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: saatVerifikasi,
            style: _filled,
            child: Text(t.mulaiVerifikasiSidikJari),
          ),
        );
      case _Tahap.tidakDidukung:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: saatCobaLagi,
                  style: _outline,
                  child: Text(t.cobaLagi),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: memuat ? null : saatLewati,
                  style: _filled,
                  child: memuat
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(t.lewatiLangkahIni),
                ),
              ),
            ),
          ],
        );
      case _Tahap.gagal:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: memuat ? null : saatLewati,
                  style: _outline,
                  child: Text(t.lewati),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: saatCobaLagi,
                  style: _filled,
                  child: Text(t.cobaLagi),
                ),
              ),
            ),
          ],
        );
      case _Tahap.sukses:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: memuat ? null : saatLanjut,
            style: _filled,
            child: memuat
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white),
                  )
                : Text(t.lanjutKeTinjauData),
          ),
        );
    }
  }
}
