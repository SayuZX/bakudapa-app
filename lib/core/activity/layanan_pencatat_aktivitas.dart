import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/endpoints.dart';
import '../config/storage_keys.dart';
import '../location/layanan_jejak_lokasi.dart';
import '../network/klien_jaringan.dart';
import '../services/layanan_sidik_perangkat.dart';
import 'jenis_aktivitas.dart';

class LayananPencatatAktivitas {
  LayananPencatatAktivitas._();
  static final LayananPencatatAktivitas instance = LayananPencatatAktivitas._();

  static final bool _diUji = Platform.environment.containsKey('FLUTTER_TEST');

  static const int _ambangFlush = 10;
  static const int _maksAntre = 200;
  static const int _maksPerKirim = 50;
  static const int _maksKunci = 30;
  static const int _maksPanjangTeks = 500;
  static const Duration _selangFlush = Duration(seconds: 30);

  static final RegExp _polaNik = RegExp(r'\b\d{16}\b');
  static final RegExp _polaEmail = RegExp(r'\b[\w.+-]+@[\w-]+\.[\w.-]+\b');
  static final RegExp _polaHp = RegExp(r'\b(?:\+?62|0)8\d{7,12}\b');
  static const Set<String> _kunciDilarang = {
    'password', 'kata_sandi', 'sandi', 'passwd',
    'otp', 'pin', 'token', 'secret', 'authorization', 'auth',
    'biometri', 'biometric', 'wajah', 'face', 'sidik_jari', 'fingerprint',
    'nik', 'email', 'no_hp', 'nohp', 'telepon', 'telpon', 'phone',
  };

  final List<Map<String, dynamic>> _antre = [];
  Timer? _timer;
  bool _mengirim = false;
  bool _lokasiDiizinkan = false;
  bool _dimuat = false;
  Map<String, dynamic>? _perangkat;

  bool get izinLokasi => _lokasiDiizinkan;

  Future<bool> bacaIzinLokasi() async {
    await _muatJikaPerlu();
    return _lokasiDiizinkan;
  }

