import 'package:flutter/material.dart';

class TeksInstruksiLiveness extends StatelessWidget {
  const TeksInstruksiLiveness({
    super.key,
    required this.utama,
    this.pendukung,
    this.kunciAnimasi,
  });

  final String utama;
  final String? pendukung;
  final String? kunciAnimasi;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (anak, anim) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(anim),
            child: anak,
          ),
        );
      },
      child: Column(
        key: ValueKey(kunciAnimasi ?? utama),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            utama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              height: 1.25,
            ),
          ),
          if (pendukung != null) ...[
            const SizedBox(height: 8),
            Text(
              pendukung!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
