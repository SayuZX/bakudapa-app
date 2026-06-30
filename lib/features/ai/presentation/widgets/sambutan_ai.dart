import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import 'chip_saran_ai.dart';

class SambutanAi extends StatelessWidget {
  const SambutanAi({
    super.key,
    required this.teks,
    required this.namaPengguna,
    required this.saran,
    required this.saatSaran,
  });

  final Teks teks;
  final String? namaPengguna;
  final List<String> saran;
  final ValueChanged<String> saatSaran;

  String? get _namaDepan {
    final nama = namaPengguna?.trim();
    if (nama == null || nama.isEmpty) return null;
    return nama.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Jarak.layarH,
        Jarak.raksasa,
        Jarak.layarH,
        Jarak.xl,
      ),
      children: [
        const Icon(
          HugeIcons.strokeRoundedSparkles,
          color: Warna.primer,
          size: 30,
        ),
        const SizedBox(height: Jarak.lg),
        Text(
          teks.sapaanWaktu(DateTime.now().hour, _namaDepan),
          style: context.teks.displaySmall?.copyWith(
            color: Warna.primer,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: Jarak.md),
        Text(
          teks.sapaanAi,
          style: context.teks.bodyLarge?.copyWith(
            color: Warna.teksKedua,
            height: 1.55,
          ),
        ),
        const SizedBox(height: Jarak.xxxl),
        Text(
          teks.cobaTanya,
          style: context.teks.labelMedium?.copyWith(
            color: Warna.teksKetiga,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: Jarak.md),
        Wrap(
          spacing: Jarak.sm,
          runSpacing: Jarak.sm,
          children: [
            for (final s in saran)
              ChipSaranAi(label: s, saatKetuk: () => saatSaran(s)),
          ],
        ),
      ],
    );
  }
}