  Future<void> aturIzinLokasi(bool izin) async {
    _lokasiDiizinkan = izin;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.aktivitasLokasiIzin, izin);
    } catch (_) {}
  }

  Future<void> catat(
    JenisAktivitas jenis, {
    String? layar,
    Map<String, dynamic>? metadata,
    bool sertakanLokasi = false,
  }) async {
    await _muatJikaPerlu();

    final peristiwa = <String, dynamic>{
      'jenis': jenis.kode,
      'waktu_klien': DateTime.now().toUtc().toIso8601String(),
      if (layar != null && layar.isNotEmpty) 'layar': _potong(layar, 120),
    };
    if (metadata != null && metadata.isNotEmpty) {
      final bersih = _bersihkan(metadata, 0);
      if (bersih is Map && bersih.isNotEmpty) peristiwa['metadata'] = bersih;
    }

    if (sertakanLokasi && _lokasiDiizinkan) {
      final lokasi = await _ambilLokasi();
      if (lokasi != null) peristiwa['lokasi'] = lokasi;
    }

    _antre.add(peristiwa);
    if (_antre.length > _maksAntre) {
      _antre.removeRange(0, _antre.length - _maksAntre);
    }
    await _simpanAntre();

    if (_antre.length >= _ambangFlush) {
      unawaited(flush());
    } else {
      _jadwalkanFlush();
    }
  }

  Future<void> flush() async {
    if (_diUji) return;
    await _muatJikaPerlu();
    if (_mengirim || _antre.isEmpty) return;

    _mengirim = true;
    _timer?.cancel();
    _timer = null;

    final batch = _antre.take(_maksPerKirim).toList(growable: false);
    try {
      await KlienJaringan.instance.dio.post(
        Endpoints.aktivitasLog,
        data: {
          'perangkat': await _infoPerangkat(),
          'peristiwa': batch,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      _antre.removeRange(0, batch.length);
      await _simpanAntre();
    } catch (_) {
      // gagal kirim: biarkan di antre untuk percobaan berikutnya
    } finally {
      _mengirim = false;
      if (_antre.isNotEmpty) _jadwalkanFlush();
    }
  }

  void _jadwalkanFlush() {
    if (_diUji) return;
    _timer ??= Timer(_selangFlush, () {
      _timer = null;
      unawaited(flush());
    });
  }

  Future<void> _muatJikaPerlu() async {
    if (_dimuat) return;
    _dimuat = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _lokasiDiizinkan = prefs.getBool(StorageKeys.aktivitasLokasiIzin) ?? false;
      final mentah = prefs.getString(StorageKeys.aktivitasAntre);
      if (mentah != null && mentah.isNotEmpty) {
        final data = jsonDecode(mentah);
        if (data is List) {
          _antre
            ..clear()
            ..addAll(data.whereType<Map>().map(Map<String, dynamic>.from));
        }
      }
    } catch (_) {
      _antre.clear();
    }
  }

  Future<void> _simpanAntre() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.aktivitasAntre, jsonEncode(_antre));
    } catch (_) {}
  }

  Future<Map<String, dynamic>> _infoPerangkat() async {
    final tersimpan = _perangkat;
    if (tersimpan != null) return tersimpan;

    final hasil = <String, dynamic>{};
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        hasil['model'] = _potong('${a.manufacturer} ${a.model}'.trim(), 120);
        hasil['os'] = _potong('Android ${a.version.release} (SDK ${a.version.sdkInt})', 120);
      } else if (Platform.isIOS) {
        final i = await info.iosInfo;
        hasil['model'] = _potong(i.utsname.machine, 120);
        hasil['os'] = _potong('${i.systemName} ${i.systemVersion}', 120);
      }
    } catch (_) {}

    try {
      final paket = await PackageInfo.fromPlatform();
      hasil['app_version'] = _potong('${paket.version}+${paket.buildNumber}', 40);
    } catch (_) {}

    hasil['device_fingerprint'] = await _idPerangkat();
    hasil.removeWhere((_, v) => v == null || (v is String && v.isEmpty));

    _perangkat = hasil;
    return hasil;
  }

  Future<String> _idPerangkat() async {
    return LayananSidikPerangkat.instance.sidikJari();
  }

  Future<Map<String, dynamic>?> _ambilLokasi() async {
    final jejak = await LayananJejakLokasi.instance.rekamSekali();
    if (jejak == null) return null;
    return {
      'lat': jejak.lintang,
      'lon': jejak.bujur,
      'akurasi': jejak.akurasi,
    };
  }

  Object? _bersihkan(Object? nilai, int kedalaman) {
    if (kedalaman > 5) return null;
    if (nilai is Map) {
      final keluar = <String, dynamic>{};
      for (final entri in nilai.entries.take(_maksKunci)) {
        final kunci = entri.key.toString();
        final kl = kunci.toLowerCase();
        if (_kunciDilarang.any(kl.contains)) continue;
        final bersih = _bersihkan(entri.value, kedalaman + 1);
        if (bersih != null) keluar[kunci] = bersih;
      }
      return keluar;
    }
    if (nilai is List) {
      return nilai
          .take(_maksKunci)
          .map((e) => _bersihkan(e, kedalaman + 1))
          .where((e) => e != null)
          .toList();
    }
    if (nilai is num || nilai is bool) return nilai;
    if (nilai is String) return _samarkanTeks(nilai);
    if (nilai == null) return null;
    return _samarkanTeks(nilai.toString());
  }

  String _samarkanTeks(String teks) {
    var hasil = _potong(teks, _maksPanjangTeks);
    hasil = hasil.replaceAllMapped(_polaEmail, (m) => _samarEmail(m.group(0)!));
    hasil = hasil.replaceAllMapped(_polaNik, (m) => _samarTengah(m.group(0)!));
    hasil = hasil.replaceAllMapped(_polaHp, (m) => _samarTengah(m.group(0)!));
    return hasil;
  }

  String _samarTengah(String nilai) {
    if (nilai.length < 6) return nilai;
    return '${nilai.substring(0, 4)}${'*' * (nilai.length - 6)}${nilai.substring(nilai.length - 2)}';
  }

  String _samarEmail(String nilai) {
    final bagian = nilai.split('@');
    if (bagian.length != 2) return nilai;
    final lokal = bagian[0];
    final tampil = lokal.length <= 2 ? lokal.substring(0, 1) : lokal.substring(0, 2);
    final bintang = '*' * (lokal.length - tampil.length).clamp(3, 64);
    return '$tampil$bintang@${bagian[1]}';
  }

  String _potong(String teks, int maks) =>
      teks.length <= maks ? teks : teks.substring(0, maks);
}
