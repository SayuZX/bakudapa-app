# Panduan UI/UX — BAKUDAPA MOBILE

Design system & spesifikasi halaman untuk aplikasi layanan administrasi
kependudukan Disdukcapil Provinsi Maluku Utara. Government-grade, clean, premium.
Dokumen ini **diturunkan dari token & komponen yang sudah ada di kode** (`lib/core/theme`,
`lib/shared/widgets`, `lib/core/dialogs`) — jadi langsung dapat dipakai, bukan teori.

> Mockup di bawah memakai wireframe ASCII (monospace) karena lebih presisi untuk
> developer Flutter daripada gambar — setiap elemen, spacing, dan state-nya jelas.

---

## 0. Prinsip Desain (WAJIB)

1. **Restrained & government-grade** — satu warna aksen (merah Disdukcapil), sisanya netral.
2. **Permukaan solid** — kartu/dialog selalu `#FFFFFF` solid di atas latar `#F7F8FA`.
   **DILARANG** background berwarna ber-opacity rendah di belakang teks (mis. merah 10%
   di belakang paragraf) — merusak kontras & keterbacaan.
3. **Tanpa** gradient berlebihan, neumorphism, glassmorphism, atau shadow berat.
   Shadow hanya 1–2 lapis sangat tipis (lihat §1.4).
4. **White space lega** — padding layar 20px, jarak antar-blok 20–24px.
5. **Hierarki jelas** — judul tebal besar → sub abu → isi. Maksimal 1 aksi primer per layar.
6. **Ikon line minimalis** — HugeIcons stroke, ukuran 18–24px, warna mengikuti teks.
7. **Bilingual ID/EN** — semua teks dari `Teks` (jangan hardcode). Bahasa sopan & instruktif.
8. **Aksesibilitas** — kontras ≥ 4.5:1, target sentuh ≥ 48px, font terbaca, dukung text-scale.
9. **State via modal/overlay clean** — loading/blocking pakai modal, bukan toast/snackbar.

---

## 1. Style Guide

### 1.1 Warna (`lib/core/theme/warna.dart`)

**Aksen (gunakan hemat — hanya untuk aksi primer & penanda aktif):**
| Token | Hex | Pakai untuk |
|---|---|---|
| `merahUtama` | `#C8102E` | tombol primer, tab aktif, link, progress |
| `merahGelap` | `#A00C24` | status pressed/hover tombol primer |
| `merahLembut` | `#FCE8EC` | latar ikon kecil (chip ikon), **bukan** di belakang teks panjang |

**Netral (tulang punggung UI):**
`#FBFBFC · #F7F8FA · #EFF1F4 · #E3E6EB · #CDD2DA · #A7AEBA · #7C8392 · #5A6171 · #3F4654 · #2A2F3A · #14171F`

**Peran permukaan & teks:**
| Peran | Token | Hex |
|---|---|---|
| Latar layar | `latar` | `#F7F8FA` |
| Permukaan (kartu/dialog) | `permukaan` | `#FFFFFF` |
| Garis/border | `garis` / `garisTegas` | `#E3E6EB` / `#CDD2DA` |
| Teks utama | `teksUtama` | `#14171F` |
| Teks kedua | `teksKedua` | `#5A6171` |
| Teks ketiga/nonaktif | `teksKetiga`/`teksNonaktif` | `#7C8392`/`#A7AEBA` |

**Semantik (status):** `sukses #1F8A4C`, `peringatan #B7791F`, `bahaya #B42318`,
`info #1F6FB8`, `tunda #6B7280` — masing-masing punya pasangan `…Lembut` untuk
latar ikon/badge **kecil** saja.

> Aturan kontras: teks selalu `teksUtama`/`teksKedua` di atas `permukaan`/`latar`.
> Warna semantik untuk ikon/label pendek, **tidak** sebagai latar paragraf.

