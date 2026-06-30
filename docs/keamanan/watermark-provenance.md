# Watermark Provenance Native

Lapisan kepemilikan ter-*entangle*: identitas kepemilikan → seed di immediate
Assembly (3 ABI, redundan) → keystream native → kunci enkripsi token at-rest.
Tujuan realistis: **cost-raising** (penghapusan mahal) + **forensik** (bukti
turunan), BUKAN pencegahan total (mustahil bila lawan punya seluruh source +
keystore).

## Alur

```
string kepemilikan (ter-obfuscate SANDI⊕KUNCI di .so, nama TIDAK plaintext)
   │  bukaSandi()  →  SHA-256
   ▼
seed 32B = SIDIK_KEPEMILIKAN (dfac89fc…381f1)
   │  4 fragmen u64, ditanam di immediate movz/movk (arm64) / movabs (x86_64)
   │  / movw/movt (armv7); salinan utama + cadangan tiap ABI
   ▼
JNI kunciBlobNative(): rakit seed dari fragmen; cross-check
   (utama==cadangan) DAN setara(seedAsm, sidikBita(bukaSandi))
   │  gagal → seed dikorup → kunci salah
   ▼
keystream → blobKey (64 hex)  →  channel bakudapa/keamanan "kunciBlob"
   ▼
PenyimpananAman: enkrip access/refresh/registrasi token (SampulBlob v1,
   HMAC-SHA256 keystream + MAC). Seed salah → token tak terdekripsi → re-login.
```

## Decoy publik vs identitas rahasia

- `PEMEGANG_HAKI="GATECH"` (BuildConfig + manifest meta-data) = **decoy publik**,
  TIDAK dipakai sebagai sumber seed.
- Identitas asli hanya ada **ter-obfuscate** di `SANDI` (cpp). Tak pernah
  plaintext di source, manifest, atau output `gen_seed`.

## Regen seed (bila identitas/`SANDI` berubah)

1. Ubah `SANDI`/`KUNCI` di `kepemilikan.cpp` DAN `tools/gen_seed/gen_seed.dart`
   (harus identik).
2. `dart run tools/gen_seed/gen_seed.dart` → catat `seed` + `F0..F3`.
3. Tempel ulang immediate ke KETIGA `.S` (`magic_arm64.S`, `magic_armv7.S`,
   `magic_x86_64.S`) — utama + cadangan, bit-exact.
4. Build 3 ABI, uji login persist lintas restart di arm64 + x86_64.

**Lupa regen `.S` setelah ubah `SANDI` → app sah ikut rusak (token tak terbaca).**

## Forensik

`tools/forensik/` (privat, gitignore). Pindai APK tersangka:

```
dart run tools/forensik/ekstraktor.dart <apk> <seedhex64>
```

>0 fragmen ditemukan = bukti positif provenance.

## Caveat jujur

Lawan dengan seluruh source + keystore tetap bisa membongkar total (regen
`SANDI`+`.S` konsisten → app jalan dengan identitas mereka). Nilai nyata: tamper
parsial/malas memecahkan app (cost-raising), sisa fragmen = bukti (forensik).
Ini jebakan + bukti, bukan benteng. Pencegahan nyata butuh enforcement
sisi-server (di luar lingkup ini).

## Verifikasi yang sudah dilakukan

- `flutter test` penuh: 62 lulus (termasuk SampulBlob, PenyediaKunciBlob,
  PenyimpananAman entangle).
- Build `flutter build apk --debug`: 3 ABI sukses, `libkepemilikan.so` ada di
  arm64-v8a / armeabi-v7a / x86_64.
- Ekstraktor pada APK sah: 4/4 fragmen, 100%.

## Manual (pending, di device fisik)

- Tamper-sim: ubah 1 immediate di `magic_arm64.S` → build → login → restart →
  harus paksa re-login (cross-check gagal).
- Rebrand-sim: ubah `SANDI` tanpa regen `.S` → mismatch → app pecah.
