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
import '../../../core/utils/format.dart';
import '../../../shared/models/pemberitahuan.dart';
import '../../../shared/providers/penyedia_pemberitahuan.dart';
import '../../../shared/widgets/kondisi_galat.dart';
import '../../../shared/widgets/kondisi_kosong.dart';
import '../../../shared/widgets/pemuat_kerlip.dart';

class HalamanPemberitahuan extends ConsumerWidget {
  const HalamanPemberitahuan({super.key});

  Future<void> _tandaiSemua(BuildContext context, WidgetRef ref) async {
    final t = ref.read(teksProvider);
    final yakin = await DialogAplikasi.tampilkanKonfirmasi(
      context: context,
      judul: t.tandaiSemuaSudahDibaca,
      pesan: t.semuaPemberitahuanDitandai,
      labelKonfirmasi: t.tandaiSemua,
      nada: NadaDialog.info,
    );
    if (!yakin || !context.mounted) return;
    await ref.read(penyediaPemberitahuan.notifier).tandaiSemuaDibaca();
    if (context.mounted) context.tampilkanSukses(t.semuaPemberitahuanDitandaiDibaca);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keadaan = ref.watch(penyediaPemberitahuan);
    final pengatur = ref.read(penyediaPemberitahuan.notifier);
    final jumlahBelum = ref.watch(penyediaJumlahBelumDibaca);
    final t = ref.watch(teksProvider);

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(
        title: Text(t.pemberitahuanJudul),
        actions: [
          if (jumlahBelum > 0)
            IconButton(
              tooltip: t.tandaiSudahDibaca,
              onPressed: () => _tandaiSemua(context, ref),
              icon: const Icon(HugeIcons.strokeRoundedCheckmarkSquare01),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: keadaan.when(
          loading: () => const DaftarKerangka(),
          error: (e, _) => KondisiGalat(
            pesan: pesanRamah(e, fallback: t.terjadiKesalahan),
            saatCobaLagi: pengatur.muat,
          ),
          data: (daftar) {
            if (daftar.isEmpty) {
              return RefreshIndicator(
                color: Warna.merahUtama,
                onRefresh: pengatur.muat,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 80),
                    KondisiKosong(
                      ikon: HugeIcons.strokeRoundedNotification01,
                      judul: t.belumAdaPemberitahuan,
                      pesan: t.pembaruanStatusAkanMuncul,
                    ),
                  ],
                ),
              );
            }
            final kelompok = _kelompokkanPerTanggal(daftar, t);
            return RefreshIndicator(
              color: Warna.merahUtama,
              onRefresh: pengatur.muat,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  Jarak.layarH,
                  Jarak.md,
                  Jarak.layarH,
                  Jarak.xxl,
                ),
                itemCount: kelompok.length,
                itemBuilder: (_, indeks) {
                  final k = kelompok[indeks];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Jarak.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, Jarak.sm),
                          child: Text(
                            k.judul,
                            style: context.teks.labelMedium?.copyWith(
                              color: Warna.teksKedua,
                              letterSpacing: 0.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Warna.permukaan,
                            borderRadius: BorderRadius.circular(Sudut.lg),
                            border: Border.all(color: Warna.garis),
                          ),
                          child: Column(
                            children: [
                              for (var i = 0; i < k.daftar.length; i++) ...[
                                _BarisPemberitahuan(
                                  notifikasi: k.daftar[i],
                                  saatKetuk: () => _tanganiKetuk(
                                    context,
                                    ref,
                                    k.daftar[i],
                                  ),
                                ),
                                if (i < k.daftar.length - 1)
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 60,
                                    color: Warna.pemisah,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _tanganiKetuk(
    BuildContext context,
    WidgetRef ref,
    Pemberitahuan n,
  ) {
    if (!n.dibaca) {
      ref.read(penyediaPemberitahuan.notifier).tandaiDibaca(n.id);
    }
    if (n.idPermohonan != null) {
      context.push('${NamaRute.detailPermohonan}/${n.idPermohonan}');
    }
  }

  List<_KelompokTanggal> _kelompokkanPerTanggal(
      List<Pemberitahuan> daftar, Teks t) {
    final sekarang = DateTime.now();
    final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);
    final kemarin = hariIni.subtract(const Duration(days: 1));
    final mingguIni = hariIni.subtract(const Duration(days: 7));

    final hi = <Pemberitahuan>[];
    final ke = <Pemberitahuan>[];
    final mi = <Pemberitahuan>[];
    final lainnya = <Pemberitahuan>[];

    for (final n in daftar) {
      final tgl = DateTime(n.diterimaPada.year, n.diterimaPada.month, n.diterimaPada.day);
      if (tgl == hariIni) {
        hi.add(n);
      } else if (tgl == kemarin) {
        ke.add(n);
      } else if (tgl.isAfter(mingguIni)) {
        mi.add(n);
      } else {
        lainnya.add(n);
      }
    }

    final hasil = <_KelompokTanggal>[];
    if (hi.isNotEmpty) hasil.add(_KelompokTanggal(t.hariIni, hi));
    if (ke.isNotEmpty) hasil.add(_KelompokTanggal(t.kemarin, ke));
    if (mi.isNotEmpty) hasil.add(_KelompokTanggal(t.mingguIni, mi));
    if (lainnya.isNotEmpty) hasil.add(_KelompokTanggal(t.sebelumnya, lainnya));
    return hasil;
  }
}

class _KelompokTanggal {
  const _KelompokTanggal(this.judul, this.daftar);
  final String judul;
  final List<Pemberitahuan> daftar;
}

class _BarisPemberitahuan extends StatelessWidget {
  const _BarisPemberitahuan({
    required this.notifikasi,
    required this.saatKetuk,
  });

  final Pemberitahuan notifikasi;
  final VoidCallback saatKetuk;

  _IkonKategori _ikon() {
    switch (notifikasi.kategori) {
      case 'status':
        return const _IkonKategori(
          ikon: HugeIcons.strokeRoundedTaskDaily01,
          warna: Warna.info,
        );
      case 'tindakan':
        return const _IkonKategori(
          ikon: HugeIcons.strokeRoundedAlert02,
          warna: Warna.peringatan,
        );
      case 'info':
        return const _IkonKategori(
          ikon: HugeIcons.strokeRoundedInformationCircle,
          warna: Warna.teksKedua,
        );
      default:
        return const _IkonKategori(
          ikon: HugeIcons.strokeRoundedNotification01,
          warna: Warna.merahUtama,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ikon = _ikon();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: saatKetuk,
        borderRadius: BorderRadius.circular(Sudut.lg),
        child: Padding(
          padding: const EdgeInsets.all(Jarak.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ikon.warna.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(Sudut.sm),
                ),
                alignment: Alignment.center,
                child: Icon(ikon.ikon, color: ikon.warna, size: 18),
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
                            style: context.teks.titleSmall?.copyWith(
                              fontWeight: notifikasi.dibaca
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (!notifikasi.dibaca)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Warna.merahUtama,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notifikasi.pesan,
                      style: context.teks.bodySmall?.copyWith(
                        color: Warna.teksKedua,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Format.relatif(notifikasi.diterimaPada),
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

class _IkonKategori {
  const _IkonKategori({required this.ikon, required this.warna});
  final IconData ikon;
  final Color warna;
}
