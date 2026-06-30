# Watermark Provenance Native Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tanam watermark kepemilikan yang ter-*entangle* dengan logika nyata: identitas HAKI → seed di immediate Assembly (3 ABI, redundan) → keystream native → kunci enkripsi token at-rest, sehingga rebrand kepemilikan memecahkan app (cost-raising) dan sisa fragmen jadi bukti turunan (forensik).

**Architecture:** Kebenaran kriptografi ada di Dart (`SampulBlob` encrypt-then-MAC, fully unit-tested dengan kunci di-inject). Native (C++/asm) hanya menyuplai kunci 32-byte = `blobKey(keystream(seed))`. Seed dirakit ulang dari fragmen immediate Assembly lalu di-cross-check terhadap SHA-256 string identitas ter-obfuscate. `PenyimpananAman` mengenkripsi hanya key sensitif (token) secara transparan; nilai tanpa sampul diperlakukan legacy plaintext (migrasi mulus).

**Tech Stack:** Flutter/Dart (`crypto: ^3.0.3`, `dart:convert`), Android NDK (C++17, CMake 3.22), Assembly AArch64/ARMv7/x86-64, Kotlin JNI + MethodChannel.

## Global Constraints

- Package id: `org.gatechstudio.malutprovkab`.
- Decoy publik: `PEMEGANG_HAKI="GATECH"` di BuildConfig + manifest meta-data (bukan sumber seed).
- Seed identitas: `seed = SHA256(bukaSandi())` di mana `bukaSandi()` mendeobfuscate string kepemilikan (`SANDI ⊕ KUNCI`) di dalam `.so`; nama asli TIDAK pernah plaintext. Hasil = `SIDIK_KEPEMILIKAN` (`dfac89fc…381f1`).
- Tidak ada komentar pada kode (preferensi user: self-documenting, zero comments) — KECUALI file `.S` yang sudah berkomentar mengikuti pola existing; ikuti gaya file yang disentuh.
- ABI didukung: `armeabi-v7a`, `arm64-v8a`, `x86_64` (dari `android/app/build.gradle.kts:64`).
- Native channel: `bakudapa/keamanan` (existing, `MainActivity.kt:10`).
- Channel methods Dart memakai Bahasa Indonesia (pola existing: `atestasiKepemilikan`, `watermarkUtuh`).
- Flutter SDK di `E:\flutter` (tidak di PATH) — pakai `E:\flutter\bin\flutter` bila `flutter` tak dikenal.
- `crypto: ^3.0.3` sudah ada di `pubspec.yaml:29` — TIDAK menambah dependency baru.
- Envelope versi: prefix literal `v1:` + base64(`nonce(12) || ciphertext || mac(32)`).
- Key sensitif yang dienkripsi: `StorageKeys.accessToken`, `StorageKeys.refreshToken`, `StorageKeys.tokenRegistrasi`. Selain itu plaintext.
- Folder `tools/forensik/` WAJIB di-gitignore dan TIDAK boleh masuk APK.

---

### Task 1: `SampulBlob` — envelope kripto encrypt-then-MAC (pure Dart)

Inti kebenaran. Tak butuh native; sepenuhnya unit-testable.

**Files:**
- Create: `lib/core/security/sampul_blob.dart`
- Test: `test/core/security/sampul_blob_test.dart`

**Interfaces:**
- Consumes: `package:crypto` (`Hmac`, `sha256`), `dart:convert` (`base64`, `utf8`).
- Produces:
  - `class SampulBlob`
  - `static const String SampulBlob.prefiks = 'v1:'`
  - `static bool SampulBlob.apakahTersampul(String nilai)` — true bila `nilai` diawali `v1:`.
  - `static String SampulBlob.enkrip(String teksBiasa, List<int> kunci, {List<int>? nonce})` — kunci 32-byte; `nonce` opsional (default 12 byte acak) hanya untuk test determinisme; balikan `'v1:' + base64(...)`.
  - `static String? SampulBlob.dekrip(String sampul, List<int> kunci)` — balikan `null` bila bukan tersampul, panjang invalid, atau MAC gagal.

- [ ] **Step 1: Write the failing test**

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:bakudapa/core/security/sampul_blob.dart';

