import 'package:flutter/material.dart';

class Bayangan {
  const Bayangan._();

  static List<BoxShadow> get kartu => const [
        BoxShadow(color: Color(0x0F101828), blurRadius: 12, offset: Offset(0, 4)),
        BoxShadow(color: Color(0x08101828), blurRadius: 2, offset: Offset(0, 1)),
      ];

  static List<BoxShadow> get halus => const [
        BoxShadow(color: Color(0x0A101828), blurRadius: 6, offset: Offset(0, 2)),
      ];

  static List<BoxShadow> get melayang => const [
        BoxShadow(color: Color(0x14101828), blurRadius: 20, offset: Offset(0, 8)),
      ];

  static List<BoxShadow> get bilahBawah => const [
        BoxShadow(color: Color(0x0A101828), blurRadius: 16, offset: Offset(0, -2)),
      ];
}
