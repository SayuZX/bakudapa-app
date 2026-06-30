import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/teks.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/theme/warna.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/bingkai_intro_registrasi.dart';

class HalamanIntroFotoWajah extends ConsumerWidget {
  const HalamanIntroFotoWajah({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percobaan = ref.watch(penyediaRegistrasi).percobaanFotoWajah;
    final t = ref.watch(teksProvider);
    final adaPercobaanSebelumnya =
        percobaan > 0 && percobaan < KondisiRegistrasi.maksPercobaanFotoWajah;
    final sisa = KondisiRegistrasi.maksPercobaanFotoWajah - percobaan;

    return BingkaiIntroRegistrasi(
      langkahAktif: LangkahRegistrasi.fotoWajah,
      judulAppBar: t.fotoWajah,
      judulLangkah: t.fotoWajah,
      judul: t.pengambilanFotoWajah,
      subJudul: t.fotoWajahDigunakan,
      langkah: [
        LangkahIntro(
          judul: t.langkahIntroFotoWajah1Judul,
          deskripsi: t.langkahIntroFotoWajah1Deskripsi,
        ),
        LangkahIntro(
          judul: t.langkahIntroFotoWajah2Judul,
          deskripsi: t.langkahIntroFotoWajah2Deskripsi,
        ),
        LangkahIntro(
          judul: t.langkahIntroFotoWajah3Judul,
          deskripsi: t.langkahIntroFotoWajah3Deskripsi,
        ),
        LangkahIntro(
          judul: t.langkahIntroFotoWajah4Judul,
          deskripsi: t.langkahIntroFotoWajah4Deskripsi,
        ),
      ],
      catatan: adaPercobaanSebelumnya
          ? t.catatanSisaPercobaan(sisa)
          : t.catatanKualitasFoto,
      tombol: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: () {
            if (percobaan >= KondisiRegistrasi.maksPercobaanFotoWajah) {
              ref.read(penyediaRegistrasi.notifier).resetPercobaanFotoWajah();
            }
            context.push(NamaRute.daftarKameraFotoWajah);
          },
          style: FilledButton.styleFrom(
            backgroundColor: Warna.primer,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(percobaan > 0 ? t.lanjutkan : t.mulai),
        ),
      ),
    );
  }
}
