import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/camera/kamera.dart';
import '../../../../core/camera/pratinjau_kamera_isi.dart';
import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/network/penjaga_jaringan.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/system/penjaga_maintenance.dart';
import '../../../../core/storage/berkas_sementara.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../shared/providers/penyedia_muat_global.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/bingkai_kamera_dokumen.dart';
import '../widgets/stepper_registrasi.dart';

class HalamanFotoDokumen extends ConsumerStatefulWidget {
  const HalamanFotoDokumen({super.key});

  @override
  ConsumerState<HalamanFotoDokumen> createState() => _HalamanFotoDokumenState();
}

class _HalamanFotoDokumenState extends ConsumerState<HalamanFotoDokumen>
    with WidgetsBindingObserver {
  CameraController? _kontroler;
  bool _siap = false;
  bool _menangkap = false;
  String? _pratinjau;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _siapkanKamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LayananKamera.instance.tutup(_kontroler);
    _kontroler = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_kontroler == null) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      LayananKamera.instance.tutup(_kontroler);
      _kontroler = null;
      if (mounted) setState(() => _siap = false);
    } else if (state == AppLifecycleState.resumed) {
      _siapkanKamera();
    }
  }

  Future<void> _siapkanKamera() async {
    try {
      final k = await LayananKamera.instance.buat(arah: ArahKamera.belakang);
      if (!mounted) {
        await LayananKamera.instance.tutup(k);
        return;
      }
      setState(() {
        _kontroler = k;
        _siap = k != null;
      });
    } catch (_) {
      if (!mounted) return;
      context.tampilkanGalat(ref.read(teksProvider).tidakDapatBukaKamera);
    }
  }

  Future<void> _ambil() async {
    final c = _kontroler;
    if (c == null || !c.value.isInitialized || _menangkap) return;
    setState(() => _menangkap = true);
    try {
      final xf = await c.takePicture();
      final jalur = await BerkasSementara.instance.jalurBaru('dokumen');
      final tujuan = '$jalur.jpg';
      await File(xf.path).copy(tujuan);
      await BerkasSementara.instance.hapus(xf.path);
      if (!mounted) return;
      setState(() {
        _pratinjau = tujuan;
        _menangkap = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _menangkap = false);
      context.tampilkanGalat(ref.read(teksProvider).gagalMengambilFoto);
    }
  }

  Future<void> _ulangi() async {
    final lama = _pratinjau;
    setState(() => _pratinjau = null);
    await BerkasSementara.instance.hapus(lama);
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
      () => ref.read(penyediaRegistrasi.notifier).simpanFotoDokumen(jalur),
      judul: t.mohonTunggu,
      pesan: t.mengunggahFotoDokumen,
    );
    if (!mounted) return;
    if (ok) {
      ref.read(penyediaRegistrasi.notifier).ubahLangkah(LangkahRegistrasi.fotoWajah);
      context.push(NamaRute.daftarFotoWajah);
    } else {
      final p = ref.read(penyediaRegistrasi).pesanGalat ??
          t.gagalMengunggahFoto;
      context.tampilkanGalat(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kondisi = ref.watch(penyediaRegistrasi);
    final t = ref.watch(teksProvider);

    return Scaffold(
      backgroundColor: Warna.permukaan,
      appBar: AppBar(
        title: Text(t.fotoKtpEl),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: Column(
        children: [
          StepperRegistrasi(
            langkahAktif: LangkahRegistrasi.fotoDokumen,
            judulLangkah: t.fotoIdentitas,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pratinjau == null
                      ? t.ambilFotoKtpEl
                      : t.periksaHasilFotoKtpEl,
                  style: context.teks.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.pastikanDokumenJelas,
                  style: context.teks.bodySmall?.copyWith(
                    color: Warna.teksKedua,
                    height: 1.5,
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
                      : !_siap || _kontroler == null
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Warna.primer, strokeWidth: 2.4),
                            )
                          : BingkaiKameraDokumen(
                              anak: PratinjauKameraIsi(kontroler: _kontroler!),
                            ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: _pratinjau == null
                  ? _BarisAmbil(menangkap: _menangkap, saatAmbil: _ambil)
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
  const _BarisAmbil({required this.menangkap, required this.saatAmbil});
  final bool menangkap;
  final VoidCallback saatAmbil;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: menangkap ? null : saatAmbil,
        customBorder: const CircleBorder(),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Warna.primer,
            shape: BoxShape.circle,
            border: Border.all(color: Warna.permukaan, width: 4),
            boxShadow: [
              BoxShadow(
                color: Warna.primer.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: menangkap
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Icon(HugeIcons.strokeRoundedCamera01,
                  color: Colors.white, size: 30),
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
                backgroundColor: Warna.primer,
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
                  : Text(t.gunakanFotoIni),
            ),
          ),
        ),
      ],
    );
  }
}
