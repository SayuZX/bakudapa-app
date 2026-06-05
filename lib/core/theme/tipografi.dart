import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'warna.dart';

class Tipografi {
  const Tipografi._();

  static TextTheme bangun() {
    final TextTheme dasar = GoogleFonts.plusJakartaSansTextTheme();

    TextStyle gaya({
      required double ukuran,
      required FontWeight tebal,
      double? tinggi,
      double rapatHuruf = -0.1,
      Color warna = Warna.teksUtama,
    }) =>
        dasar.bodyMedium!.copyWith(
          fontSize: ukuran,
          fontWeight: tebal,
          height: tinggi,
          letterSpacing: rapatHuruf,
          color: warna,
        );

    return TextTheme(
      displayLarge: gaya(ukuran: 36, tebal: FontWeight.w700, tinggi: 1.16, rapatHuruf: -0.6),
      displayMedium: gaya(ukuran: 30, tebal: FontWeight.w700, tinggi: 1.2, rapatHuruf: -0.5),
      displaySmall: gaya(ukuran: 26, tebal: FontWeight.w700, tinggi: 1.22, rapatHuruf: -0.4),
      headlineLarge: gaya(ukuran: 24, tebal: FontWeight.w700, tinggi: 1.24, rapatHuruf: -0.3),
      headlineMedium: gaya(ukuran: 22, tebal: FontWeight.w700, tinggi: 1.26, rapatHuruf: -0.3),
      headlineSmall: gaya(ukuran: 20, tebal: FontWeight.w700, tinggi: 1.28, rapatHuruf: -0.2),
      titleLarge: gaya(ukuran: 18, tebal: FontWeight.w700, tinggi: 1.3),
      titleMedium: gaya(ukuran: 16, tebal: FontWeight.w600, tinggi: 1.35),
      titleSmall: gaya(ukuran: 14, tebal: FontWeight.w600, tinggi: 1.4),
      bodyLarge: gaya(ukuran: 16, tebal: FontWeight.w500, tinggi: 1.5),
      bodyMedium: gaya(ukuran: 14, tebal: FontWeight.w500, tinggi: 1.5),
      bodySmall: gaya(ukuran: 12, tebal: FontWeight.w500, tinggi: 1.5, warna: Warna.teksKedua),
      labelLarge: gaya(ukuran: 14, tebal: FontWeight.w600, tinggi: 1.3),
      labelMedium: gaya(ukuran: 12, tebal: FontWeight.w600, tinggi: 1.3, warna: Warna.teksKedua),
      labelSmall: gaya(ukuran: 11, tebal: FontWeight.w600, tinggi: 1.3, warna: Warna.teksKetiga, rapatHuruf: 0.2),
    );
  }
}
