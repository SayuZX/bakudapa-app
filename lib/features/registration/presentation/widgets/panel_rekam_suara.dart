import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/theme/warna.dart';

class PanelRekamSuara extends StatelessWidget {
  const PanelRekamSuara({
    super.key,
    required this.sedangMerekam,
    required this.detik,
    required this.amplitudo,
    required this.saatTekanRekam,
    this.aktif = true,
  });

  final bool sedangMerekam;
  final int detik;
  final double amplitudo;
  final VoidCallback saatTekanRekam;
  final bool aktif;

  String _format() {
    final m = (detik ~/ 60).toString().padLeft(2, '0');
    final s = (detik % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(20, (i) {
            final tinggi = (8 + (amplitudo * 36 * ((i % 7 + 1) / 7))).clamp(8.0, 44.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 3,
                height: sedangMerekam ? tinggi : 8,
                decoration: BoxDecoration(
                  color: sedangMerekam ? Warna.merahUtama : Warna.netral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        Text(
          _format(),
          style: context.teks.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: sedangMerekam ? Warna.merahUtama : Warna.teksUtama,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: aktif ? saatTekanRekam : null,
          customBorder: const CircleBorder(),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: aktif ? Warna.merahUtama : Warna.netral300,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (aktif ? Warna.merahUtama : Warna.netral300)
                      .withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              sedangMerekam
                  ? HugeIcons.strokeRoundedStop
                  : HugeIcons.strokeRoundedMic01,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}