### 1.2 Tipografi (`Plus Jakarta Sans`)
| Style | Size / Weight / Height | Pakai |
|---|---|---|
| displaySmall | 26 / 700 / 1.22 | judul splash/sukses besar |
| headlineSmall | 20 / 700 / 1.28 | judul halaman |
| titleLarge | 18 / 700 / 1.3 | judul section/kartu besar |
| titleMedium | 16 / 600 / 1.35 | judul kartu |
| titleSmall | 14 / 600 / 1.4 | label tebal |
| bodyLarge | 16 / 500 / 1.5 | isi penting |
| bodyMedium | 14 / 500 / 1.5 | isi standar |
| bodySmall | 12 / 500 / 1.5 | keterangan (abu) |
| labelMedium | 12 / 600 / 1.3 | label form/stepper |
| labelSmall | 11 / 600 / 1.3 | kapsul status, footnote |

Akses cepat: `context.teks.titleMedium`. Letter-spacing ketat (judul −0.2…−0.6) untuk kesan premium.

### 1.3 Spacing & Radius
**Jarak:** `xs4 · sm8 · md12 · lg16 · xl20 · xxl24 · xxxl32 · raksasa40`; padding layar `layarH = 20`.
**Sudut:** `xs6 · sm10 · md12 · lg16 · xl20 · pil999`.
- Kartu radius `lg(16)`, tombol `pil(999)` (StadiumBorder), field `sm–md`.
- Antar field 20 (`xl`), antar section 20–24, dalam kartu 12 (`md`).

### 1.4 Elevation / Shadow (`Bayangan`)
Sangat halus, government-grade — **jangan ditambah berat**:
- `kartu` → 2 lapis (`#0F101828` blur12 y4 + `#08101828` blur2 y1). Default kartu.
- `halus` → hover/elemen kecil. `melayang` → dialog/FAB. `bilahBawah` → bottom-nav (shadow ke atas).
> Banyak kartu cukup pakai **border `garis` tanpa shadow** (lebih flat & bersih).

### 1.5 Ikon — HugeIcons (stroke/line)
Ukuran: 18 (inline), 20 (tombol/list), 22–24 (header), 30–44 (ilustrasi state).
Warna = warna teks konteks (`teksKedua` netral, `merahUtama` aktif). Hindari ikon filled warna-warni.

### 1.6 Aksesibilitas
- Kontras teks ≥ 4.5:1 (kombinasi token di atas sudah memenuhi).
- Target sentuh **≥ 48px** (tombol 52, bottom-nav default, icon-button 44–48).
- Dukung text-scale; `textScaler` boleh di-clamp maksimum (mis. 1.25) agar layout tetap rapi tetapi tetap membesar.
- Setiap ikon-aksi punya `tooltip`/`Semantics` label. Jangan andalkan warna saja untuk status (selalu + ikon + teks).

---

## 2. Komponen Reusable (Flutter — sudah ada di repo)

