import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Format {
  const Format._();

  static final DateFormat _tanggalPanjang = DateFormat('d MMMM y', 'id_ID');
  static final DateFormat _tanggalPendek = DateFormat('d MMM y', 'id_ID');
  static final DateFormat _tanggalJam = DateFormat('d MMM y, HH:mm', 'id_ID');
  static final DateFormat _jam = DateFormat('HH:mm', 'id_ID');

  static String tanggalPanjang(DateTime d) => _tanggalPanjang.format(d);
  static String tanggalPendek(DateTime d) => _tanggalPendek.format(d);
  static String tanggalJam(DateTime d) => _tanggalJam.format(d);
  static String jam(DateTime d) => _jam.format(d);

  static String relatif(DateTime d) {
    final kini = DateTime.now();
    final selisih = kini.difference(d);
    if (selisih.inSeconds < 60) return 'Baru saja';
    if (selisih.inMinutes < 60) return '${selisih.inMinutes} menit lalu';
    if (selisih.inHours < 24) return '${selisih.inHours} jam lalu';
    if (selisih.inDays < 7) return '${selisih.inDays} hari lalu';
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
