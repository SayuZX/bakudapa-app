import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/router/navigasi_aman.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/models/permohonan.dart';
import '../../../shared/models/status_permohonan.dart';
import '../../../shared/providers/penyedia_permohonan.dart';
import '../../../shared/widgets/kondisi_galat.dart';
import '../../../shared/widgets/kondisi_kosong.dart';
import '../../../shared/widgets/pemuat_lingkar.dart';
import 'widgets/baris_permohonan.dart';

enum _FilterRiwayat {
  semua,
  berjalan,
  perluTindakan,
  selesai,
  berakhir;

  String label(Teks t) => switch (this) {
        semua => t.semua,
        berjalan => t.filterBerjalan,
        perluTindakan => t.filterPerluTindakan,
        selesai => t.labelSelesai,
        berakhir => t.filterBerakhir,
      };

  bool cocok(Permohonan p) {
    switch (this) {
      case _FilterRiwayat.semua:
        return true;
      case _FilterRiwayat.berjalan:
        return p.status == StatusPermohonan.menunggu ||
            p.status == StatusPermohonan.tertunda ||
            p.status.sedangBerjalan;
      case _FilterRiwayat.perluTindakan:
        return p.status == StatusPermohonan.perluPerbaikan;
      case _FilterRiwayat.selesai:
        return p.status == StatusPermohonan.selesai;
      case _FilterRiwayat.berakhir:
        return p.status == StatusPermohonan.ditolak ||
            p.status == StatusPermohonan.dibatalkan;
    }
  }
}

class HalamanRiwayat extends ConsumerStatefulWidget {
  const HalamanRiwayat({super.key});

  @override
  ConsumerState<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends ConsumerState<HalamanRiwayat> {
  _FilterRiwayat _filter = _FilterRiwayat.semua;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final riwayat = ref.watch(penyediaPengaturRiwayat);

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(
        title: Text(t.riwayatPermohonan),
        actions: [
          IconButton(
            onPressed: () => context.pushAman(NamaRute.layanan),
            tooltip: t.ajukanPermohonanBaru,
            icon: const Icon(HugeIcons.strokeRoundedAdd01, size: 22),
          ),
          const SizedBox(width: Jarak.sm),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: Jarak.layarH,
                vertical: Jarak.sm,
              ),
              itemCount: _FilterRiwayat.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: Jarak.sm),
              itemBuilder: (context, indeks) {
                final filter = _FilterRiwayat.values[indeks];
                final aktif = filter == _filter;
                return ChoiceChip(
                  label: Text(filter.label(t)),
                  selected: aktif,
                  showCheckmark: false,
                  labelStyle: context.teks.labelMedium?.copyWith(
                    color: aktif ? Warna.primerGelap : Warna.teksKedua,
                    fontWeight: aktif ? FontWeight.w800 : FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _filter = filter),
                );
              },
            ),
          ),
          Expanded(
            child: riwayat.when(
              loading: () => PemuatLingkar(pesan: t.memuatRiwayat),
              error: (e, _) => KondisiGalat(
                pesan: pesanRamah(e, fallback: t.gagalMuatRiwayat, teks: t),
                saatCobaLagi: () =>
                    ref.read(penyediaPengaturRiwayat.notifier).muat(),
              ),
              data: (daftar) {
                final tersaring = daftar.where(_filter.cocok).toList();
                if (tersaring.isEmpty) {
                  return RefreshIndicator(
                    color: Warna.primer,
                    onRefresh: () =>
                        ref.read(penyediaPengaturRiwayat.notifier).segarkan(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: context.ukuran.height * 0.12),
                        KondisiKosong(
                          judul: _filter == _FilterRiwayat.semua
                              ? t.riwayatKosongJudul
                              : t.tidakAdaData,
                          pesan: _filter == _FilterRiwayat.semua
                              ? t.riwayatKosongPesan
                              : t.tanpaStatus(_filter.label(t)),
                          ikon: HugeIcons.strokeRoundedFile02,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: Warna.primer,
                  onRefresh: () =>
                      ref.read(penyediaPengaturRiwayat.notifier).segarkan(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      Jarak.layarH,
                      Jarak.sm,
                      Jarak.layarH,
                      Jarak.xxxl,
                    ),
                    itemCount: tersaring.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Jarak.md),
                    itemBuilder: (context, indeks) {
                      return BarisPermohonan(permohonan: tersaring[indeks])
                          .animate(delay: (indeks.clamp(0, 8) * 40).ms)
                          .fadeIn(duration: 260.ms, curve: Curves.easeOutCubic)
                          .slideY(
                            begin: 0.06,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOutCubic,
                          );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