| Komponen | File | Fungsi & state |
|---|---|---|
| `Kartu` | `shared/widgets/kartu.dart` | kontainer putih + border + radius lg + InkWell. Dasar semua kartu. |
| `TombolUtama` | `shared/widgets/tombol_utama.dart` | tombol primer pil; props `label`, `memuat` (spinner), `melebar`, `aktif`. |
| `TombolGaris` | `shared/widgets/tombol_garis.dart` | tombol sekunder (outline). |
| `IsianGarisBawah` / `KotakIsian` | `auth/.../isian_garis_bawah.dart`, `shared/widgets/kotak_isian.dart` | field; toggle sandi, validator, pesan error inline. |
| `KotakCentangSetuju` | `shared/widgets/kotak_centang_setuju.dart` | checkbox persetujuan. |
| `DialogAplikasi` | `core/dialogs/dialog_aplikasi.dart` | `tampilkanAlert` (modal info/sukses/error), `tampilkanKonfirmasi`, `tampilkanPemblokir` (full-screen blocking), `tampilkanToast`. Pakai HugeIcon + nada. |
| `OverlayMuatGlobal` | `shared/widgets/overlay_muat_global.dart` | **modal loading** dim+blur blocking, pesan informatif. Untuk semua proses backend. |
| `PemuatKerlip` / `DaftarKerangka` | `shared/widgets/pemuat_kerlip.dart` | skeleton shimmer saat memuat list/kartu. |
| `KondisiKosong` / `KondisiGalat` | `shared/widgets/…` | empty & error state (ikon + judul + pesan + tombol coba lagi). |
| `LencanaStatusLiveness` | `registration/.../lencana_status_liveness.dart` | kapsul status realtime (ikon + teks, nada netral/peringatan/sukses). |
| `BingkaiWajahLiveness` | `registration/.../bingkai_wajah_liveness.dart` | overlay lingkaran deteksi wajah, reaktif (offset/yaw/pitch/progress). |
| `StepperRegistrasi` | `registration/.../stepper_registrasi.dart` | "Langkah X dari N" + progress bar. |
| `KerangkaUtama` | `dashboard/.../kerangka_utama.dart` | shell 5-tab (`StatefulShellRoute`) + badge notifikasi. |

---

## 3. Mockup + Flow per Halaman

### 3.1 Splash / Intro
```
┌───────────────────────────────┐
│                               │  latar: #F7F8FA solid
│                               │
│                               │
│            ╭─────╮            │
│            │ LOGO│  logo-malut.svg, ~96px
│            ╰─────╯            │
│         BAKUDAPA              │  headlineSmall, teksUtama
│   Disdukcapil Maluku Utara    │  bodySmall, teksKedua
│                               │
│                               │
│          ◜  ◝                 │  loader halus (4 dots / spinner merahUtama)
│                               │
│   Powered by GATECH           │  labelSmall, teksKetiga (footer)
└───────────────────────────────┘
```
**Flow:** tampil ≥ 1.4 dtk (minimum) → cek keamanan perangkat → cek sesi →
redirect (onboarding/login/dashboard). **Tanpa** background kompleks, tanpa animasi
berlebihan — fade-in logo + loader saja.
**State khusus:** bila perangkat diblok (VPN/rooted/emulator) → tampil layar blokir
**non-dismissible** (ikon line bahaya + judul + penjelasan sopan + tombol "Coba Lagi"/"Keluar").

---

### 3.2 Login / Register
```
┌───────────────────────────────┐
│ ‹                      [ID ▾] │  language selector (sheet, gaya pil)
│                               │
│  Masuk menggunakan            │  headlineSmall, teksUtama
│  akun Disdukcapil Anda        │
│  Gunakan NIK 16 digit, email, │  bodySmall, teksKedua
│  atau nomor HP terdaftar.     │
│                               │
│  NIK / Email / Nomor HP       │  IsianGarisBawah (label mengambang)
│  ───────────────────────────  │
│                               │
│  Kata Sandi              [👁]  │  toggle lihat sandi
│  ───────────────────────────  │
│                  Lupa sandi?  │  text link, merahUtama
│                               │
│  Dengan masuk, saya setuju    │  bodySmall + link S&K / Privasi
│  Syarat & Kebijakan Privasi.  │
│                               │
│  ╭───────────────────────────╮│
│  │          Masuk            ││  TombolUtama (pil, merahUtama)
│  ╰───────────────────────────╯│   → disabled s/d input valid
│        Belum punya akun? Daftar│
└───────────────────────────────┘
```
**Language selector (Telkomsel-style):** chip `ID ▾` di kanan atas → buka
**bottom sheet** putih (bukan dropdown OS) berisi pilihan **Indonesia / English**
dengan radio + bendera/inisial, sudut `xl`, handle bar di atas.

