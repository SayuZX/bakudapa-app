import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class _PenjagaNavigasi {
  static String? _lokasiTerakhir;
  static DateTime? _waktuTerakhir;

  static const Duration _jendela = Duration(milliseconds: 600);

  static bool boleh(String lokasi) {
    final sekarang = DateTime.now();
    final ganda = lokasi == _lokasiTerakhir &&
        _waktuTerakhir != null &&
        sekarang.difference(_waktuTerakhir!) < _jendela;
    if (ganda) return false;
    _lokasiTerakhir = lokasi;
    _waktuTerakhir = sekarang;
    return true;
  }
}

extension NavigasiAman on BuildContext {
  void pushAman(String lokasi, {Object? extra}) {
    if (!_PenjagaNavigasi.boleh(lokasi)) return;
    push(lokasi, extra: extra);
  }
}
