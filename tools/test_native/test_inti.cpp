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

  rakitSeed(a, a, seed, konsisten);
  auto bk = blobKeyHeks(seed);
  cek(bk.size() == 64, "blobKey 64 hex");
  uint8_t seed2[32]; bool k3;
  Fragmen c = a; c.f[0] ^= 0x99;
  rakitSeed(c, c, seed2, k3);
  cek(blobKeyHeks(seed2) != bk, "seed beda => blobKey beda");

  uint8_t seed3[32]; bool k4;
  rakitSeed(a, a, seed3, k4);
  cek(blobKeyHeks(seed3) == bk, "seed sama => blobKey deterministik");

  printf(gagal ? "\n%d GAGAL\n" : "\nSEMUA LULUS\n", gagal);
  return gagal ? 1 : 0;
}
