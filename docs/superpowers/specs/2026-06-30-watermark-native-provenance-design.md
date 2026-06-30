# Desain: Watermark Provenance Native (C++/NDK/Assembly)

Tanggal: 2026-06-30
Status: Disetujui (brainstorming) — siap implementation plan

## 1. Latar & Model Ancaman

Aplikasi Flutter Android BAKUDAPA sudah punya lapisan kepemilikan native
(`android/app/src/main/cpp/`) yang cross-layer attestation. Lapisan itu:

- Build-break: token nyasar `vo` di `kepemilikan.cpp:99`.
- Untracked (`?? android/app/src/main/cpp/`) — bisa hilang saat checkout bersih.
- Memperlakukan watermark sebagai gerbang `boolean utuh` yang mudah di-bypass
  (`PAKSA_WATERMARK=false`, ganti `SIDIK_TANDA_RILIS`).

**Adversary:** developer lain dengan akses penuh — source Dart + source native
(cpp/asm) + release keystore.

**Konsekuensi jujur:** pencegahan total MUSTAHIL. Siapa pun yang memegang seluruh
source + signing key bisa menghapus konstanta, recompile, tandatangani ulang.
Tidak ada trik C++/Assembly yang mengubah fakta ini.

**Goal yang dikejar (realistis):**

- **A. Cost-raising** — penghapusan jadi mahal/melelahkan; menyaring penyerang malas.
- **B. Forensic provenance** — tanam marker tersembunyi yang sulit ditemukan & dihapus;
  buktikan karya turunan secara hukum bila memperoleh APK tersangka.

**Bukan goal:** server-side enforcement (C), packing `.so` komersial, anti-Frida berat.

Prinsip pengikat A+B: **entanglement**. Marker bukan flag `if(watermarkUtuh)` terpisah,
melainkan konstanta yang DIPAKAI logika nyata app dan diturunkan dari identitas HAKI.
Hapus/ubah → fungsi rusak (A); sisa fragmen → bukti (B).

## 2. Arsitektur (Approach 1 — Entangled provenance keystream)

```
PEMEGANG_HAKI + TAHUN_CIPTA + package
        │  SHA-256
        ▼
   seed 32-byte  ──(8 byte pertama = magic, kompat skema lama)
        │  dipecah 4×64-bit, ditanam di immediate movz/movk
        ▼
  Assembly .S (arm64 / armv7 / x86_64), ≥2 fungsi/ABI (redundan)
        │  C++ panggil semua, rakit-ulang, cross-check antar-salinan
        ▼
   keystream (HMAC-chain dari seed)
        │  f(keystream) = kunci enkripsi blob
        ▼
  PenyimpananAman: enkrip value at-rest (token akses/segar)
        │
        ▼
  seed salah (tamper identitas/asm) → dekrip token gagal → app paksa re-login
```

### Komponen

| Unit | Lokasi | Tanggung jawab | Depend |
|---|---|---|---|
| Seed identitas | `kepemilikan.cpp` | identitas → SHA-256 → seed 32B | branding HAKI |
| Fragmen asm | `magic_*.S` (3 ABI) | simpan 4 fragmen seed di immediate, redundan | — |
| Perakit + keystream | `kepemilikan.cpp` | rakit seed, cross-check salinan, derive keystream | fragmen asm, SHA native |
| Jembatan JNI | `Kepemilikan.kt` | expose keystream/kunci-blob ke Kotlin | native lib |
| Channel | `MainActivity.kt` | method `kunciBlob` via `bakudapa/keamanan` | Kepemilikan.kt |
| Konsumen entanglement | `penyimpanan_aman.dart` | enkrip/dekrip value at-rest pakai kunci-blob | channel |
| Ekstraktor forensik | `tools/forensik/` (gitignore, di luar APK) | scan APK tersangka → laporan provenance | — |

## 3. Detail Desain

### 3.1 Identitas → seed
`seed = SHA256(string_kepemilikan_ter-obfuscate)` di mana string kepemilikan
disimpan ter-obfuscate (`SANDI ⊕ KUNCI` = `bukaSandi()`) di dalam `.so` — TIDAK
pernah plaintext di source/manifest. `SHA256(bukaSandi)` = `SIDIK_KEPEMILIKAN`
(`dfac89fc…381f1`). Nama pemegang asli tak diekspos; `PEMEGANG_HAKI="GATECH"`
di BuildConfig/manifest hanya decoy publik, terpisah dari seed.
8 byte pertama tetap dipakai sebagai `magic` agar kompatibel pemeriksaan lama.