**Flow & state tombol:**
1. Field kosong/invalid → tombol **disabled** (`Warna.netral200`, teks `teksNonaktif`).
2. Input valid → tombol **aktif** (`merahUtama`).
3. Tap → field di-lock + **OverlayMuatGlobal** "Sedang memverifikasi akun…".
4. Sukses → dashboard / OTP. Gagal → **error inline di field** (validasi) atau
   **modal alert** (akun diblokir, rate-limit) — bukan toast.

**Register:** alur multi-langkah (lihat Stepper §3.5) dengan pola field & tombol sama.

---

### 3.3 Dashboard (fokus: Permohonan + AI)
```
┌───────────────────────────────┐
│ [logo] BAKUDAPA          [🔔²]│  header: logo+nama, bell+badge
│ Selamat pagi, Budi  ✓Terverif │  greeting + pill status akun
│                               │
│ ╭───────────────────────────╮ │
│ │ 📄  PERMOHONAN            ›│ │  Kartu fokus #1 (putih, border)
│ │ 2 permohonan aktif         │ │  live count (skeleton saat load)
│ │ ─────────────────────────  │ │
│ │ + Buat    ◷ Aktif    ▤ Riwayat │  3 aksi ringkas
│ ╰───────────────────────────╯ │
│                               │
│ ╭───────────────────────────╮ │
│ │ 🤖  BAKUDAPA AI          ›│ │  Kartu fokus #2
│ │ Tanya layanan, status,     │ │
│ │ & syarat kependudukan      │ │
│ │ ─────────────────────────  │ │
│ │ 💬 Mulai percakapan        │ │
│ ╰───────────────────────────╯ │
│                               │
├───────────────────────────────┤
│  ⌂      📄      🤖     🔔   👤 │  bottom-nav 5 tab (HugeIcons)
│ Dasbor Permhn   AI   Notif Profil
└───────────────────────────────┘
```
**Aturan:** **hanya 2 kartu fokus** + header. Tanpa grid 8-layanan, tanpa banner
statis, tanpa kartu warna-warni. White space lega antar kartu (`xl`).
**Flow:** kartu Permohonan → tab Permohonan; aksi "Buat" → katalog layanan.
Kartu AI → tab AI. Header bell → tab Notifikasi. Pull-to-refresh memuat ulang ringkasan.
**State:** angka aktif & notif pakai **skeleton** saat memuat; kosong → teks ajakan
("Mulai percakapan", "Belum ada permohonan").

---

### 3.4 Face Verification / Liveness
```
┌───────────────────────────────┐
│ ‹ Verifikasi Wajah    ◉ Siap  │  header + LencanaStatusLiveness (ikon+teks)
│ Posisikan wajah Anda di dalam │  arahan realtime (berubah per state)
│ lingkaran agar dapat diverif. │
│ ┌───────────────────────────┐ │
│ │        ╭───────╮          │ │  BingkaiWajahLiveness:
│ │      ╭─┤  👤   ├─╮        │ │  - lingkaran panduan
│ │      │ ╰───────╯ │        │ │  - warna tepi: netral→peringatan→sukses
│ │      ╰───────────╯        │ │  - bergeser ikut posisi wajah
│ │   (preview kamera)         │ │  - cincin progres saat tantangan
│ └───────────────────────────┘ │
│                               │
│  ╭───────────────────────────╮│
│  │     Posisikan Wajah       ││  tombol: DISABLED s/d wajah valid
│  ╰───────────────────────────╯│   → "Ambil Foto" (aktif) → "Memproses…"
└───────────────────────────────┘
```
**State machine (realtime, tanpa toast):**
`menyiapkan → tidakAda → (cahayaKurang / banyakWajah / terlaluJauh / terlaluDekat /
geserKeTengah / kameraGoyang) → siap`. Tiap state mengganti **(a)** kapsul status
(ikon+teks), **(b)** arahan kalimat manusiawi, **(c)** warna tepi lingkaran.
**Tombol** hanya aktif saat `siap` (backend-ready gating). Saat izin kamera ditolak →
panel pusat (ikon + arahan + "Ulangi"), bukan spinner menggantung.
**Liveness:** setelah "Mulai Verifikasi", tantangan acak (kedip/tengok/angguk) dipandu
timer + cincin progres; verifikasi final di server.