void main() {
  final kunci = List<int>.generate(32, (i) => i + 1);
  final nonce = List<int>.generate(12, (i) => 100 + i);

  test('round-trip mengembalikan teks asli', () {
    final sampul = SampulBlob.enkrip('token-rahasia-123', kunci, nonce: nonce);
    expect(SampulBlob.apakahTersampul(sampul), isTrue);
    expect(sampul.startsWith('v1:'), isTrue);
    expect(SampulBlob.dekrip(sampul, kunci), 'token-rahasia-123');
  });

  test('ciphertext bukan plaintext', () {
    final sampul = SampulBlob.enkrip('AAAAAAAAAA', kunci, nonce: nonce);
    expect(sampul.contains('AAAAAAAAAA'), isFalse);
  });

  test('kunci salah => dekrip null (MAC gagal)', () {
    final sampul = SampulBlob.enkrip('token', kunci, nonce: nonce);
    final kunciLain = List<int>.generate(32, (i) => i + 9);
    expect(SampulBlob.dekrip(sampul, kunciLain), isNull);
  });

  test('ciphertext diutak-atik => dekrip null', () {
    final sampul = SampulBlob.enkrip('token', kunci, nonce: nonce);
    final mentah = base64.decode(sampul.substring(3));
    mentah[13] ^= 0xFF;
    final rusak = 'v1:${base64.encode(mentah)}';
    expect(SampulBlob.dekrip(rusak, kunci), isNull);
  });

  test('nilai non-sampul => apakahTersampul false & dekrip null', () {
    expect(SampulBlob.apakahTersampul('plaintext-lama'), isFalse);
    expect(SampulBlob.dekrip('plaintext-lama', kunci), isNull);
  });

  test('nonce acak => dua enkripsi berbeda', () {
    final a = SampulBlob.enkrip('sama', kunci);
    final b = SampulBlob.enkrip('sama', kunci);
    expect(a == b, isFalse);
    expect(SampulBlob.dekrip(a, kunci), 'sama');
    expect(SampulBlob.dekrip(b, kunci), 'sama');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `E:\flutter\bin\flutter test test/core/security/sampul_blob_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../sampul_blob.dart'`.

- [ ] **Step 3: Write minimal implementation**

```dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class SampulBlob {
  SampulBlob._();

  static const String prefiks = 'v1:';
  static const int _panjangNonce = 12;
  static const int _panjangMac = 32;

  static final Random _acak = Random.secure();

  static bool apakahTersampul(String nilai) => nilai.startsWith(prefiks);

  static String enkrip(String teksBiasa, List<int> kunci, {List<int>? nonce}) {
    final n = nonce ?? List<int>.generate(_panjangNonce, (_) => _acak.nextInt(256));
    final teks = utf8.encode(teksBiasa);
    final ks = _aliranKunci(kunci, n, teks.length);
    final sandi = Uint8List(teks.length);
    for (var i = 0; i < teks.length; i++) {
      sandi[i] = teks[i] ^ ks[i];
    }
    final mac = _mac(kunci, n, sandi);
    final muatan = <int>[...n, ...sandi, ...mac];
    return prefiks + base64.encode(muatan);
  }

  static String? dekrip(String sampul, List<int> kunci) {
    if (!apakahTersampul(sampul)) return null;
    List<int> mentah;
    try {
      mentah = base64.decode(sampul.substring(prefiks.length));
    } catch (_) {
      return null;
    }
    if (mentah.length < _panjangNonce + _panjangMac) return null;
    final n = mentah.sublist(0, _panjangNonce);
    final sandi = mentah.sublist(_panjangNonce, mentah.length - _panjangMac);
    final mac = mentah.sublist(mentah.length - _panjangMac);
    final macHarap = _mac(kunci, n, sandi);
    if (!_setaraWaktuTetap(mac, macHarap)) return null;
    final ks = _aliranKunci(kunci, n, sandi.length);
    final teks = Uint8List(sandi.length);
    for (var i = 0; i < sandi.length; i++) {
      teks[i] = sandi[i] ^ ks[i];
    }
    try {
      return utf8.decode(teks);
    } catch (_) {
      return null;
    }
  }

  static List<int> _aliranKunci(List<int> kunci, List<int> nonce, int panjang) {
    final hmac = Hmac(sha256, kunci);
    final keluar = <int>[];
    var penghitung = 0;
    while (keluar.length < panjang) {
      final blokInput = <int>[
        ...nonce,
        (penghitung >> 24) & 0xFF,
        (penghitung >> 16) & 0xFF,
        (penghitung >> 8) & 0xFF,
        penghitung & 0xFF,
      ];
      keluar.addAll(hmac.convert(blokInput).bytes);
      penghitung++;
    }
    return keluar.sublist(0, panjang);
  }

  static List<int> _mac(List<int> kunci, List<int> nonce, List<int> sandi) {
    final hmac = Hmac(sha256, kunci);
    return hmac.convert(<int>[...nonce, ...sandi]).bytes;
  }

  static bool _setaraWaktuTetap(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var beda = 0;
    for (var i = 0; i < a.length; i++) {
      beda |= a[i] ^ b[i];
    }
    return beda == 0;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `E:\flutter\bin\flutter test test/core/security/sampul_blob_test.dart`
Expected: PASS (6 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/security/sampul_blob.dart test/core/security/sampul_blob_test.dart
git commit -m "feat(security): SampulBlob encrypt-then-MAC envelope (v1)"
```

---

### Task 2: `PenyediaKunciBlob` — abstraksi kunci native + fake

Pisahkan sumber kunci dari konsumen agar `PenyimpananAman` unit-testable tanpa platform.

**Files:**
- Create: `lib/core/security/penyedia_kunci_blob.dart`
- Test: `test/core/security/penyedia_kunci_blob_test.dart`

**Interfaces:**
- Consumes: `package:flutter/services.dart` (`MethodChannel`), `dart:io` (`Platform`).
- Produces:
  - `abstract class PenyediaKunciBlob { Future<List<int>?> kunci(); }`
  - `class KunciBlobNative implements PenyediaKunciBlob` — baca channel `bakudapa/keamanan` method `kunciBlob` (hex 64 char) → 32 byte; `null` bila non-Android, hex invalid, atau `MissingPluginException`. Hasil di-cache memori.
  - `class KunciBlobTetap implements PenyediaKunciBlob` — balikan kunci konstan (untuk test/`null`).
  - `List<int>? heksKeBita(String heks)` (helper publik di file ini).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bakudapa/core/security/penyedia_kunci_blob.dart';

void main() {
  test('heksKeBita mengonversi 64 char ke 32 byte', () {
    final b = heksKeBita('00ff10' + '0' * 58);
    expect(b, isNotNull);
    expect(b!.length, 32);
    expect(b[0], 0x00);
    expect(b[1], 0xff);
    expect(b[2], 0x10);
  });

  test('heksKeBita panjang ganjil/invalid => null', () {
    expect(heksKeBita('abc'), isNull);
    expect(heksKeBita('zz' * 32), isNull);
  });

  test('KunciBlobTetap mengembalikan kunci sama', () async {
    final k = List<int>.generate(32, (i) => i);
    final p = KunciBlobTetap(k);
    expect(await p.kunci(), k);
  });

  test('KunciBlobTetap(null) => null', () async {
    expect(await KunciBlobTetap(null).kunci(), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `E:\flutter\bin\flutter test test/core/security/penyedia_kunci_blob_test.dart`
Expected: FAIL — file belum ada.

- [ ] **Step 3: Write minimal implementation**

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `E:\flutter\bin\flutter test test/core/security/penyedia_kunci_blob_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/security/penyedia_kunci_blob.dart test/core/security/penyedia_kunci_blob_test.dart
git commit -m "feat(security): PenyediaKunciBlob abstraksi kunci native + fake"
```

---

### Task 3: Integrasi entanglement ke `PenyimpananAman`

Enkripsi transparan key sensitif; legacy plaintext lewat tanpa rusak.

**Files:**
- Modify: `lib/core/services/penyimpanan_aman.dart`
- Test: `test/core/services/penyimpanan_aman_entangle_test.dart`

**Interfaces:**
- Consumes: `SampulBlob` (Task 1), `PenyediaKunciBlob`/`KunciBlobTetap`/`KunciBlobNative` (Task 2), `StorageKeys`.
- Produces:
  - `PenyimpananAman` baru menerima injeksi opsional: `PenyimpananAman.uji({required FlutterSecureStorage penyimpanan, required PenyediaKunciBlob penyediaKunci, Set<String>? kunciSensitif})` untuk test.
  - `static const Set<String> PenyimpananAman.kunciSensitifBaku = {StorageKeys.accessToken, StorageKeys.refreshToken, StorageKeys.tokenRegistrasi}`.
  - Perilaku: `tulis(kunci, nilai)` mengenkripsi bila `kunci` sensitif DAN provider memberi kunci 32-byte; `baca(kunci)` mendekripsi bila nilai tersampul (gagal MAC → `null`), mengembalikan apa adanya bila legacy plaintext.

**Catatan TDD:** `FlutterSecureStorage` butuh platform. Test memakai implementasi in-memory palsu via subclass tipis. Karena `PenyimpananAman` memanggil method instance `_penyimpanan`, refactor agar `_penyimpanan` di-inject.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bakudapa/core/config/storage_keys.dart';
import 'package:bakudapa/core/security/penyedia_kunci_blob.dart';
import 'package:bakudapa/core/services/penyimpanan_aman.dart';

class PenyimpananMemori extends FlutterSecureStorage {
  final Map<String, String> _data = {};
  @override
  Future<void> write({required String key, required String? value,
      AndroidOptions? aOptions, IOSOptions? iOptions, LinuxOptions? lOptions,
      WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    if (value == null) { _data.remove(key); } else { _data[key] = value; }
  }
  @override
  Future<String?> read({required String key, AndroidOptions? aOptions,
      IOSOptions? iOptions, LinuxOptions? lOptions, WebOptions? webOptions,
      MacOsOptions? mOptions, WindowsOptions? wOptions}) async => _data[key];
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

extension on PenyimpananMemori {
  String? data(String k) => _data[k];
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `E:\flutter\bin\flutter test test/core/services/penyimpanan_aman_entangle_test.dart`
Expected: FAIL — `PenyimpananAman.uji` belum ada.

- [ ] **Step 3: Write minimal implementation** (ganti isi `penyimpanan_aman.dart`)

```dart
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
    required FlutterSecureStorage penyimpanan,
    required PenyediaKunciBlob penyediaKunci,
    Set<String>? kunciSensitif,
  })  : _penyimpanan = penyimpanan,
        _penyediaKunci = penyediaKunci,
        _kunciSensitif = kunciSensitif ?? kunciSensitifBaku;

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
```

- [ ] **Step 4: Run tests to verify pass + no regression**

Run: `E:\flutter\bin\flutter test test/core/services/penyimpanan_aman_entangle_test.dart`
Expected: PASS (5 tests).

Run: `E:\flutter\bin\flutter analyze lib/core/services/penyimpanan_aman.dart`
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/penyimpanan_aman.dart test/core/services/penyimpanan_aman_entangle_test.dart
git commit -m "feat(security): entangle token at-rest dgn kunci kepemilikan native"
```

---

### Task 4: C++ core `seed_inti.h` — reassembly + keystream + blobKey (host-tested)

Logika murni C++ yang dipakai JNI dan diuji di host tanpa Android.

**Files:**
- Create: `android/app/src/main/cpp/seed_inti.h`
- Create: `tools/test_native/test_inti.cpp`
- Create: `tools/test_native/README.md`

**Interfaces:**
- Consumes: SHA-256 dari `kepemilikan.cpp` direfactor sebagai inline di `seed_inti.h` (pindahkan `struct Sha256` + `sidik()` ke header, namespace `kepem`).
- Produces (semua di namespace `kepem`, header-only inline):
  - `std::string sidikHeks(const uint8_t* data, size_t n)` — SHA-256 hex.
  - `void sidikBita(const uint8_t* data, size_t n, uint8_t keluar[32])` — SHA-256 raw 32 byte (untuk cross-check identitas vs seed-asm).
  - `bool setara(const uint8_t* a, const uint8_t* b, size_t n)` — banding waktu-tetap.
  - `struct Fragmen { uint64_t f[4]; }`.
  - `void rakitSeed(const Fragmen& utama, const Fragmen& cadangan, uint8_t seed[32], bool& konsisten)` — tulis 4×u64 big-endian ke `seed`; `konsisten=false` bila `utama.f[i] != cadangan.f[i]`.
  - `std::string keystreamHeks(const uint8_t seed[32])` = `sidikHeks(seed,32)` lalu `sidikHeks(prev||"ks")` 1 ronde tambahan.
  - `std::string blobKeyHeks(const uint8_t seed[32])` = `sidikHeks( keystreamBytes || "blob" )` → 64 hex char.

- [ ] **Step 1: Write the failing host test**

```cpp
#include <cstdio>
#include <cstring>
#include "../../android/app/src/main/cpp/seed_inti.h"

using namespace kepem;

static int gagal = 0;
static void cek(bool ok, const char* nama) {
  printf("%s: %s\n", ok ? "PASS" : "FAIL", nama);
  if (!ok) gagal++;
}

int main() {
  uint8_t seed[32];
  bool konsisten = false;
  Fragmen a{{0x0102030405060708ULL, 0x1112131415161718ULL,
             0x2122232425262728ULL, 0x3132333435363738ULL}};
  rakitSeed(a, a, seed, konsisten);
  cek(konsisten, "salinan sama => konsisten");
  cek(seed[0] == 0x01 && seed[7] == 0x08 && seed[31] == 0x38, "seed big-endian benar");

  Fragmen b = a; b.f[2] ^= 0xFF;
  bool kon2 = true;
  rakitSeed(a, b, seed, kon2);
  cek(!kon2, "salinan beda => tidak konsisten");

  uint8_t h[32];
  const char* pesan = "abc";
  sidikBita(reinterpret_cast<const uint8_t*>(pesan), 3, h);
  cek(h[0] == 0xba && h[1] == 0x78 && h[31] == 0xad, "sidikBita(abc) = ba7816bf...c3361aad");
  uint8_t h2[32];
  sidikBita(reinterpret_cast<const uint8_t*>(pesan), 3, h2);
  cek(setara(h, h2, 32), "setara identik => true");
  h2[5] ^= 1;
  cek(!setara(h, h2, 32), "setara beda => false");

  auto bk = blobKeyHeks(seed);
  cek(bk.size() == 64, "blobKey 64 hex");
  uint8_t seed2[32]; bool k3;
  rakitSeed(a, a, seed2, k3);
  cek(blobKeyHeks(seed2) != bk, "seed beda => blobKey beda");

  uint8_t seed3[32]; bool k4;
  rakitSeed(a, a, seed3, k4);
  cek(blobKeyHeks(seed3) == blobKeyHeks(seed2), "seed sama => blobKey deterministik");

  printf(gagal ? "\n%d GAGAL\n" : "\nSEMUA LULUS\n", gagal);
  return gagal ? 1 : 0;
}
```

- [ ] **Step 2: Compile & run to verify it fails**

Run (cari compiler: clang dari NDK `E:\...\ndk\<ver>\toolchains\llvm\prebuilt\windows-x86_64\bin\clang++.exe`, atau `g++`/`clang++` di PATH):
`clang++ -std=c++17 tools/test_native/test_inti.cpp -o tools/test_native/test_inti.exe`
Expected: FAIL kompilasi — `seed_inti.h` belum ada.

Tulis di `tools/test_native/README.md`: cara cari compiler + perintah build/run di atas.

- [ ] **Step 3: Write `seed_inti.h`**

Pindahkan `struct Sha256` (PLUS perbaiki token nyasar `vo` di baris ~99 — hapus baris `vo`) dari `kepemilikan.cpp` ke header sebagai `inline`, dalam `namespace kepem`. Tambahkan:

```cpp
#ifndef KEPEM_SEED_INTI_H
#define KEPEM_SEED_INTI_H
#include <cstdint>
#include <cstring>
#include <string>

namespace kepem {

struct Sha256 { /* ... isi existing dari kepemilikan.cpp, TANPA baris 'vo' ... */ };

inline std::string sidikHeks(const uint8_t* data, size_t n) {
  Sha256 s; s.mulai(); s.suap(data, n); return s.selesai();
}

inline void sidikBita(const uint8_t* data, size_t n, uint8_t keluar[32]) {
  std::string h = sidikHeks(data, n);
  for (int i = 0; i < 32; i++) {
    auto nib = [](char c) -> int {
      return (c >= '0' && c <= '9') ? c - '0' : (c - 'a' + 10);
    };
    keluar[i] = static_cast<uint8_t>((nib(h[i * 2]) << 4) | nib(h[i * 2 + 1]));
  }
}

inline bool setara(const uint8_t* a, const uint8_t* b, size_t n) {
  uint8_t beda = 0;
  for (size_t i = 0; i < n; i++) beda |= a[i] ^ b[i];
  return beda == 0;
}

struct Fragmen { uint64_t f[4]; };

inline void rakitSeed(const Fragmen& utama, const Fragmen& cadangan,
                      uint8_t seed[32], bool& konsisten) {
  konsisten = true;
  for (int i = 0; i < 4; i++) {
    if (utama.f[i] != cadangan.f[i]) konsisten = false;
    uint64_t v = utama.f[i];
    for (int j = 0; j < 8; j++) {
      seed[i * 8 + j] = static_cast<uint8_t>(v >> (56 - j * 8));
    }
  }
}

inline std::string keystreamHeks(const uint8_t seed[32]) {
  std::string a = sidikHeks(seed, 32);
  std::string b = a + "ks";
  return sidikHeks(reinterpret_cast<const uint8_t*>(b.data()), b.size());
}

inline std::string blobKeyHeks(const uint8_t seed[32]) {
  std::string ks = keystreamHeks(seed) + "blob";
  return sidikHeks(reinterpret_cast<const uint8_t*>(ks.data()), ks.size());
}

}  // namespace kepem
#endif
```

- [ ] **Step 4: Compile & run to verify pass**

Run: `clang++ -std=c++17 tools/test_native/test_inti.cpp -o tools/test_native/test_inti.exe && tools/test_native/test_inti.exe`
Expected: `SEMUA LULUS`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add android/app/src/main/cpp/seed_inti.h tools/test_native/
git commit -m "feat(native): seed_inti.h core reassembly+keystream+blobKey, host test"
```

---

### Task 5: Generator seed + regen `magic_*.S` (4 fragmen ×2 redundan ×3 ABI) + wire JNI `kunciBlobNative`

**Files:**
- Create: `tools/gen_seed/gen_seed.dart`
- Modify: `android/app/src/main/cpp/magic_arm64.S`
- Modify: `android/app/src/main/cpp/magic_armv7.S`
- Modify: `android/app/src/main/cpp/magic_x86_64.S`
- Modify: `android/app/src/main/cpp/kepemilikan.cpp`
- Modify: `android/app/src/main/cpp/CMakeLists.txt` (tak berubah struktur; verifikasi `seed_inti.h` ikut karena header)

**Interfaces:**
- Produces (extern "C", dipanggil dari `kepemilikan.cpp`):
  - arm64/armv7/x86_64 masing-masing meng-export: `kepem_frag_u0..u3` (salinan utama) dan `kepem_frag_c0..c3` (salinan cadangan), tiap fungsi balikan `uint64_t` fragmen.
  - Pertahankan `kepemilikan_magic()` (kompat) = `kepem_frag_u0()`.
- `kepemilikan.cpp` produces JNI:
  - `Java_org_gatechstudio_malutprovkab_Kepemilikan_kunciBlobNative(JNIEnv*, jobject)` → `jstring` 64 hex. TANPA arg identitas dari Kotlin. Internal: `seedAsm` dari fragmen; `seedId = sidikBita(bukaSandi())` (deobfuscate string kepemilikan di `.so`). Bila `utama==cadangan` DAN `setara(seedAsm, seedId)` → `blobKeyHeks(seedAsm)`. Bila salah satu gagal → korup `seedAsm[0] ^= 0xFF` lalu `blobKeyHeks` (key "salah" → dekrip token gagal → app paksa re-login). Ubah `SANDI`/identitas TANPA regen `.S` (atau sebaliknya) → mismatch → app pecah.

- [ ] **Step 1: Tulis generator seed**

`tools/gen_seed/gen_seed.dart` — deobfuscate `SANDI ⊕ KUNCI` (sama seperti `bukaSandi()` di cpp), `SHA256` hasilnya, pecah 4×u64 big-endian, cetak `seed` + immediate per ABI. Nama pemegang TIDAK pernah dicetak/disimpan plaintext — hanya bentuk ter-obfuscate `SANDI` (sudah ada di repo). `seed` yang dihasilkan = `SIDIK_KEPEMILIKAN` (`dfac89fc…381f1`). Format hex per-fragmen WAJIB dari byte (bukan `int.toRadixString`, yang membalik tanda untuk fragmen ber-bit63).

- [ ] **Step 2: Jalankan generator, catat output**

Run: `E:\flutter\bin\dart run tools/gen_seed/gen_seed.dart`
Expected: cetak `seed=<64hex>` dan `F0..F3` + immediate per ABI. **Catat nilai ini**; dipakai literal di langkah berikut.

- [ ] **Step 3: Regen `magic_arm64.S`** (pakai F0..F3 hasil Step 2)

```asm
// Lapisan kepemilikan — assembly AArch64 (arm64-v8a).
// Fragmen seed identitas (SHA-256) ditanam di immediate movz/movk.
    .text

.macro FRAG name, w0, w1, w2, w3
    .global \name
    .type \name, %function
\name:
    movz x0, #\w0
    movk x0, #\w1, lsl #16
    movk x0, #\w2, lsl #32
    movk x0, #\w3, lsl #48
    ret
    .size \name, .-\name
.endm

    FRAG kepem_frag_u0, 0xWWWW, 0xWWWW, 0xWWWW, 0xWWWW   // F0 (ganti dgn Step 2)
    FRAG kepem_frag_u1, 0xWWWW, 0xWWWW, 0xWWWW, 0xWWWW   // F1
    FRAG kepem_frag_u2, 0xWWWW, 0xWWWW, 0xWWWW, 0xWWWW   // F2
    FRAG kepem_frag_u3, 0xWWWW, 0xWWWW, 0xWWWW, 0xWWWW   // F3
    FRAG kepem_frag_c0, 0xWWWW, 0xWWWW, 0xWWWW, 0xWWWW   // F0 cadangan
    FRAG kepem_frag_c1, 0xWWWW, 0xWWWW, 0xWWWW, 0xWWWW   // F1
    FRAG kepem_frag_c2, 0xWWWW, 0xWWWW, 0xWWWW, 0xWWWW   // F2
    FRAG kepem_frag_c3, 0xWWWW, 0xWWWW, 0xWWWW, 0xWWWW   // F3

    .global kepemilikan_magic
    .type kepemilikan_magic, %function
kepemilikan_magic:
    b kepem_frag_u0
    .size kepemilikan_magic, .-kepemilikan_magic
```

- [ ] **Step 4: Regen `magic_x86_64.S`**

```asm
    .text

.macro FRAG name, imm
    .global \name
    .type \name, @function
\name:
    movabs $\imm, %rax
    ret
    .size \name, .-\name
.endm

    FRAG kepem_frag_u0, 0x................   // F0 hasil Step 2
    FRAG kepem_frag_u1, 0x................   // F1
    FRAG kepem_frag_u2, 0x................   // F2
    FRAG kepem_frag_u3, 0x................   // F3
    FRAG kepem_frag_c0, 0x................   // F0
    FRAG kepem_frag_c1, 0x................   // F1
    FRAG kepem_frag_c2, 0x................   // F2
    FRAG kepem_frag_c3, 0x................   // F3

    .global kepemilikan_magic
    .type kepemilikan_magic, @function
kepemilikan_magic:
    jmp kepem_frag_u0
    .size kepemilikan_magic, .-kepemilikan_magic
```

- [ ] **Step 5: Regen `magic_armv7.S`** (ARMv7 32-bit: balikan u64 di r0(lo)/r1(hi) via movw/movt)

```asm
    .text
    .syntax unified
    .arm

.macro FRAG name, lo_l, lo_h, hi_l, hi_h
    .global \name
    .type \name, %function
\name:
    movw r0, #\lo_l
    movt r0, #\lo_h
    movw r1, #\hi_l
    movt r1, #\hi_h
    bx lr
    .size \name, .-\name
.endm

    @ Tiap fragmen u64 F = (hi<<32)|lo ; r0=lo, r1=hi
    FRAG kepem_frag_u0, 0x...., 0x...., 0x...., 0x....   @ F0: lo_l,lo_h,hi_l,hi_h
    FRAG kepem_frag_u1, 0x...., 0x...., 0x...., 0x....
    FRAG kepem_frag_u2, 0x...., 0x...., 0x...., 0x....
    FRAG kepem_frag_u3, 0x...., 0x...., 0x...., 0x....
    FRAG kepem_frag_c0, 0x...., 0x...., 0x...., 0x....
    FRAG kepem_frag_c1, 0x...., 0x...., 0x...., 0x....
    FRAG kepem_frag_c2, 0x...., 0x...., 0x...., 0x....
    FRAG kepem_frag_c3, 0x...., 0x...., 0x...., 0x....

    .global kepemilikan_magic
    .type kepemilikan_magic, %function
kepemilikan_magic:
    b kepem_frag_u0
    .size kepemilikan_magic, .-kepemilikan_magic
```

(ARMv7 balikan `uint64_t` lewat r0/r1 sesuai AAPCS — deklarasikan signatur C `uint64_t` agar konsisten.)

- [ ] **Step 6: Wire `kepemilikan.cpp`** — `#include "seed_inti.h"`, hapus `struct Sha256` lokal (sudah pindah), hapus baris `vo`, deklarasi extern fragmen, tambah JNI `kunciBlobNative`.

```cpp
#include <jni.h>
#include "seed_inti.h"

extern "C" {
uint64_t kepem_frag_u0(); uint64_t kepem_frag_u1();
uint64_t kepem_frag_u2(); uint64_t kepem_frag_u3();
uint64_t kepem_frag_c0(); uint64_t kepem_frag_c1();
uint64_t kepem_frag_c2(); uint64_t kepem_frag_c3();
}

extern "C" JNIEXPORT jstring JNICALL
Java_org_gatechstudio_malutprovkab_Kepemilikan_kunciBlobNative(
    JNIEnv* env, jobject, jstring jidentitas) {
    kepem::Fragmen utama{{kepem_frag_u0(), kepem_frag_u1(), kepem_frag_u2(), kepem_frag_u3()}};
    kepem::Fragmen cadangan{{kepem_frag_c0(), kepem_frag_c1(), kepem_frag_c2(), kepem_frag_c3()}};
    uint8_t seed[32];
    bool konsisten = false;
    kepem::rakitSeed(utama, cadangan, seed, konsisten);

    const char* idc = env->GetStringUTFChars(jidentitas, nullptr);
    std::string identitas(idc == nullptr ? "" : idc);
    if (idc != nullptr) env->ReleaseStringUTFChars(jidentitas, idc);

    uint8_t seedId[32];
    kepem::sidikBita(reinterpret_cast<const uint8_t*>(identitas.data()),
                     identitas.size(), seedId);

    if (!konsisten || !kepem::setara(seed, seedId, 32)) {
        seed[0] ^= 0xFF;
    }
    return env->NewStringUTF(kepem::blobKeyHeks(seed).c_str());
}
```

(Pertahankan fungsi JNI lama yang masih dipakai channel; Task 6 menghapus yang jadi teater.)

- [ ] **Step 7: Verifikasi native build 3 ABI**

Run: `E:\flutter\bin\flutter build apk --debug`
Expected: BUILD SUCCESSFUL; `libkepemilikan.so` ter-generate untuk armeabi-v7a, arm64-v8a, x86_64 (cek `build/app/intermediates/.../jniLibs` atau APK `unzip -l`).

- [ ] **Step 8: Commit**

```bash
git add tools/gen_seed/ android/app/src/main/cpp/
git commit -m "feat(native): fragmen seed redundan 3 ABI + JNI kunciBlobNative"
```

---

### Task 6: Kotlin JNI bridge + channel `kunciBlob` + buang attestation teater

**Files:**
- Modify: `android/app/src/main/kotlin/org/gatechstudio/malutprovkab/Kepemilikan.kt`
- Modify: `android/app/src/main/kotlin/org/gatechstudio/malutprovkab/MainActivity.kt`

**Interfaces:**
- Consumes: `kunciBlobNative(identitas: String)` (Task 5).
- Produces:
  - `Kepemilikan.kunciBlob(context: Context): String` — `""` bila native tak tersedia (debug/SIMULASI), selain itu hasil `kunciBlobNative(identitas)` dengan `identitas = "${BuildConfig.PEMEGANG_HAKI}|${BuildConfig.TAHUN_CIPTA}|${context.packageName}"` (HARUS identik dengan string yang di-hash `tools/gen_seed`).
  - Channel method `"kunciBlob"` → `hasil.success(Kepemilikan.kunciBlob(applicationContext))` (kembalikan `null` bila string kosong agar Dart provider balikan `null`).

- [ ] **Step 1: Tambah ke `Kepemilikan.kt`**

```kotlin
private external fun kunciBlobNative(identitas: String): String

fun kunciBlob(context: Context): String {
    if (!nativeTersedia) return ""
    val identitas = "${BuildConfig.PEMEGANG_HAKI}|${BuildConfig.TAHUN_CIPTA}|${context.packageName}"
    return try { kunciBlobNative(identitas) } catch (_: Throwable) { "" }
}
```

- [ ] **Step 2: Wire channel di `MainActivity.kt`** (tambah cabang `when`)

```kotlin
"kunciBlob" -> {
    val k = Kepemilikan.kunciBlob(applicationContext)
    hasil.success(if (k.isEmpty()) null else k)
}
```

- [ ] **Step 3: Buang attestation teater**

Di `Kepemilikan.kt`: hapus method/field gerbang yang tak lagi dipakai sebagai proteksi (`atestasi`, `watermarkUtuh`, `kunciTurunan`, struct `Atestasi`, `atestasiInternal`) HANYA jika tak ada konsumen tersisa. Cek dulu:

Run: `git grep -n "watermarkUtuh\|atestasiKepemilikan\|kunciKepemilikan\|kunciTurunan" -- lib android`
- Hapus cabang channel `atestasiKepemilikan`/`watermarkUtuh`/`kunciKepemilikan` di `MainActivity.kt` dan handler Dart terkait di `detektor_native.dart` (field `watermarkUtuh` di `HasilNative` → default true, hentikan invoke `watermarkUtuh`).
- Pertahankan deteksi keamanan lain (debugger/frida/root/emulator/sidikTandaTangan) — di luar scope.

- [ ] **Step 4: Verifikasi build**

Run: `E:\flutter\bin\flutter build apk --debug`
Expected: BUILD SUCCESSFUL.

- [ ] **Step 5: Smoke test on device/emulator** (manual)

Pasang debug APK, login, restart app → tetap login (token round-trip lewat native key). Catat hasil di commit body.

Run: `E:\flutter\bin\flutter test`
Expected: seluruh suite PASS (tak ada regresi).

- [ ] **Step 6: Commit**

```bash
git add android/app/src/main/kotlin/ lib/core/security/detektor_native.dart
git commit -m "feat(security): channel kunciBlob + buang attestation gerbang teater"
```

---

### Task 7: Tool ekstraktor forensik (privat, di luar APK)

**Files:**
- Create: `tools/forensik/ekstraktor.dart`
- Create: `tools/forensik/README.md`
- Test: `tools/forensik/ekstraktor_test.dart`
- Modify: `.gitignore` (tambah `tools/forensik/`)

**Interfaces:**
- Produces:
  - `class LaporanForensik { final int fragmenDitemukan; final int total; final double keyakinan; final List<String> abiTerdeteksi; }`
  - `LaporanForensik pindaiBytes(List<int> isiSo, List<int> seedHarap)` — cari pola immediate fragmen (arm64 `movz/movk`, x86_64 `movabs`, armv7 `movw/movt`) yang menyusun `seedHarap`; `keyakinan = fragmenDitemukan/total`.
  - `Future<LaporanForensik> pindaiApk(String pathApk, List<int> seedHarap)` — unzip, scan tiap `lib*.so`.

- [ ] **Step 1: Write the failing test**

```dart
import 'dart:typed_data';
import 'package:test/test.dart';
import 'ekstraktor.dart';

void main() {
  test('temukan movabs x86_64 fragmen di buffer', () {
    final seed = List<int>.generate(32, (i) => i + 1);
    final f0 = seed.sublist(0, 8);
    final buf = <int>[0x90, 0x90, 0x48, 0xB8, ...f0.reversed, 0xC3];
    final lap = pindaiBytes(Uint8List.fromList(buf), seed);
    expect(lap.fragmenDitemukan >= 1, isTrue);
    expect(lap.abiTerdeteksi.contains('x86_64'), isTrue);
  });

  test('buffer acak => nol fragmen', () {
    final seed = List<int>.generate(32, (i) => i + 1);
    final buf = List<int>.filled(256, 0x55);
    final lap = pindaiBytes(Uint8List.fromList(buf), seed);
    expect(lap.fragmenDitemukan, 0);
    expect(lap.keyakinan, 0.0);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `E:\flutter\bin\dart test tools/forensik/ekstraktor_test.dart`
Expected: FAIL — `ekstraktor.dart` belum ada.

- [ ] **Step 3: Implement `ekstraktor.dart`**

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';

class LaporanForensik {
  LaporanForensik(this.fragmenDitemukan, this.total, this.abiTerdeteksi);
  final int fragmenDitemukan;
  final int total;
  final List<String> abiTerdeteksi;
  double get keyakinan => total == 0 ? 0 : fragmenDitemukan / total;
}

LaporanForensik pindaiBytes(Uint8List isi, List<int> seedHarap) {
  final frag = <List<int>>[];
  for (var i = 0; i < 4; i++) {
    frag.add(seedHarap.sublist(i * 8, i * 8 + 8));
  }
  var temu = 0;
  final abi = <String>{};
  for (final f in frag) {
    final le = f.reversed.toList();
    if (_cariSub(isi, le) >= 0) { temu++; abi.add('x86_64'); continue; }
    if (_cariSub(isi, f) >= 0) { temu++; abi.add('be-raw'); continue; }
  }
  return LaporanForensik(temu, frag.length, abi.toList());
}

int _cariSub(List<int> hay, List<int> needle) {
  for (var i = 0; i + needle.length <= hay.length; i++) {
    var ok = true;
    for (var j = 0; j < needle.length; j++) {
      if (hay[i + j] != needle[j]) { ok = false; break; }
    }
    if (ok) return i;
  }
  return -1;
}

Future<LaporanForensik> pindaiApk(String pathApk, List<int> seedHarap) async {
  final bytes = await File(pathApk).readAsBytes();
  final arsip = ZipDecoder().decodeBytes(bytes);
  var temu = 0; final abi = <String>{}; var total = 0;
  for (final f in arsip) {
    if (!f.name.endsWith('.so')) continue;
    final lap = pindaiBytes(Uint8List.fromList(f.content as List<int>), seedHarap);
    temu += lap.fragmenDitemukan; total += lap.total; abi.addAll(lap.abiTerdeteksi);
  }
  return LaporanForensik(temu, total, abi.toList());
}
```

(Catatan: `movabs` menaruh immediate little-endian → cocok via `f.reversed`. arm64/armv7 menyebar nibble di banyak instruksi; deteksi raw-LE menangkap kasus x86_64 dan blob `.rodata` turunan. README jelaskan keterbatasan + cara perluas ke disasm immediate arm.)

- [ ] **Step 4: Run to verify pass**

Run: `E:\flutter\bin\dart pub add --dev archive && E:\flutter\bin\dart test tools/forensik/ekstraktor_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: gitignore + README + commit (script saja, bukan output build)**

Tambah ke `.gitignore`: `tools/forensik/`. README jelaskan: jalankan `dart run tools/forensik/ekstraktor.dart <apk> <seedhex>` pada APK tersangka → laporan provenance untuk bukti hukum; JANGAN distribusikan dengan app.

```bash
git add .gitignore
git commit -m "chore: gitignore tools/forensik (ekstraktor provenance privat)"
```

(File di `tools/forensik/` sengaja tak di-commit — privat.)

---

### Task 8: Verifikasi end-to-end + dokumentasi tamper-response

**Files:**
- Create: `docs/keamanan/watermark-provenance.md`

- [ ] **Step 1: Tamper simulation (manual, catat hasil)**

Ubah sementara satu immediate di `magic_arm64.S` (mis. `kepem_frag_u2`) → build → pasang → login → restart app. Expected: cross-check `konsisten=false` → seed korup → token tak terdekripsi → app paksa re-login. Kembalikan immediate setelah uji.

- [ ] **Step 2: Rebrand simulation (manual)**

Ubah sementara `PEMEGANG_HAKI` di `build.gradle.kts` TANPA regen `.S` → build → login → restart. Expected: `sidikHeks(identitas) != seedAsm` (bila cross-check identitas diaktifkan) atau seed asm tetap = identitas lama → demonstrasikan bahwa app hanya berfungsi penuh dengan identitas asli. Kembalikan nilai.

- [ ] **Step 3: Full suite**

Run: `E:\flutter\bin\flutter test && E:\flutter\bin\flutter analyze`
Expected: PASS, no issues.

- [ ] **Step 4: Tulis dokumentasi**

`docs/keamanan/watermark-provenance.md`: ringkas arsitektur, cara regen seed saat ganti identitas (`tools/gen_seed` → tempel ke 3 `.S`), prosedur forensik, dan caveat (adversary maha-tahu tetap bisa bongkar; ini cost-raising + bukti, bukan benteng).

- [ ] **Step 5: Commit**

```bash
git add docs/keamanan/watermark-provenance.md
git commit -m "docs(keamanan): prosedur watermark provenance + regen seed + forensik"
```

---

## Catatan Eksekusi Kritis

- **Regen seed saat ganti identitas:** mengubah `PEMEGANG_HAKI`/`TAHUN_CIPTA` WAJIB diikuti `dart run tools/gen_seed` + tempel ulang ketiga `.S`, jika tidak app sah ikut rusak.
- **Bit-exact lintas ABI:** ketiga `.S` HARUS encode `F0..F3` identik. Verifikasi via Task 8 di minimal 1 device arm64 + 1 emulator x86_64.
- **Rollout pertama:** install lama bertoken plaintext aman (legacy passthrough); enkripsi mulai pada penulisan token berikutnya.
- **Debug/lokal:** native absent / `SIMULASI_TANPA_NATIVE` → `kunciBlob` kosong → token plaintext → dev lancar.
