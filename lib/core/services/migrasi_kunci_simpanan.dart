import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/storage_keys.dart';

class MigrasiKunciSimpanan {
  MigrasiKunciSimpanan._();

  static const _secure = FlutterSecureStorage();

  static const _petaSecure = <String, String>{
    'sk_token_akses': StorageKeys.accessToken,
    'sk_token_segar': StorageKeys.refreshToken,
    'sk_kedaluwarsa': StorageKeys.kedaluwarsa,
    'sk_id_pengguna': StorageKeys.userId,
    'sk_profil_pengguna': StorageKeys.profilPengguna,
    'sk_sidik_perangkat': StorageKeys.sidikJariPerangkat,
  };

  static const _petaPrefs = <String, String>{
    'pref_onboarding': StorageKeys.onboardingTerlihat,
    'pref_biometrik': StorageKeys.biometrikAktif,
    'pref_notifikasi': StorageKeys.notifikasiAktif,
    'pref_bahasa': StorageKeys.bahasaPilihan,
    'pref_sinkron_terakhir': StorageKeys.terakhirSinkron,
    'pref_panduan': StorageKeys.panduanTerlihat,
  };

  static Future<void> jalankan() async {
    await _migrasiSecure();
    await _migrasiPrefs();
  }

  static Future<void> _migrasiSecure() async {
    for (final entry in _petaSecure.entries) {
      try {
        final nilaiLama = await _secure.read(key: entry.key);
        if (nilaiLama == null || nilaiLama.isEmpty) continue;
        final nilaiBaru = await _secure.read(key: entry.value);
        if (nilaiBaru == null || nilaiBaru.isEmpty) {
          await _secure.write(key: entry.value, value: nilaiLama);
        }
        await _secure.delete(key: entry.key);
      } catch (_) {}
    }
  }

  static Future<void> _migrasiPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in _petaPrefs.entries) {
        if (!prefs.containsKey(entry.key)) continue;
        if (prefs.containsKey(entry.value)) {
          await prefs.remove(entry.key);
          continue;
        }
        final v = prefs.get(entry.key);
        if (v is String) {
          await prefs.setString(entry.value, v);
        } else if (v is bool) {
          await prefs.setBool(entry.value, v);
        } else if (v is int) {
          await prefs.setInt(entry.value, v);
        } else if (v is double) {
          await prefs.setDouble(entry.value, v);
        } else if (v is List<String>) {
          await prefs.setStringList(entry.value, v);
        }
        await prefs.remove(entry.key);
      }
    } catch (_) {}
  }
}
