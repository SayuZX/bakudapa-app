import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/router/navigasi_aman.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../shared/models/jenis_layanan.dart';

class LembarPilihJalurAkta extends ConsumerWidget {
  const LembarPilihJalurAkta({super.key});

  static Future<void> tampilkan(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Warna.permukaan,
      builder: (_) => const LembarPilihJalurAkta(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Jarak.layarH,
          0,
          Jarak.layarH,
          Jarak.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.katalog(JenisLayanan.aktaKelahiran.namaSingkat),
              style: context.teks.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: Jarak.xs),
            Text(
              t.pilihJalurPermohonan,
              style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
            ),
            const SizedBox(height: Jarak.xl),
            _PilihanJalur(
              ikon: HugeIcons.strokeRoundedId,
              judul: t.jalurPunyaNik,
              deskripsi: t.jalurPunyaNikSub,
              saatKetuk: () => _pilih(context, JenisLayanan.aktaKelahiran),
            ),
            const SizedBox(height: Jarak.md),
            _PilihanJalur(
              ikon: HugeIcons.strokeRoundedIdNotVerified,
              judul: t.jalurTanpaNik,
              deskripsi: t.jalurTanpaNikSub,
              saatKetuk: () =>
                  _pilih(context, JenisLayanan.aktaKelahiranTanpaNik),
            ),
          ],
        ),
      ),
    );
  }

  void _pilih(BuildContext context, JenisLayanan jenis) {
    Navigator.of(context).pop();
    context.pushAman(
      NamaRute.layananAwal,
      extra: RingkasanLayanan.dariJenis(jenis),
    );
  }
}

class _PilihanJalur extends StatelessWidget {
  const _PilihanJalur({
    required this.ikon,
    required this.judul,
    required this.deskripsi,
    required this.saatKetuk,
  });

  final IconData ikon;
  final String judul;
  final String deskripsi;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Warna.permukaan,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sudut.lg),
        side: const BorderSide(color: Warna.garis),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: saatKetuk,
        splashColor: Warna.primerLembut,
        highlightColor: Warna.primerLembut,
        child: Padding(
          padding: const EdgeInsets.all(Jarak.lg),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
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
                      judul,
                      style: context.teks.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deskripsi,
                      style: context.teks.bodySmall?.copyWith(
                        color: Warna.teksKedua,
                      ),
                    ),
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
      ),
    );
  }
}
