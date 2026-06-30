import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/teks.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/theme/warna.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/bingkai_intro_registrasi.dart';

class HalamanIntroLiveness extends ConsumerWidget {
  const HalamanIntroLiveness({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return BingkaiIntroRegistrasi(
      langkahAktif: LangkahRegistrasi.liveness,
      judulAppBar: t.verifikasiWajah,
      judulLangkah: t.verifikasiWajah,
      judul: t.verifikasiWajahAktif,
      subJudul: t.subJudulIntroLiveness,
      langkah: [
        LangkahIntro(
          judul: t.langkahIntroLiveness1Judul,
          deskripsi: t.langkahIntroLiveness1Deskripsi,
        ),
        LangkahIntro(
          judul: t.langkahIntroLiveness2Judul,
          deskripsi: t.langkahIntroLiveness2Deskripsi,
        ),
        LangkahIntro(
          judul: t.langkahIntroLiveness3Judul,
          deskripsi: t.langkahIntroLiveness3Deskripsi,
        ),
        LangkahIntro(
          judul: t.langkahIntroLiveness4Judul,
          deskripsi: t.langkahIntroLiveness4Deskripsi,
        ),
      ],
      catatan: t.catatanIntroLiveness,
      tombol: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: () => context.push(NamaRute.daftarKameraLiveness),
          style: FilledButton.styleFrom(
            backgroundColor: Warna.primer,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(t.lanjutkan),
        ),
      ),
    );
  }
}