---

### 3.5 Policy / Agreement (Kirim Registrasi)
```
┌───────────────────────────────┐
│ Langkah 7 dari 7   Persetujuan│  StepperRegistrasi + progress
│ Persetujuan Kebijakan         │  headlineSmall
│ Baca dan setujui sebelum      │  bodySmall, teksKedua
│ mengirim registrasi.          │
│ ┌───────────────────────────┐ │
│ │ Kebijakan Privasi      ›   │ │  baris kebijakan → buka halaman baca
│ │ ☐ Saya telah membaca &     │ │  checkbox TER-DISABLE sampai dibaca
│ │   menyetujui               │ │  (aktif setelah scroll/buka penuh)
│ ├───────────────────────────┤ │
│ │ Syarat & Ketentuan     ›   │ │
│ │ ☐ Saya telah membaca &…    │ │
│ ├───────────────────────────┤ │
│ │ Pernyataan Kebenaran   ›   │ │
│ │ ☐ Saya menyatakan data…    │ │
│ └───────────────────────────┘ │
│  ╭───────────────────────────╮│
│  │     Kirim Registrasi      ││  DISABLED s/d semua checkbox dicentang
│  ╰───────────────────────────╯│
└───────────────────────────────┘
```
**Flow:** checkbox **terkunci** sampai user membuka & membaca dokumen (deteksi
scroll sampai bawah / kembali dari halaman baca). Tombol **Kirim Registrasi**
aktif hanya jika **semua** checkbox tercentang. Tap → **OverlayMuatGlobal**
"Sedang mengirim registrasi…" → halaman proses verifikasi AI → sukses.

---

### 3.6 Network / Maintenance Warning (global blocking)
```
        ╭───────────────────────╮
        │          ◔            │   ikon line (cloud-off / wrench), netral
        │                       │
        │   Layanan Sedang      │   titleLarge, teksUtama
        │   Dalam Pemeliharaan  │
        │                       │
        │ Mohon maaf, layanan   │   bodyMedium, teksKedua (sopan)
        │ sementara tidak       │
        │ tersedia. Silakan     │
        │ coba beberapa saat    │
        │ lagi.                 │
        │ ╭───────────────────╮ │
        │ │     Coba Lagi     │ │   TombolUtama
        │ ╰───────────────────╯ │
        ╰───────────────────────╯
   (dim #00000073 di belakang, TANPA warna mencolok)
```
**Aturan:** modal **blocking** (PopScope non-dismissible) lewat
`DialogAplikasi.tampilkanPemblokir`. Latar dim hitam transparan (bukan warna
mencolok). Ikon line, teks sopan & instruktif. Sama untuk **tidak ada koneksi**
(ikon cloud-off, "Periksa koneksi internet Anda", tombol "Coba Lagi").

---

### 3.7 Error / Loading States
```
LOADING (modal global)            ERROR (modal alert)            EMPTY (inline)
╭─────────────────────╮           ╭─────────────────────╮        ┌──────────────┐
│        ◜ ◝          │           │         ⚠           │        │      ▢       │
│   Sedang memproses  │           │  Gagal Memproses    │        │  Belum ada   │
│   data registrasi…  │           │  Permintaan         │        │  permohonan  │
│                     │           │ Terjadi kendala.    │        │ Pengajuan    │
│ (dim + blur,        │           │ Silakan coba lagi.  │        │ Anda muncul  │
│  TIDAK bisa ditutup)│           │ ╭─────────────────╮ │        │ di sini.     │
╰─────────────────────╯           │ │       OK        │ │        └──────────────┘
                                  │ ╰─────────────────╯ │        KondisiKosong
OverlayMuatGlobal                 ╰─────────────────────╯        (ikon+judul+pesan)
                                  DialogAplikasi.tampilkanAlert
```
**Aturan:**
- **Loading proses backend** → `OverlayMuatGlobal` (modal dim+blur, blocking, pesan
  spesifik: "Sedang memverifikasi akun…", "Mengunggah foto…", "Mengirim registrasi…").
  Tombol sumber **otomatis disabled** selama proses (cegah double-submit).
