import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/dialogs/dialog_aplikasi.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/models/perangkat_aktif.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import 'widgets/kartu_perangkat.dart';

class HalamanKelolaPerangkat extends ConsumerStatefulWidget {
  const HalamanKelolaPerangkat({super.key, required this.perangkatAwal});

  final List<PerangkatAktif> perangkatAwal;

  @override
  ConsumerState<HalamanKelolaPerangkat> createState() =>
      _HalamanKelolaPerangkatState();
}

class _HalamanKelolaPerangkatState
    extends ConsumerState<HalamanKelolaPerangkat> {
  late final List<PerangkatAktif> _perangkat = [...widget.perangkatAwal];

  Future<void> _logout(PerangkatAktif perangkat) async {
    final t = ref.read(teksProvider);
    final yakin = await DialogAplikasi.tampilkanKonfirmasi(
      context: context,
      judul: t.logoutPerangkatKonfirmasiJudul,
      pesan: t.logoutPerangkatKonfirmasiPesan,
      labelKonfirmasi: t.logoutPerangkat,
      labelBatal: t.batal,
      destruktif: true,
      nada: NadaDialog.bahaya,
    );
    if (!yakin || !mounted) return;

    try {
      await ref
          .read(penyediaMuatGlobal.notifier)
          .jalankan(
            () => ref.read(penyediaRepositoriPerangkat).cabut(perangkat.sesiId),
            judul: t.logoutPerangkat,
          );
      if (!mounted) return;
      setState(() => _perangkat.removeWhere((p) => p.sesiId == perangkat.sesiId));
      context.tampilkanSukses(t.perangkatBerhasilDilogout);
    } on Kesalahan catch (e) {
      if (mounted) context.tampilkanGalat(e.pesan);
    } catch (_) {
      if (mounted) context.tampilkanGalat(t.gagalLogoutPerangkat);
    }
  }

  Future<void> _lanjut() async {
    final t = ref.read(teksProvider);
    await ref
        .read(penyediaMuatGlobal.notifier)
        .jalankan(
          () => ref.read(penyediaOtentikasi.notifier).lanjutkanSetelahKelola(),
          judul: t.mohonTunggu,
        );
    if (mounted) context.go(NamaRute.beranda);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Warna.latar,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    Jarak.layarH,
                    Jarak.xxl,
                    Jarak.layarH,
                    Jarak.lg,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Warna.peringatanLembut,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          HugeIcons.strokeRoundedSmartPhone01,
                          size: 34,
                          color: Warna.peringatan,
                        ),
                      ),
                    ),
                    const SizedBox(height: Jarak.lg),
                    Text(
                      t.batasPerangkatJudul,
                      textAlign: TextAlign.center,
                      style: context.teks.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Jarak.sm),
                    Text(
                      t.batasPerangkatPesan,
                      textAlign: TextAlign.center,
                      style: context.teks.bodyMedium?.copyWith(
                        color: Warna.teksKedua,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: Jarak.xxl),
                    for (var i = 0; i < _perangkat.length; i++) ...[
                      if (i > 0) const SizedBox(height: Jarak.md),
                      KartuPerangkat(
                        perangkat: _perangkat[i],
                        saatLogout: () => _logout(_perangkat[i]),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Jarak.layarH,
                  Jarak.sm,
                  Jarak.layarH,
                  Jarak.lg,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _lanjut,
                    style: FilledButton.styleFrom(
                      backgroundColor: Warna.primer,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(t.lanjutKeBeranda),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
