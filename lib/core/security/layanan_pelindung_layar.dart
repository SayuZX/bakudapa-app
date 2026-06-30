import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LayananPelindungLayar {
  LayananPelindungLayar._();
  static final LayananPelindungLayar instance = LayananPelindungLayar._();

  static const MethodChannel _saluran = MethodChannel('bakudapa/keamanan');

  bool _aktif = false;

  Future<void> aktifkan() async {
    if (kDebugMode || _aktif || !Platform.isAndroid) return;
    _aktif = true;
    try {
      await _saluran.invokeMethod('amankanLayarOn');
    } catch (_) {}
  }

  Future<void> nonaktifkan() async {
    if (kDebugMode || !_aktif || !Platform.isAndroid) return;
    _aktif = false;
    try {
      await _saluran.invokeMethod('amankanLayarOff');
    } catch (_) {}
  }
}
