import 'package:flutter/material.dart';

enum NadaStatusLiveness { netral, peringatan, sukses, deteksi }

class LencanaStatusLiveness extends StatelessWidget {
  const LencanaStatusLiveness({
    super.key,
    required this.teks,
    this.nada = NadaStatusLiveness.netral,
    this.ikon,
  });

  final String teks;
  final NadaStatusLiveness nada;
  final IconData? ikon;

  Color get _warnaTeks {
    switch (nada) {
      case NadaStatusLiveness.peringatan:
        return const Color(0xFFFFA68B);
      case NadaStatusLiveness.sukses:
        return const Color(0xFFA9E5B6);
      case NadaStatusLiveness.deteksi:
        return const Color(0xFFFCC2C9);
      case NadaStatusLiveness.netral:
        return Colors.white.withValues(alpha: 0.85);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (anak, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.3),
            end: Offset.zero,
          ).animate(anim),
          child: anak,
        ),
      ),
      child: Row(
        key: ValueKey('$nada-$teks'),
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ikon != null)
            Icon(ikon, size: 14, color: _warnaTeks)
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: _warnaTeks,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _warnaTeks.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          Text(
            teks,
            style: TextStyle(
              color: _warnaTeks,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
