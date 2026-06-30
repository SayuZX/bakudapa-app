import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/dialogs/dialog_aplikasi.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/models/perangkat_aktif.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import '../../../shared/widgets/kondisi_galat.dart';
import '../../../shared/widgets/kondisi_kosong.dart';
import '../../../shared/widgets/pemuat_kerlip.dart';
import '../providers/penyedia_perangkat.dart';
import 'widgets/kartu_perangkat.dart';

class HalamanPerangkatAktif extends ConsumerWidget {
  const HalamanPerangkatAktif({super.key});

  Future<void> _logout(
    BuildContext context,
    WidgetRef ref,
    PerangkatAktif perangkat,
  ) async {
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
    if (!yakin || !context.mounted) return;

    try {
      await ref
          .read(penyediaMuatGlobal.notifier)
          .jalankan(
            () => ref.read(penyediaRepositoriPerangkat).cabut(perangkat.sesiId),
            judul: t.logoutPerangkat,
          );
      ref.invalidate(penyediaDaftarPerangkat);
      ref.invalidate(penyediaRiwayatPerangkat);
      if (context.mounted) context.tampilkanSukses(t.perangkatBerhasilDilogout);
    } on Kesalahan catch (e) {
      if (context.mounted) context.tampilkanGalat(e.pesan);
    } catch (_) {
      if (context.mounted) context.tampilkanGalat(t.gagalLogoutPerangkat);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Warna.latar,
        appBar: AppBar(
          title: Text(t.perangkatAktif),
          bottom: TabBar(
            labelColor: Warna.primer,
            unselectedLabelColor: Warna.teksKedua,
            indicatorColor: Warna.primer,
            tabs: [
              Tab(text: t.tabPerangkatAktif),
              Tab(text: t.tabRiwayatPerangkat),
            ],
          ),
        ),
        body: TabBarView(
          children: [_TabAktif(onLogout: _logout), const _TabRiwayat()],
        ),
      ),
    );
  }
}

class _TabAktif extends ConsumerWidget {
  const _TabAktif({required this.onLogout});

  final Future<void> Function(BuildContext, WidgetRef, PerangkatAktif) onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final daftar = ref.watch(penyediaDaftarPerangkat);

    return daftar.when(
      loading: () => const DaftarKerangka(jumlah: 3),
      error: (e, _) => KondisiGalat(
        pesan: e is Kesalahan ? e.pesan : t.terjadiKesalahan,
        saatCobaLagi: () => ref.invalidate(penyediaDaftarPerangkat),
      ),
      data: (perangkat) {
        if (perangkat.isEmpty) {
          return KondisiKosong(
            ikon: HugeIcons.strokeRoundedDeviceAccess,
            judul: t.tidakAdaPerangkatLain,
            pesan: t.tidakAdaPerangkatLainPesan,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(penyediaDaftarPerangkat),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(Jarak.layarH),
            itemCount: perangkat.length,
            separatorBuilder: (_, _) => const SizedBox(height: Jarak.md),
            itemBuilder: (_, i) => KartuPerangkat(
              perangkat: perangkat[i],
              saatLogout: () => onLogout(context, ref, perangkat[i]),
            ),
          ),
        );
      },
    );
  }
}

class _TabRiwayat extends ConsumerWidget {
  const _TabRiwayat();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final riwayat = ref.watch(penyediaRiwayatPerangkat);

    return riwayat.when(
      loading: () => const DaftarKerangka(jumlah: 4),
      error: (e, _) => KondisiGalat(
        pesan: e is Kesalahan ? e.pesan : t.terjadiKesalahan,
        saatCobaLagi: () => ref.invalidate(penyediaRiwayatPerangkat),
      ),
      data: (perangkat) {
        if (perangkat.isEmpty) {
          return KondisiKosong(
            ikon: HugeIcons.strokeRoundedDeviceAccess,
            judul: t.riwayatPerangkat,
            pesan: t.riwayatPerangkatKosong,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(penyediaRiwayatPerangkat),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(Jarak.layarH),
            itemCount: perangkat.length,
            separatorBuilder: (_, _) => const SizedBox(height: Jarak.md),
            itemBuilder: (_, i) =>
                KartuPerangkat(perangkat: perangkat[i], tampilkanStatus: true),
          ),
        );
      },
    );
  }
}
