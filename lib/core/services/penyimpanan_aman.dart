import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/storage_keys.dart';
import '../errors/kesalahan.dart';
import '../security/penyedia_kunci_blob.dart';
import '../security/sampul_blob.dart';

class PenyimpananAman {
  PenyimpananAman._()
      : _penyimpanan = const FlutterSecureStorage(aOptions: _android, iOptions: _ios),
        _penyediaKunci = KunciBlobNative.instance,
        _kunciSensitif = kunciSensitifBaku;

  PenyimpananAman.uji({
    required this._penyimpanan,
    required this._penyediaKunci,
    Set<String>? kunciSensitif,
  }) : _kunciSensitif = kunciSensitif ?? kunciSensitifBaku;

  static final PenyimpananAman instance = PenyimpananAman._();

  static const Set<String> kunciSensitifBaku = {
    StorageKeys.accessToken,
    StorageKeys.refreshToken,
    StorageKeys.tokenRegistrasi,
  };

  static const AndroidOptions _android =
      AndroidOptions(encryptedSharedPreferences: true, resetOnError: true);
  static const IOSOptions _ios =
      IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device);

  final FlutterSecureStorage _penyimpanan;
  final PenyediaKunciBlob _penyediaKunci;
  final Set<String> _kunciSensitif;

  Future<void> tulis(String kunci, String? nilai) async {
    try {
      if (nilai == null) {
        await _penyimpanan.delete(key: kunci);
        return;
      }
      var simpan = nilai;
      if (_kunciSensitif.contains(kunci)) {
        final k = await _penyediaKunci.kunci();
        if (k != null) simpan = SampulBlob.enkrip(nilai, k);
      }
      await _penyimpanan.write(key: kunci, value: simpan);
    } catch (_) {
      throw const KesalahanSimpanan();
    }
  }

  Future<String?> baca(String kunci) async {
    try {
      final mentah = await _penyimpanan.read(key: kunci);
      if (mentah == null) return null;
      if (!SampulBlob.apakahTersampul(mentah)) return mentah;
      final k = await _penyediaKunci.kunci();
      if (k == null) return null;
      return SampulBlob.dekrip(mentah, k);
    } catch (_) {
      return null;
    }
  }

  Future<void> hapus(String kunci) async {
    try {
      await _penyimpanan.delete(key: kunci);
    } catch (_) {}
  }

  Future<void> hapusSemua() async {
    try {
      await _penyimpanan.deleteAll();
    } catch (_) {}
  }

  Future<bool> berisi(String kunci) async {
    try {
      return await _penyimpanan.containsKey(key: kunci);
    } catch (_) {
      return false;
    }
  }
}
