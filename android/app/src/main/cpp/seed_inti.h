#ifndef KEPEM_SEED_INTI_H
#define KEPEM_SEED_INTI_H

#include <cstdint>
#include <cstring>
#include <string>

namespace kepem {

struct Sha256 {
    uint32_t h[8];
    uint64_t panjang;
    uint8_t penyangga[64];
    size_t isi;

    static uint32_t putar(uint32_t x, uint32_t n) {
        return (x >> n) | (x << (32 - n));
    }

    void mulai() {
        h[0] = 0x6a09e667; h[1] = 0xbb67ae85; h[2] = 0x3c6ef372; h[3] = 0xa54ff53a;
        h[4] = 0x510e527f; h[5] = 0x9b05688c; h[6] = 0x1f83d9ab; h[7] = 0x5be0cd19;
        panjang = 0; isi = 0;
    }

    void blok(const uint8_t* p) {
        static const uint32_t k[64] = {
            0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
            0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
            0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
            0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
            0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
            0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
            0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
            0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
        };
        uint32_t w[64];
        for (int i = 0; i < 16; i++) {
            w[i] = (uint32_t(p[i*4]) << 24) | (uint32_t(p[i*4+1]) << 16) |
                   (uint32_t(p[i*4+2]) << 8) | uint32_t(p[i*4+3]);
        }
        for (int i = 16; i < 64; i++) {
            uint32_t s0 = putar(w[i-15],7) ^ putar(w[i-15],18) ^ (w[i-15] >> 3);
            uint32_t s1 = putar(w[i-2],17) ^ putar(w[i-2],19) ^ (w[i-2] >> 10);
            w[i] = w[i-16] + s0 + w[i-7] + s1;
        }
        uint32_t a=h[0],b=h[1],c=h[2],d=h[3],e=h[4],f=h[5],g=h[6],hh=h[7];
        for (int i = 0; i < 64; i++) {
            uint32_t S1 = putar(e,6) ^ putar(e,11) ^ putar(e,25);
            uint32_t ch = (e & f) ^ (~e & g);
            uint32_t t1 = hh + S1 + ch + k[i] + w[i];
            uint32_t S0 = putar(a,2) ^ putar(a,13) ^ putar(a,22);
            uint32_t maj = (a & b) ^ (a & c) ^ (b & c);
            uint32_t t2 = S0 + maj;
            hh=g; g=f; f=e; e=d+t1; d=c; c=b; b=a; a=t1+t2;
        }
        h[0]+=a; h[1]+=b; h[2]+=c; h[3]+=d; h[4]+=e; h[5]+=f; h[6]+=g; h[7]+=hh;
    }

    void suap(const uint8_t* data, size_t n) {
        panjang += n;
        while (n > 0) {
            penyangga[isi++] = *data++;
            n--;
            if (isi == 64) { blok(penyangga); isi = 0; }
        }
    }

    std::string selesai() {
        uint64_t bit = panjang * 8;
        uint8_t satu = 0x80;
        suap(&satu, 1);
        uint8_t nol = 0;
        while (isi != 56) suap(&nol, 1);
        uint8_t pj[8];
        for (int i = 0; i < 8; i++) pj[i] = static_cast<uint8_t>(bit >> (56 - i*8));
        suap(pj, 8);
        static const char* heks = "0123456789abcdef";
        std::string keluar;
        keluar.resize(64);
        for (int i = 0; i < 8; i++) {
            for (int j = 0; j < 4; j++) {
                uint8_t bita = static_cast<uint8_t>(h[i] >> (24 - j*8));
                keluar[(i*4+j)*2] = heks[bita >> 4];
                keluar[(i*4+j)*2+1] = heks[bita & 0xf];
            }
        }
        return keluar;
    }
};

inline std::string sidikHeks(const uint8_t* data, size_t n) {
    Sha256 s; s.mulai(); s.suap(data, n); return s.selesai();
}

inline void sidikBita(const uint8_t* data, size_t n, uint8_t keluar[32]) {
    std::string h = sidikHeks(data, n);
    auto nib = [](char c) -> int {
        return (c >= '0' && c <= '9') ? c - '0' : (c - 'a' + 10);
    };
    for (int i = 0; i < 32; i++) {
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
