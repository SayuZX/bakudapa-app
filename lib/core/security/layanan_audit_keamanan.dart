import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/endpoints.dart';
import '../enums/peristiwa_audit.dart';
import '../network/klien_jaringan.dart';
import '../services/layanan_sidik_perangkat.dart';

class LayananAuditKeamanan {
  LayananAuditKeamanan._();
  static final LayananAuditKeamanan instance = LayananAuditKeamanan._();

  static const String _kunciAntrean = 'antrean_audit_keamanan';
  static const int _batasAntrean = 100;
  static const Duration _batasWaktu = Duration(seconds: 5);

  StreamSubscription<List<ConnectivityResult>>? _langgananKonektivitas;
  bool _sedangFlush = false;

  void mulaiPemantauanKonektivitas() {
    _langgananKonektivitas ??= Connectivity().onConnectivityChanged.listen((
      hasil,
    ) {
      final adaKoneksi = hasil.any((r) => r != ConnectivityResult.none);
      if (adaKoneksi) {
        unawaited(flushAntrean());
      }
    });
  }

  Future<void> catat({
    required PeristiwaAudit peristiwa,
    TingkatAudit tingkat = TingkatAudit.info,
    Map<String, dynamic>? metadata,
  }) async {
    final muatan = await _bangunMuatan(
      peristiwa: peristiwa,
      tingkat: tingkat,
      metadata: metadata,
    );
    final terkirim = await _kirim(muatan);
    if (!terkirim) {
      await _antrekan(muatan);
    }
  }

  Future<void> flushAntrean() async {
    if (_sedangFlush) return;
    _sedangFlush = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final antrean = prefs.getStringList(_kunciAntrean) ?? const [];
      if (antrean.isEmpty) return;

      final tersisa = <String>[];
      for (final baris in antrean) {
        final muatan = _uraikan(baris);
        if (muatan == null) continue;
        final terkirim = await _kirim(muatan);
        if (!terkirim) tersisa.add(baris);
      }

      if (tersisa.isEmpty) {
        await prefs.remove(_kunciAntrean);
      } else {
        await prefs.setStringList(_kunciAntrean, tersisa);
      }
    } finally {
      _sedangFlush = false;
    }
  }

  Future<Map<String, dynamic>> _bangunMuatan({
    required PeristiwaAudit peristiwa,
    required TingkatAudit tingkat,
    Map<String, dynamic>? metadata,
  }) async {
    String? sidik;
    try {
      sidik = await LayananSidikPerangkat.instance.sidikJari();
    } catch (_) {}
    return {
      'peristiwa': peristiwa.value,
      'tingkat': tingkat.value,
      'device_fingerprint': ?sidik,
      if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
    };
  }

  Future<bool> _kirim(Map<String, dynamic> muatan) async {
    try {
      await KlienJaringan.instance.dio.post(
        Endpoints.biometrikAudit,
        data: muatan,
        options: Options(
          sendTimeout: _batasWaktu,
          receiveTimeout: _batasWaktu,
          extra: const {'anonim': true},
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _antrekan(Map<String, dynamic> muatan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final antrean = List<String>.from(
        prefs.getStringList(_kunciAntrean) ?? const [],
      );
      antrean.add(jsonEncode(muatan));
      if (antrean.length > _batasAntrean) {
        antrean.removeRange(0, antrean.length - _batasAntrean);
      }
      await prefs.setStringList(_kunciAntrean, antrean);
    } catch (_) {}
  }

  Map<String, dynamic>? _uraikan(String baris) {
    try {
      final hasil = jsonDecode(baris);
      return hasil is Map<String, dynamic> ? hasil : null;
    } catch (_) {
      return null;
    }
  }
}
