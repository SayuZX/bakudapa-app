import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/theme/warna.dart';
import '../../providers/penyedia_registrasi.dart';

class StepperRegistrasi extends ConsumerWidget {
  const StepperRegistrasi({
    super.key,
    required this.langkahAktif,
    this.judulLangkah,
  });

  final LangkahRegistrasi langkahAktif;
  final String? judulLangkah;

  int get _indeks => LangkahRegistrasi.values.indexOf(langkahAktif);
  int get _total => LangkahRegistrasi.total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final progres = (_indeks + 1) / _total;
    return Container(
      color: Warna.permukaan,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t.langkahXDariY(_indeks + 1, _total),
                style: context.teks.labelMedium?.copyWith(
                  color: Warna.teksKedua,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              if (judulLangkah != null)
                Text(
                  judulLangkah!,
                  style: context.teks.labelMedium?.copyWith(
                    color: Warna.primer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progres),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 4,
                backgroundColor: Warna.netral100,
                valueColor: const AlwaysStoppedAnimation<Color>(Warna.primer),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
