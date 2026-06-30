# Host test `seed_inti.h`

Uji unit murni untuk logika inti native (`android/app/src/main/cpp/seed_inti.h`):
reassembly seed big-endian, `sidikBita` (SHA-256 raw), `setara` (banding
waktu-tetap), `keystreamHeks`, `blobKeyHeks`.

## Jalankan (butuh toolchain C++ host)

Dengan g++ / clang++ / MSVC host:

```
clang++ -std=c++17 tools/test_native/test_inti.cpp -o test_inti && ./test_inti
```

Output sukses: `SEMUA LULUS`, exit 0.

## Verifikasi di environment tanpa toolchain host

NDK clang hanya membawa sysroot Android (tak ada header host), sehingga
host-run tidak tersedia. Minimal lakukan syntax-check terhadap target Android:

```
NDK=$ANDROID_HOME/ndk/<versi>/toolchains/llvm/prebuilt/windows-x86_64/bin
"$NDK/clang++.exe" --target=aarch64-linux-android24 -std=c++17 -O2 -fsyntax-only tools/test_native/test_inti.cpp
"$NDK/clang++.exe" --target=x86_64-linux-android24 -std=c++17 -O2 -fsyntax-only tools/test_native/test_inti.cpp
```

Known-answer yang diuji: `SHA-256("abc") = ba7816bf...c3361aad`. Korektnya juga
divalidasi end-to-end di device (Task 8: login tetap persist lintas restart).
