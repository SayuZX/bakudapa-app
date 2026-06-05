import 'dart:async';

import 'package:dio/dio.dart';

import '../network/klien_jaringan.dart';
import 'model_konfigurasi_sistem.dart';

class LayananKonfigurasiSistem {
  LayananKonfigurasiSistem._();
  static final LayananKonfigurasiSistem instance = LayananKonfigurasiSistem._();

  static const String _endpoint = '/sistem/konfigurasi';
  static const Duration _ttl = Duration(minutes: 30);

  KonfigurasiSistem _terakhir = KonfigurasiSistem.bawaan;
  DateTime? _diambilPada;
  Future<KonfigurasiSistem>? _permintaanAktif;

  KonfigurasiSistem get terakhir => _terakhir;

  Future<KonfigurasiSistem> ambil({bool paksaUlang = false}) async {
    if (!paksaUlang) {
      final aktif = _permintaanAktif;
      if (aktif != null) return aktif;
      final dapat = _diambilPada;
      if (dapat != null && DateTime.now().difference(dapat) < _ttl) {
        return _terakhir;
      }
    }
    final tugas = _muatDariServer();
    _permintaanAktif = tugas;
    try {
      return await tugas;
    } finally {
      _permintaanAktif = null;
    }
  }

  Future<KonfigurasiSistem> _muatDariServer() async {
    try {
      final r = await KlienJaringan.instance.dio.get(
        _endpoint,
        options: Options(
          sendTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
          extra: const {'anonim': true},
        ),
      );
      if (r.data is Map<String, dynamic>) {
        _terakhir = KonfigurasiSistem.dariJson(
          r.data as Map<String, dynamic>,
        );
        _diambilPada = DateTime.now();
      }
    } catch (_) {}
    return _terakhir;
  }
}