- **Error** → `DialogAplikasi.tampilkanAlert` (modal, ikon nada, pesan **ramah** —
  tidak pernah menampilkan stack trace / kode teknis).
- **Empty / list error** → inline `KondisiKosong` / `KondisiGalat` (+ "Coba Lagi").
- **Memuat list** → skeleton `PemuatKerlip`, bukan spinner kosong.
> Toast/snackbar **hanya** untuk konfirmasi ringan non-blocking (mis. "Bahasa diubah").
> Semua state penting memakai **modal/overlay**, sesuai arahan.

---

## 4. Catatan UX — Tombol, Feedback, Backend

**Tombol**
- 1 aksi **primer** per layar (pil `merahUtama`, tinggi 52). Sekunder = outline.
- **Disabled-until-valid**: form (login/registrasi), face-capture (wajah valid),
  persetujuan (semua dicentang). Disabled = `netral200` + teks `teksNonaktif`.
- **3-state**: Idle → Loading (spinner + label "Memproses…", tidak bisa ditekan) → hasil.
- Anti double-submit: flag `memuat` + guard mutex di provider.

**Feedback**
- Blocking → modal/overlay clean (§3.6, §3.7). Non-blocking ringan → toast (jarang).
- Realtime (liveness, validasi field) → inline + kapsul status, **tanpa** latar warna ber-opacity.
- Pesan selalu **sopan, instruktif, bilingual** (lewat `Teks`), tanpa istilah teknis.

**Backend-ready**
- Aksi yang menyentuh server selalu lewat `OverlayMuatGlobal.jalankan()` → otomatis
  loading-modal + disable + tangani sukses/gagal.
- Tombol mencerminkan kesiapan: face-capture aktif hanya jika engine melaporkan wajah
  valid; "Kirim" aktif hanya jika syarat terpenuhi.
- Error backend dipetakan ke pesan ramah (`pesanRamah()` / hierarki `Kesalahan`),
  jangan tampilkan `e.toString()`.

**Animasi (halus, fungsional)**
- Transisi state: `AnimatedSwitcher` 220–320ms, fade + slide kecil (offset 0.25).
- Progress/stepper: `TweenAnimationBuilder` 350ms `easeOutCubic`.
- Lingkaran liveness: pulse 2.2s, pergeseran offset ter-smooth (EMA).
- Hindari animasi panjang/berlebihan — semua ≤ ~350ms, mendukung pemahaman, bukan dekorasi.

**Bilingual**
- Sumber tunggal `Teks` (abstrak) + `TeksId`/`TeksEn` (zero-drift). Tambah key baru di
  ketiga file. Method berparameter untuk angka/plural (mis. `langkahXDariY(i, n)`).

---

## 5. Ringkasan "Boleh / Dilarang"

| ✅ Boleh | ❌ Dilarang |
|---|---|
| Permukaan putih solid + border tipis | Latar berwarna opacity rendah di belakang teks |
| 1 warna aksen (merah) + netral | Warna-warni mencolok / banyak aksen |
| Shadow 1–2 lapis sangat tipis | Shadow berat, neumorphism, glassmorphism |
| White space lega, hierarki jelas | Layar padat, banyak elemen bersaing |
| Ikon line HugeIcons | Ikon filled warna-warni |
| Modal/overlay clean untuk state | Toast/snackbar spam untuk semua hal |
| Tombol disabled s/d valid | Tombol selalu aktif lalu error |
| Teks `Teks` ID/EN, sopan | Hardcode string / istilah teknis ke user |
