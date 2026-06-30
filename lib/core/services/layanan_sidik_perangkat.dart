import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../config/storage_keys.dart';
import 'penyimpanan_aman.dart';

class IdentitasPerangkat {
  const IdentitasPerangkat({
    required this.sidikJari,
    required this.model,
    required this.os,
    required this.versiAplikasi,
  });

  final String sidikJari;
  final String model;
  final String os;
  final String versiAplikasi;

  Map<String, dynamic> keJsonLogin() => {
    'sidik_perangkat': sidikJari,
    'device_fingerprint': sidikJari,
    if (model.isNotEmpty) 'model_perangkat': model,
    if (os.isNotEmpty) 'os_perangkat': os,
    if (versiAplikasi.isNotEmpty) 'versi_aplikasi': versiAplikasi,
  };

  Map<String, dynamic> keBlokPerangkat() => {
    'device_fingerprint': sidikJari,
    if (model.isNotEmpty) 'model': model,
    if (os.isNotEmpty) 'os': os,
    if (versiAplikasi.isNotEmpty) 'app_version': versiAplikasi,
  };
}

class LayananSidikPerangkat {
  LayananSidikPerangkat._({PenyimpananAman? penyimpanan})
    : _penyimpanan = penyimpanan ?? PenyimpananAman.instance;

  static final LayananSidikPerangkat instance = LayananSidikPerangkat._();

  final PenyimpananAman _penyimpanan;
  IdentitasPerangkat? _cache;
  String? _sidikCache;

  Future<String> sidikJari() async {
    final cache = _sidikCache;
    if (cache != null && cache.isNotEmpty) return cache;

    var nilai = await _penyimpanan.baca(StorageKeys.sidikJariPerangkat);
    nilai = (nilai != null && nilai.isNotEmpty) ? nilai : await _bacaCadangan();
    nilai = (nilai != null && nilai.isNotEmpty) ? nilai : await _turunkan();

    await _simpan(nilai);
    _sidikCache = nilai;
    return nilai;
  }

  Future<String> _turunkan() async {
    final dasar = await _idStabil();
    if (dasar != null && dasar.isNotEmpty) {
      return sha256.convert(utf8.encode('bakudapa:$dasar')).toString();
    }
    return const Uuid().v4();
  }

  Future<String?> _idStabil() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        return [
          a.brand,
          a.manufacturer,
          a.device,
          a.model,
          a.hardware,
          a.board,
          a.product,
        ].where((e) => e.isNotEmpty).join('|');
      }
      if (Platform.isIOS) {
        final i = await info.iosInfo;
        return i.identifierForVendor ??
            '${i.name}|${i.model}|${i.utsname.machine}';
      }
    } catch (_) {}
    return null;
  }

  Future<void> _simpan(String nilai) async {
    await _penyimpanan.tulis(StorageKeys.sidikJariPerangkat, nilai);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.sidikJariPerangkat, nilai);
    } catch (_) {}
  }

  Future<String?> _bacaCadangan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(StorageKeys.sidikJariPerangkat);
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {}
    return null;
  }

  Future<IdentitasPerangkat> identitas() async {
    final tersimpan = _cache;
    if (tersimpan != null) return tersimpan;

    final sidik = await sidikJari();
    var model = '';
    var os = '';
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        model = '${a.manufacturer} ${a.model}'.trim();
        os = 'Android ${a.version.release}';
      } else if (Platform.isIOS) {
        final i = await info.iosInfo;
        model = i.utsname.machine;
        os = '${i.systemName} ${i.systemVersion}';
      }
    } catch (_) {}

    var versi = '';
    try {
      final paket = await PackageInfo.fromPlatform();
      versi = paket.version;
    } catch (_) {}

    final hasil = IdentitasPerangkat(
      sidikJari: sidik,
      model: model,
      os: os,
      versiAplikasi: versi,
    );
    _cache = hasil;
    return hasil;
  }
}
