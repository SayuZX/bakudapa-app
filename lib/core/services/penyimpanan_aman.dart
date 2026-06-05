import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/kesalahan.dart';

class PenyimpananAman {
  PenyimpananAman._();
  static final PenyimpananAman instance = PenyimpananAman._();

  static const AndroidOptions _android = AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  );

  static const IOSOptions _ios = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  final FlutterSecureStorage _penyimpanan = const FlutterSecureStorage(
    aOptions: _android,
    iOptions: _ios,
  );

  Future<void> tulis(String kunci, String? nilai) async {
    try {
      if (nilai == null) {
        await _penyimpanan.delete(key: kunci);
      } else {
        await _penyimpanan.write(key: kunci, value: nilai);
      }
    } catch (_) {
      throw const KesalahanSimpanan();
    }
  }

  Future<String?> baca(String kunci) async {
    try {
      return await _penyimpanan.read(key: kunci);
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
