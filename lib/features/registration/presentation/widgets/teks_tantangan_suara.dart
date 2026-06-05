import 'package:flutter/material.dart';

import '../../../../core/theme/warna.dart';

class TeksTantanganSuara extends StatelessWidget {
  const TeksTantanganSuara({
    super.key,
    required this.kalimat,
    required this.indeksKata,
    this.kunci,
  });

  final String kalimat;
  final int indeksKata;
  final String? kunci;

  @override
  Widget build(BuildContext context) {
    final kata = kalimat.split(RegExp(r'\s+'));
    final spans = <InlineSpan>[];
    for (var i = 0; i < kata.length; i++) {
      final aktif = i == indeksKata;
      final sudah = i < indeksKata;

      Color warna;
      FontWeight tebal;
      if (sudah) {
        warna = Warna.teksUtama;
        tebal = FontWeight.w600;
      } else if (aktif) {
        warna = Warna.merahUtama;
        tebal = FontWeight.w800;
      } else {
        warna = Warna.teksKetiga;
        tebal = FontWeight.w500;
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(right: 4, bottom: 2),
            padding: aktif
                ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: aktif ? Warna.merahLembut : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: warna,
                fontSize: 17,
                fontWeight: tebal,
                height: 1.55,
                letterSpacing: -0.1,
              ),
              child: Text(kata[i]),
            ),
          ),
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.start,
      key: ValueKey(kunci),
    );
  }
}
