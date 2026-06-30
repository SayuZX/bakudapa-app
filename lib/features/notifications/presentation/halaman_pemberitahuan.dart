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
import '../../../core/utils/format.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/models/pemberitahuan.dart';
import '../../../shared/providers/penyedia_pemberitahuan.dart';
import '../../../shared/widgets/kondisi_galat.dart';
import '../../../shared/widgets/kondisi_kosong.dart';
import '../../../shared/widgets/pemuat_kerlip.dart';

const _kategoriFilter = [
  KategoriPemberitahuan.status,
  KategoriPemberitahuan.tindakan,
  KategoriPemberitahuan.info,
  KategoriPemberitahuan.sistem,
];

class HalamanPemberitahuan extends ConsumerStatefulWidget {
  const HalamanPemberitahuan({super.key});

  @override
  ConsumerState<HalamanPemberitahuan> createState() =>
      _HalamanPemberitahuanState();
}

class _HalamanPemberitahuanState extends ConsumerState<HalamanPemberitahuan> {
  final _pengaturGulir = ScrollController();

  @override
  void initState() {
    super.initState();
    _pengaturGulir.addListener(_pantauGulir);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(penyediaJumlahBelumDibaca.notifier).segarkan();
    });
  }

  @override
  void dispose() {
    _pengaturGulir.removeListener(_pantauGulir);
    _pengaturGulir.dispose();
    super.dispose();
  }

  void _pantauGulir() {
    if (!_pengaturGulir.hasClients) return;
    final pos = _pengaturGulir.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      ref.read(penyediaPemberitahuan.notifier).muatBerikutnya();
    }
  }

  void _buka(Pemberitahuan notifikasi) {
    if (!notifikasi.dibaca) {
      ref.read(penyediaPemberitahuan.notifier).tandaiDibaca(notifikasi.id);
    }
    final id = notifikasi.permohonanId;
    if (id == null || id.isEmpty) return;
    final slug = notifikasi.metadata?.jenisLayanan;
    if (slug == null || JenisLayanan.dariSlug(slug) == null) return;
    context.pushAman('${NamaRute.detailPermohonan}/$slug/$id');
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final kondisi = ref.watch(penyediaPemberitahuan);
    final belumDibaca = ref.watch(penyediaJumlahBelumDibaca);
    final notifier = ref.read(penyediaPemberitahuan.notifier);

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(
        title: Text(t.tabNotifikasi),
        actions: [
          if (belumDibaca > 0)
            TextButton(
              onPressed: notifier.tandaiSemuaDibaca,
              child: Text(t.tandaiSemua),
            ),
          const SizedBox(width: Jarak.sm),
        ],
      ),
      body: Column(
        children: [
          _BilahFilter(
            kondisi: kondisi,
            teks: t,
            saatDibaca: notifier.pilihDibaca,
            saatKategori: notifier.pilihKategori,
          ),
          Expanded(child: _bangunIsi(t, kondisi)),
        ],
      ),
    );
  }

  Widget _bangunIsi(Teks t, KondisiPemberitahuan kondisi) {
    if (kondisi.memuat && kondisi.daftar.isEmpty) {
      return const DaftarKerangka();
    }
    if (kondisi.galat != null && kondisi.daftar.isEmpty) {
      return KondisiGalat(
        pesan: pesanRamah(
          kondisi.galat,
          fallback: t.gagalMuatNotifikasi,
          teks: t,
        ),
        saatCobaLagi: () => ref.read(penyediaPemberitahuan.notifier).muat(),
      );
    }
    return RefreshIndicator(
      color: Warna.primer,
      onRefresh: () => ref.read(penyediaPemberitahuan.notifier).segarkan(),
      child: kondisi.daftar.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: context.ukuran.height * 0.12),
                KondisiKosong(
                  judul: t.notifKosongJudul,
                  pesan: t.notifKosongPesan,
                  ikon: HugeIcons.strokeRoundedNotification01,
                ),
              ],
            )
          : ListView.separated(
              controller: _pengaturGulir,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(
                Jarak.layarH,
                Jarak.md,
                Jarak.layarH,
                Jarak.xxxl,
              ),
              itemCount: kondisi.daftar.length + (kondisi.memuatLagi ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: Jarak.sm),
              itemBuilder: (context, indeks) {
                if (indeks >= kondisi.daftar.length) {
                  return const _PemuatKaki();
                }
                final notifikasi = kondisi.daftar[indeks];
                return _BarisNotifikasi(
                      notifikasi: notifikasi,
                      saatKetuk: () => _buka(notifikasi),
                    )
                    .animate(delay: (indeks.clamp(0, 8) * 30).ms)
                    .fadeIn(duration: 220.ms, curve: Curves.easeOutCubic);
              },
            ),
    );
  }
}

