import 'dart:async';
import 'package:flutter/widgets.dart';

import '../config/session_config.dart';

class PengelolaSesi extends ChangeNotifier {
  PengelolaSesi({this.batasIdle = SessionConfig.batasIdleSesi});

  final Duration batasIdle;
  Timer? _pengatur;
  bool _kedaluwarsa = false;
  VoidCallback? _saatKedaluwarsa;

  bool get kedaluwarsa => _kedaluwarsa;

  void daftarPenanganKedaluwarsa(VoidCallback penangan) {
    _saatKedaluwarsa = penangan;
  }

  void mulai() {
    _kedaluwarsa = false;
    _aturUlang();
  }

  void sentuh() {
    if (_kedaluwarsa) return;
    _aturUlang();
  }

  void berhenti() {
    _pengatur?.cancel();
    _pengatur = null;
  }

  void _aturUlang() {
    _pengatur?.cancel();
    _pengatur = Timer(batasIdle, _picu);
  }

  void _picu() {
    _kedaluwarsa = true;
    _pengatur = null;
    _saatKedaluwarsa?.call();
    notifyListeners();
  }

  @override
  void dispose() {
    _pengatur?.cancel();
    super.dispose();
  }
}
