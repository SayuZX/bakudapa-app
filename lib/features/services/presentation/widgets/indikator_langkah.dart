import 'package:flutter/material.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';

class IndikatorLangkah extends StatelessWidget {
  const IndikatorLangkah({
    super.key,
    required this.langkah,
    required this.jumlah,
    required this.judul,
    required this.labelLangkah,
  });

  final int langkah;
  final int jumlah;
  final String judul;
  final String labelLangkah;

  static const double tinggi = 64;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: tinggi,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Jarak.layarH,
          0,
          Jarak.layarH,
          Jarak.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (saatIni, sebelumnya) => Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [...sebelumnya, ?saatIni],
                    ),
                    transitionBuilder: (anak, animasi) => FadeTransition(
                      opacity: animasi,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.25),
                          end: Offset.zero,
                        ).animate(animasi),
                        child: anak,
                      ),
                    ),
                    child: Text(
                      judul,
                      key: ValueKey(judul),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.teks.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Jarak.md),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    labelLangkah,
                    style: context.teks.labelSmall?.copyWith(
                      color: Warna.teksKetiga,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Jarak.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(Sudut.pil),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: (langkah + 1) / jumlah),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                builder: (_, nilai, _) => LinearProgressIndicator(
                  value: nilai,
                  minHeight: 5,
                  backgroundColor: Warna.netral100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