### 3.2 Penanaman fragmen Assembly
- Seed 32-byte → 4 fragmen 64-bit `F0..F3`.
- Tiap fragmen di-emit via `movz/movk` (arm64), padanan armv7 (`movw/movt`),
  padanan x86_64 (`movabs`).
- Redundansi: tiap fragmen muncul di ≥2 fungsi berbeda per ABI. C++ membaca
  semua salinan dan membandingkan — salinan tak konsisten = sinyal tamper.
- Fragmen hidup di `.text` (instruksi), bukan `.rodata`; tidak muncul pada `strings`.

### 3.3 Perakitan + keystream (C++)
- Panggil seluruh fungsi fragmen, rakit `seed`.
- Cross-check antar-salinan; mismatch → keystream sengaja korup (gagal dekrip).
- `keystream = HMAC-chain(seed)` memakai SHA-256 native yang sudah ada
  (perbaiki dulu token nyasar `vo` di `kepemilikan.cpp:99`).
- Perakitan di-interleave dengan kerja lain agar tak jadi satu blok mudah di-patch.

### 3.4 Konsumen entanglement — token-blob
- `PenyimpananAman.tulis` mengenkripsi `nilai` dengan kunci `f(keystream)` (mis.
  AES-GCM atau XOR-keystream + MAC) sebelum delegasi ke FlutterSecureStorage;
  `baca` mendekripsi.
- Target kritis: **access token & refresh token**.
- Penyerang yang mengubah `PEMEGANG_HAKI` (untuk klaim kepemilikan sendiri) →
  seed berubah → kunci berubah → token tersimpan tak terdekripsi → app paksa
  re-login berulang. Mempertahankan identitas asli = syarat app berfungsi.
- Bit-exact lintas ABI dijamin karena immediate sama di tiap `.S`.

### 3.5 Tanpa flag pusat
Tidak ada satu `boolean watermarkUtuh`. Verifikasi implisit: dekrip berhasil atau
tidak. Hapus skema `atestasi`/`utuh` lama yang mudah di-bypass.

### 3.6 Ekstraktor forensik (privat)
- `tools/forensik/` (di-gitignore, TIDAK masuk APK).
- Input: APK tersangka → unzip → tiap `lib*.so` → scan pola immediate
  `movz/movk` (dan padanan ABI lain) + signature keystream.
- Output: laporan `fragmen X/8 ditemukan`, confidence, identitas terbaca.
- Inilah yang membuat goal B actionable secara hukum.

### 3.7 Hardening cost-raising (modest)
- `-O2 -fvisibility=hidden` (sudah), strip symbol rilis.
- Interleave perakitan seed dengan kerja nyata.
- Anti-debug native ringan (`ptrace` self-attach) — opsional, jangan berlebihan.

## 4. Keamanan User Sah & Migrasi

- Build sah: seed selalu benar → token nyaman, nol degradasi.
- Migrasi: install lama menyimpan token format plaintext → deteksi format saat baca
  → re-enkrip sekali. `AndroidOptions(resetOnError: true)` sudah ada sebagai jaring.
- `BuildConfig.SIMULASI_TANPA_NATIVE` / `DEBUG` / `BUILD_LOKAL`: lewati enkripsi blob
  agar dev lokal lancar (degradasi hanya menargetkan rilis tamper).

## 5. Cleanup Skema Lama

- Perbaiki token nyasar `vo` di `kepemilikan.cpp:99`.
- Buang attestation lama yang jadi teater (`atestasi`/`utuh`/`lintasUtuh`/`metaUtuh`)
  bila tidak lagi dipakai sebagai gerbang; pertahankan hanya jalur keystream.
- **Commit `android/app/src/main/cpp/`** (saat ini untracked).

## 6. Testing

- Unit (C++/native test atau via JNI): rakit-seed dari identitas dikenal = nilai harapan.
- Unit (Dart): round-trip enkrip/dekrip token via `PenyimpananAman`.
- Tamper-sim: ubah satu immediate di satu `.S` → cross-check gagal → dekrip gagal.
- Integrasi: build 3 ABI sukses; ekstraktor menemukan fragmen pada `.so` hasil build.

## 7. Risiko & Caveat

- Lawan adversary maha-tahu, skema TETAP bisa dibongkar total oleh penyerang gigih.
  Nilai nyata: rebrand-kepemilikan memecahkan app (A); sisa fragmen = bukti turunan (B).
  Ini jebakan + bukti, bukan benteng.
- Entanglement token berisiko logout bila migrasi/ABI salah → mitigasi: deteksi format,
  `resetOnError`, bypass debug, uji 3 ABI bit-exact sebelum rilis.
