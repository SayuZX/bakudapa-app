import 'dart:async';

import 'package:geolocator/geolocator.dart';

class JejakLokasi {
  const JejakLokasi({
    required this.lintang,
    required this.bujur,
    required this.akurasi,
    required this.diambilPada,
  });

  final double lintang;
  final double bujur;
  final double akurasi;
  final DateTime diambilPada;

  Map<String, Object?> toMetadata() => {
        'lat': lintang,
        'lng': bujur,
        'acc': akurasi,
        'at': diambilPada.toIso8601String(),
      };
}

enum HasilIzinLokasi { diberikan, ditolak, ditolakPermanen, layananMati }

class LayananJejakLokasi {
  LayananJejakLokasi._();
  static final LayananJejakLokasi instance = LayananJejakLokasi._();

  static const Duration _batasWaktu = Duration(seconds: 10);

  JejakLokasi? _jejakTerakhir;
  JejakLokasi? get jejakTerakhir => _jejakTerakhir;

  Future<HasilIzinLokasi> mintaIzinJikaPerlu() async {
    final layanan = await Geolocator.isLocationServiceEnabled();
    if (!layanan) return HasilIzinLokasi.layananMati;

    var izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
    }
    if (izin == LocationPermission.deniedForever) {
      return HasilIzinLokasi.ditolakPermanen;
    }
    if (izin == LocationPermission.denied) {
      return HasilIzinLokasi.ditolak;
    }
    return HasilIzinLokasi.diberikan;
  }

  Future<JejakLokasi?> rekamSekali() async {
    try {
      final hasil = await mintaIzinJikaPerlu();
      if (hasil != HasilIzinLokasi.diberikan) return null;

      final posisi = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(_batasWaktu);

      final jejak = JejakLokasi(
        lintang: posisi.latitude,
        bujur: posisi.longitude,
        akurasi: posisi.accuracy,
        diambilPada: DateTime.now(),
      );
      _jejakTerakhir = jejak;
      return jejak;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> bukaPengaturanLokasi() => Geolocator.openLocationSettings();
  Future<bool> bukaPengaturanAplikasi() => Geolocator.openAppSettings();

  void bersihkan() {
    _jejakTerakhir = null;
  }
}
