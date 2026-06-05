import 'dart:async';
import 'package:flutter/foundation.dart';

class Penunda {
  Penunda({this.jeda = const Duration(milliseconds: 400)});

  final Duration jeda;
  Timer? _pengatur;

  void jalan(VoidCallback aksi) {
    _pengatur?.cancel();
    _pengatur = Timer(jeda, aksi);
  }

  void batal() => _pengatur?.cancel();

  void dispose() {
    _pengatur?.cancel();
    _pengatur = null;
  }
}

class Pembatas {
  Pembatas({this.jedaPendingin = const Duration(milliseconds: 1500)});

  final Duration jedaPendingin;
  DateTime? _terakhir;

  bool cobaJalan(VoidCallback aksi) {
    final kini = DateTime.now();
    if (_terakhir != null && kini.difference(_terakhir!) < jedaPendingin) {
      return false;
    }
    _terakhir = kini;
    aksi();
    return true;
  }

  void aturUlang() => _terakhir = null;
}
