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
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/widgets/kondisi_galat.dart';
import '../../../shared/widgets/kondisi_kosong.dart';
import '../../../shared/widgets/pemuat_lingkar.dart';
import '../providers/penyedia_layanan.dart';

class HalamanLayanan extends ConsumerWidget {
  const HalamanLayanan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final daftar = ref.watch(
      penyediaDaftarLayanan(const FilterDaftarLayanan()),
    );
    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.layananPermohonan)),
      body: daftar.when(
        loading: () => PemuatLingkar(pesan: t.mohonTungguSebentar),
        error: (e, _) => KondisiGalat(
          pesan: pesanRamah(e, fallback: t.terjadiKesalahan, teks: t),
          saatCobaLagi: () => ref.invalidate(
            penyediaDaftarLayanan(const FilterDaftarLayanan()),
          ),
        ),
        data: (layanan) {
          if (layanan.isEmpty) {
            return KondisiKosong(
              judul: t.tidakAdaLayanan,
              labelAksi: t.cobaLagi,
              saatAksi: () => ref.invalidate(
                penyediaDaftarLayanan(const FilterDaftarLayanan()),
              ),
            );
          }
          return _DaftarServer(teks: t, layanan: layanan);
        },
      ),
    );
  }
}

class _DaftarServer extends StatelessWidget {
  const _DaftarServer({required this.teks, required this.layanan});

  final Teks teks;
  final List<RingkasanLayanan> layanan;

  @override
  Widget build(BuildContext context) {
    final kelompok = <String, List<RingkasanLayanan>>{};
    for (final item in layanan) {
      final kunci = (item.kategori ?? '').trim();
      kelompok.putIfAbsent(kunci.isEmpty ? '_' : kunci, () => []).add(item);
    }
    final kategori = kelompok.keys.toList();
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        Jarak.layarH,
        Jarak.sm,
        Jarak.layarH,
        Jarak.xxxl,
      ),
      children: [
        for (var i = 0; i < kategori.length; i++) ...[
          if (i > 0) const SizedBox(height: Jarak.xxl),
          if (kategori[i] != '_') ...[
            Text(
              teks.katalog(kategori[i]),
              style: context.teks.labelLarge?.copyWith(
                color: Warna.teksKetiga,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: Jarak.md),
          ],
          _KartuKelompok(
            anak: [
              for (final item in kelompok[kategori[i]]!)
                _BarisLayananServer(teks: teks, layanan: item),
            ],
          ),
        ].animate(delay: (i * 70).ms).fadeIn(
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            ),
      ],
    );
  }
}

class _KartuKelompok extends StatelessWidget {
  const _KartuKelompok({required this.anak});

  final List<Widget> anak;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var j = 0; j < anak.length; j++) ...[
            if (j > 0) const Divider(indent: 76, color: Warna.pemisah),
            anak[j],
          ],
        ],
      ),
    );
  }
}

class _BarisLayananServer extends StatelessWidget {
  const _BarisLayananServer({required this.teks, required this.layanan});

  final Teks teks;
  final RingkasanLayanan layanan;

  @override
  Widget build(BuildContext context) {
    return _BarisIsi(
      teks: teks,
      ikon: layanan.ikon,
      nama: teks.katalog(layanan.nama),
      deskripsi: teks.katalog(layanan.deskripsiTampil),
      saatKetuk: () =>
          context.pushAman(NamaRute.layananAwal, extra: layanan),
    );
  }
}

class _BarisIsi extends StatelessWidget {
  const _BarisIsi({
    required this.teks,
    required this.ikon,
    required this.nama,
    required this.deskripsi,
    required this.saatKetuk,
  });

  final Teks teks;
  final IconData ikon;
  final String nama;
  final String deskripsi;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: saatKetuk,
      splashColor: Warna.primerLembut,
      highlightColor: Warna.primerLembut,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Jarak.lg,
          vertical: Jarak.lg,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Warna.primerLembut,
                borderRadius: BorderRadius.circular(Sudut.md),
              ),
              child: Icon(ikon, size: 22, color: Warna.primer),
            ),
            const SizedBox(width: Jarak.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: context.teks.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (deskripsi.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.teks.bodySmall?.copyWith(
                        color: Warna.teksKedua,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Jarak.sm),
            const Icon(
              HugeIcons.strokeRoundedArrowRight01,
              size: 18,
              color: Warna.teksKetiga,
            ),
          ],
        ),
      ),
    );
  }
}
