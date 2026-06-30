import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bakudapa_mobile/core/config/storage_keys.dart';
import 'package:bakudapa_mobile/core/security/penyedia_kunci_blob.dart';
import 'package:bakudapa_mobile/core/services/penyimpanan_aman.dart';

class PenyimpananMemori extends FlutterSecureStorage {
  final Map<String, String> _data = {};

  String? data(String k) => _data[k];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _data[key];
}

void main() {
  final kunci = List<int>.generate(32, (i) => i + 1);

  PenyimpananAman buat(PenyimpananMemori mem, PenyediaKunciBlob p) =>
      PenyimpananAman.uji(penyimpanan: mem, penyediaKunci: p);

  test('token sensitif tersimpan tersampul, terbaca jelas', () async {
    final mem = PenyimpananMemori();
    final pa = buat(mem, KunciBlobTetap(kunci));
    await pa.tulis(StorageKeys.accessToken, 'AKSES-123');
    expect(mem.data(StorageKeys.accessToken)!.startsWith('v1:'), isTrue);
    expect(await pa.baca(StorageKeys.accessToken), 'AKSES-123');
  });

  test('key non-sensitif tetap plaintext', () async {
    final mem = PenyimpananMemori();
    final pa = buat(mem, KunciBlobTetap(kunci));
    await pa.tulis(StorageKeys.bahasaPilihan, 'id');
    expect(mem.data(StorageKeys.bahasaPilihan), 'id');
  });

  test('legacy plaintext token terbaca apa adanya', () async {
    final mem = PenyimpananMemori();
    await mem.write(key: StorageKeys.accessToken, value: 'LAMA-PLAIN');
    final pa = buat(mem, KunciBlobTetap(kunci));
    expect(await pa.baca(StorageKeys.accessToken), 'LAMA-PLAIN');
  });

  test('kunci identitas beda (tamper) => token tak terbaca (null)', () async {
    final mem = PenyimpananMemori();
    final pa = buat(mem, KunciBlobTetap(kunci));
    await pa.tulis(StorageKeys.accessToken, 'AKSES-123');
    final paTamper = buat(mem, KunciBlobTetap(List<int>.generate(32, (i) => i + 99)));
    expect(await paTamper.baca(StorageKeys.accessToken), isNull);
  });

  test('provider tanpa kunci (debug) => token plaintext', () async {
    final mem = PenyimpananMemori();
    final pa = buat(mem, KunciBlobTetap(null));
    await pa.tulis(StorageKeys.accessToken, 'AKSES-123');
    expect(mem.data(StorageKeys.accessToken), 'AKSES-123');
    expect(await pa.baca(StorageKeys.accessToken), 'AKSES-123');
  });
}
