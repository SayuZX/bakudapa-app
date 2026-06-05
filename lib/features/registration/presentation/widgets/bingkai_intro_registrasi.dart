import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../providers/penyedia_registrasi.dart';
import 'stepper_registrasi.dart';

class LangkahIntro {
  const LangkahIntro({required this.judul, this.deskripsi});
  final String judul;
  final String? deskripsi;
}

class BingkaiIntroRegistrasi extends StatelessWidget {
  const BingkaiIntroRegistrasi({
    super.key,
    required this.langkahAktif,
    required this.judulLangkah,
    required this.judulAppBar,
    required this.judul,
    required this.subJudul,
    required this.langkah,
    required this.tombol,
    this.catatan,
  });

  final LangkahRegistrasi langkahAktif;
  final String judulLangkah;
  final String judulAppBar;
  final String judul;
  final String subJudul;
  final List<LangkahIntro> langkah;
  final Widget tombol;
  final String? catatan;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Warna.permukaan,
      appBar: AppBar(
        title: Text(judulAppBar),
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: Column(
        children: [
          StepperRegistrasi(
            langkahAktif: langkahAktif,
            judulLangkah: judulLangkah,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              children: [
                Text(
                  judul,
                  textAlign: TextAlign.center,
                  style: teks.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subJudul,
                  textAlign: TextAlign.center,
                  style: teks.bodyMedium?.copyWith(
                    color: Warna.teksKedua,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: Jarak.xl),
                Text(
                  'Ikuti langkah berikut:',
                  style: teks.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: Jarak.md),
                for (var i = 0; i < langkah.length; i++) ...[
                  _BarisLangkah(nomor: i + 1, isi: langkah[i]),
                  if (i < langkah.length - 1) const SizedBox(height: 14),
                ],
                if (catatan != null) ...[
                  const SizedBox(height: Jarak.xl),
                  _Catatan(teks: catatan!),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: tombol,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarisLangkah extends StatelessWidget {
  const _BarisLangkah({required this.nomor, required this.isi});
  final int nomor;
  final LangkahIntro isi;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$nomor)',
          style: teks.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Warna.merahUtama,
            height: 1.4,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isi.judul,
                style: teks.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              if (isi.deskripsi != null) ...[
                const SizedBox(height: 2),
                Text(
                  isi.deskripsi!,
                  style: teks.bodySmall?.copyWith(
                    color: Warna.teksKedua,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Catatan extends StatelessWidget {
  const _Catatan({required this.teks});
  final String teks;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Catatan: ',
            style: t.bodySmall?.copyWith(
              color: Warna.teksUtama,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
          TextSpan(
            text: teks,
            style: t.bodySmall?.copyWith(
              color: Warna.teksKedua,
              fontStyle: FontStyle.italic,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
