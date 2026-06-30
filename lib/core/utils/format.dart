import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../localization/teks.dart';
import '../localization/teks_id.dart';
import 'waktu_server.dart';

class Format {
  const Format._();

  static String _locale = 'id_ID';
  static Teks _teks = const TeksId();

  static void pasang(String locale, Teks teks) {
    _locale = locale;
    _teks = teks;
  }

  static String tanggalPanjang(DateTime d) =>
      DateFormat('d MMMM y', _locale).format(d);
  static String tanggalPendek(DateTime d) =>
      DateFormat('d MMM y', _locale).format(d);
  static String tanggalJam(DateTime d) =>
      DateFormat('d MMM y, HH:mm', _locale).format(d);
  static String jam(DateTime d) => DateFormat('HH:mm', _locale).format(d);

  static String relatif(DateTime d) {
    final kini = WaktuServer.kini();
    final selisih = kini.difference(d);
    if (selisih.inSeconds < 60) return _teks.baruSaja;
    if (selisih.inMinutes < 60) return _teks.menitLalu(selisih.inMinutes);
    if (selisih.inHours < 24) return _teks.jamLalu(selisih.inHours);
    if (selisih.inDays < 7) return _teks.hariLalu(selisih.inDays);
    return tanggalPendek(d);
  }
}

class HanyaDigitFormatter extends TextInputFormatter {
  HanyaDigitFormatter({this.panjangMaks});
  final int? panjangMaks;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue lama,
    TextEditingValue baru,
  ) {
    final digit = baru.text.replaceAll(RegExp(r'\D'), '');
    final hasil = panjangMaks != null && digit.length > panjangMaks!
        ? digit.substring(0, panjangMaks!)
        : digit;
    return TextEditingValue(
      text: hasil,
      selection: TextSelection.collapsed(offset: hasil.length),
    );
  }
}
