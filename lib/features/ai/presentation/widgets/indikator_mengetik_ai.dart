import 'package:flutter/material.dart';

import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import 'lencana_asisten_ai.dart';

class IndikatorMengetikAi extends StatefulWidget {
  const IndikatorMengetikAi({super.key, required this.labelSemantik});

  final String labelSemantik;

  @override
  State<IndikatorMengetikAi> createState() => _IndikatorMengetikAiState();
}

class _IndikatorMengetikAiState extends State<IndikatorMengetikAi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol;

  @override
  void initState() {
    super.initState();
    _kontrol = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  double _opasitasTitik(int indeks) {
    final fase = ((_kontrol.value - indeks * 0.2) % 1.0 + 1.0) % 1.0;
    final puncak = 1 - ((fase - 0.5).abs() * 2);
    return 0.3 + 0.7 * puncak.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.labelSemantik,
      child: Padding(
        padding: const EdgeInsets.only(bottom: Jarak.lg),
        child: Row(
          children: [
            const LencanaAsistenAi(),
            const SizedBox(width: Jarak.md),
            AnimatedBuilder(
              animation: _kontrol,
              builder: (context, _) => Row(
                children: List.generate(3, (i) {
                  return Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
                    child: Opacity(
                      opacity: _opasitasTitik(i),
                      child: const _Titik(),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Titik extends StatelessWidget {
  const _Titik();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Warna.primer,
        shape: BoxShape.circle,
      ),
    );
  }
}
