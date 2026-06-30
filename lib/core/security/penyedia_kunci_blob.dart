import 'dart:io';

import 'package:flutter/services.dart';

abstract class PenyediaKunciBlob {
  Future<List<int>?> kunci();
}

List<int>? heksKeBita(String heks) {
  if (heks.length != 64) return null;
  final keluar = <int>[];
  for (var i = 0; i < heks.length; i += 2) {
    final b = int.tryParse(heks.substring(i, i + 2), radix: 16);
    if (b == null) return null;
    keluar.add(b);
  }
  return keluar;
}

class KunciBlobTetap implements PenyediaKunciBlob {
  KunciBlobTetap(this._kunci);
  final List<int>? _kunci;

  @override
  Future<List<int>?> kunci() async => _kunci;
}

class KunciBlobNative implements PenyediaKunciBlob {
  KunciBlobNative._();
  static final KunciBlobNative instance = KunciBlobNative._();

  static const MethodChannel _saluran = MethodChannel('bakudapa/keamanan');

  List<int>? _cache;
  bool _sudahCoba = false;

  @override
  Future<List<int>?> kunci() async {
    if (_sudahCoba) return _cache;
    _sudahCoba = true;
    if (!Platform.isAndroid) return _cache;
    try {
      final heks = await _saluran.invokeMethod<String>('kunciBlob');
      if (heks == null) return _cache;
      _cache = heksKeBita(heks.trim().toLowerCase());
    } on MissingPluginException {
      _cache = null;
    } catch (_) {
      _cache = null;
    }
    return _cache;
  }
}