class _BilahFilter extends StatelessWidget {
  const _BilahFilter({
    required this.kondisi,
    required this.teks,
    required this.saatDibaca,
    required this.saatKategori,
  });

  final KondisiPemberitahuan kondisi;
  final Teks teks;
  final ValueChanged<bool?> saatDibaca;
  final ValueChanged<KategoriPemberitahuan?> saatKategori;

  String _label(KategoriPemberitahuan k) {
    switch (k) {
      case KategoriPemberitahuan.status:
        return teks.kategoriStatus;
      case KategoriPemberitahuan.tindakan:
        return teks.kategoriTindakan;
      case KategoriPemberitahuan.info:
        return teks.kategoriInfo;
      case KategoriPemberitahuan.sistem:
        return teks.kategoriSistem;
      case KategoriPemberitahuan.takDikenal:
        return teks.kategoriInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: Jarak.sm),
      decoration: const BoxDecoration(
        color: Warna.latar,
        border: Border(bottom: BorderSide(color: Warna.garis, width: 0.6)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          Jarak.layarH,
          Jarak.sm,
          Jarak.layarH,
          0,
        ),
        child: Row(
          children: [
            _ChipFilter(
              label: teks.filterSemua,
              aktif: kondisi.filterDibaca == null,
              saatKetuk: () => saatDibaca(null),
            ),
            _ChipFilter(
              label: teks.filterBelumDibaca,
              aktif: kondisi.filterDibaca == false,
              saatKetuk: () => saatDibaca(false),
            ),
            Container(
              width: 1,
              height: 22,
              margin: const EdgeInsets.symmetric(horizontal: Jarak.sm),
              color: Warna.garis,
            ),
            for (final k in _kategoriFilter)
              _ChipFilter(
                label: _label(k),
                aktif: kondisi.filterKategori == k,
                saatKetuk: () =>
                    saatKategori(kondisi.filterKategori == k ? null : k),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChipFilter extends StatelessWidget {
  const _ChipFilter({
    required this.label,
    required this.aktif,
    required this.saatKetuk,
  });

  final String label;
  final bool aktif;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Jarak.sm),
      child: Material(
        color: aktif ? Warna.primer : Warna.permukaan,
        shape: StadiumBorder(
          side: BorderSide(color: aktif ? Warna.primer : Warna.garis),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: saatKetuk,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Jarak.lg,
              vertical: Jarak.sm,
            ),
            child: Text(
              label,
              style: context.teks.labelLarge?.copyWith(
                color: aktif ? Warna.putih : Warna.teksKedua,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PemuatKaki extends StatelessWidget {
  const _PemuatKaki();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: Jarak.lg),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: Warna.primer),
        ),
      ),
    );
  }
}

class _BarisNotifikasi extends StatelessWidget {
  const _BarisNotifikasi({required this.notifikasi, required this.saatKetuk});

  final Pemberitahuan notifikasi;
  final VoidCallback saatKetuk;

  IconData get _ikon {
    switch (notifikasi.kategori) {
      case KategoriPemberitahuan.status:
        return HugeIcons.strokeRoundedFile02;
      case KategoriPemberitahuan.tindakan:
        return HugeIcons.strokeRoundedAlert02;
      case KategoriPemberitahuan.info:
        return HugeIcons.strokeRoundedInformationCircle;
      case KategoriPemberitahuan.sistem:
        return HugeIcons.strokeRoundedSettings02;
      case KategoriPemberitahuan.takDikenal:
        return HugeIcons.strokeRoundedNotification01;
    }
  }

  @override
  Widget build(BuildContext context) {
    final belum = !notifikasi.dibaca;
    return Material(
      color: belum ? Warna.primerLembut : Warna.permukaan,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sudut.lg),
        side: BorderSide(color: belum ? Colors.transparent : Warna.garis),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: saatKetuk,
        child: Padding(
          padding: const EdgeInsets.all(Jarak.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: belum ? Warna.permukaan : Warna.netral50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _ikon,
                  size: 19,
                  color: belum ? Warna.primer : Warna.teksKedua,
                ),
              ),
              const SizedBox(width: Jarak.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notifikasi.judul,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.teks.titleSmall?.copyWith(
                              fontWeight: belum
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (belum)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: Jarak.sm),
                            decoration: const BoxDecoration(
                              color: Warna.primer,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notifikasi.pesan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.teks.bodySmall?.copyWith(
                        color: Warna.teksKedua,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Format.relatif(notifikasi.dikirimPada),
                      style: context.teks.labelSmall?.copyWith(
                        color: Warna.teksKetiga,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
