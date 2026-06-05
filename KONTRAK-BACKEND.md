# Kontrak Backend — BAKUDAPA MOBILE

Dokumen ini berisi kebutuhan backend yang muncul dari pengembangan aplikasi mobile
BAKUDAPA (Disdukcapil Provinsi Maluku Utara). Klien **sudah diimplementasikan**
dengan *graceful degradation* (tetap jalan walau field baru belum ada), jadi tim
backend dapat mengimplementasikan ini secara bertahap.

Semua contoh JSON di bawah adalah **kontrak nyata** yang sudah dipakai/diparse oleh
aplikasi Flutter. Mohon ikuti nama field persis (klien menerima alias snake_case
Indonesia **dan** Inggris di beberapa tempat — ditandai di bawah).

Base URL produksi: `https://bakudapa.malutprov.go.id/api`

---

## 0. Amplop Respons & Kode Error (FONDASI — semua endpoint)

Klien mem-*unwrap* semua respons lewat satu interceptor. Tolong konsisten.

### Sukses
```json
{ "success": true, "data": { ... } }
```
Klien mengambil `data`. Untuk list berhalaman, sertakan `meta`:
```json
{ "success": true, "data": [ ... ], "meta": { "halaman": 1, "total_halaman": 5, "total_item": 73 } }
```

### Error (semua status non-2xx)
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "title": "Judul opsional",
    "message": "Pesan ramah untuk pengguna (Bahasa Indonesia / sesuai Accept-Language)",
    "details": { "field": ["pesan validasi"], "retry_after_seconds": 30, "terblokir_sampai": "ISO8601" }
  }
}
```

**Kode error yang DIKENALI klien** (di luar ini → dianggap error server generik):

| code | Kapan dipakai |
|---|---|
| `VALIDATION_ERROR` | 400/422, sertakan `details` per-field |
| `UNAUTHORIZED` | 401 / sesi berakhir |
| `INVALID_CREDENTIALS` | login salah |
| `ACCOUNT_BLOCKED` | akun terkunci, sertakan `details.terblokir_sampai` (ISO8601) |
| `NOT_FOUND` | 404 |
| `CONFLICT` | data sudah terdaftar |
| `RATE_LIMITED` | sertakan `details.retry_after_seconds` (int) |
| `MAINTENANCE_MODE` | mode pemeliharaan (lihat §6) |
| `AI_UNAVAILABLE` | asisten AI nonaktif sementara |
| `AI_ERROR` | layanan AI terganggu |
| `VISION_ERROR` | analisis gambar gagal |
| `FACE_SERVICE_ERROR` | layanan verifikasi wajah bermasalah |
| `FACE_PHOTO_BLOCKED` | percobaan foto wajah habis |
| `RESOURCE_EMPTY` | sumber data belum tersedia (mis. tantangan suara kosong) |

> Header bahasa: klien mengirim `Accept-Language: id|en`. `message` sebaiknya
> mengikuti bahasa ini.

---

## 1. AI Smart Assistant — `POST /ai/tanya`  ⭐ PRIORITAS TINGGI

Klien sudah membangun asisten kontekstual. Saat ini backend hanya membalas teks;
agar fitur penuh aktif, endpoint harus menerima **konteks** dan mengembalikan
**aksi + saran + sinyal eskalasi**.

### Request
```json
{
  "pesan": "Apa status permohonan KK saya?",
  "sesi_id": "abc123",          // opsional; kosong/absen pada pesan pertama
  "lanjutkan": true,            // opsional; true = lanjutkan jawaban yang terpotong
  "konteks": {                  // opsional; dikirim klien tiap pesan
    "locale": "id",
    "pengguna": {
      "nama": "Budi Santoso",
      "kab_kota": "Kota Ternate",
      "kecamatan": "Ternate Tengah",
      "terverifikasi": true
    },
    "ringkasan_permohonan": { "menunggu": 1, "berjalan": 2, "selesai": 5 }
  }
}
```

**PENTING (privasi/keamanan):**
- `konteks.pengguna` **TIDAK** memuat NIK/no.KK/no.HP/email — sengaja. **Identitas
  pengguna WAJIB diturunkan dari Bearer token**, bukan dari isi `konteks`/`pesan`.
- Jangan menyimpan/melatih model dengan isi percakapan tanpa kebijakan retensi yang
  jelas. Mohon konfirmasi kebijakan retensi & PII untuk endpoint ini.

### Response (200)
```json
{
  "sesi_id": "abc123",
  "balasan": "Permohonan **KK** Anda sedang diproses...",   // markdown
  "selesai": true,                  // false = jawaban terpotong → klien tampilkan tombol "Lanjutkan"
  "done_reason": "stop",            // opsional
  "token_output": 128,              // opsional (telemetри)
  "latensi_ms": 850,                // opsional
  "aksi": [
    { "tipe": "lihat_status",   "label": "Lihat status KK", "target": "<id_permohonan>" },
    { "tipe": "buka_layanan",   "label": "Buat Kartu Keluarga", "target": "kk" }
  ],
  "saran": ["Apa syarat pindah domisili?", "Berapa lama proses KK?"],
  "butuh_operator": false           // true → klien tampilkan tombol "Hubungi Operator"
}
```

**Skema `aksi[]`** (klien memvalidasi & men-deep-link; target di-whitelist klien):

| `tipe` (terima kedua alias) | `target` berisi | Aksi di klien |
|---|---|---|
| `buka_layanan` / `open_service` | **kode layanan** (mis. `kk`, `ktp_ikd`, `akta_lahir`) | buka form layanan |
| `lihat_status` / `view_status` | **id permohonan** | buka detail permohonan |
| `lihat_permohonan` / `view_requests` | — | buka tab Permohonan |
| `mulai_pengaduan` / `start_complaint` | — | mulai alur pengaduan |
| `buka_faq` / `open_faq` | kode/slug FAQ (opsional) | buka FAQ |
| `hubungi_operator` / `contact_operator` | — | buka Pusat Bantuan |

> Alias `butuh_operator` yang diterima klien: `butuh_operator` **atau** `needs_human`
> **atau** `escalate` (boolean).
> Alias `aksi`/`actions`, `saran`/`suggestions` keduanya diterima.

### Safety layer (WAJIB sisi server)
1. **Jangan berhalusinasi** data kependudukan / status permohonan / dasar hukum.
   Jawaban tentang status harus berasal dari data nyata pengguna (via token).
2. Bila tidak yakin / di luar cakupan → set `butuh_operator: true` dan arahkan ke
   operator, jangan mengarang.
3. Timeout: klien memberi **receiveTimeout 90 detik** untuk endpoint ini.
4. Saat AI nonaktif → balas error `AI_UNAVAILABLE`; saat terganggu → `AI_ERROR`.

---

## 2. Verifikasi Liveness — server menjadi otoritas  ⭐ PRIORITAS TINGGI

Karena keterbatasan Android (tidak bisa deteksi-realtime + rekam-video sekaligus),
klien memakai strategi **time-guided recording**: klien memandu tantangan acak
berbasis timer lalu **mengunggah video + metadata**. **Verifikasi tantangan &
anti-spoofing WAJIB dilakukan di server** dari video tersebut.

### `POST /registrasi/liveness` (multipart/form-data)
Header: `Authorization`/registration-token (lihat §4), `X-Idempotency-Key`.

| Field | Tipe | Keterangan |
|---|---|---|
| `video` | file (mp4) | rekaman liveness penuh |
| `challenges` | string | kode tantangan dipisah koma, urut: mis. `BLINK,TURN_LEFT,NOD` |
| `segmen_tantangan` | string (JSON) | array segmen, lihat di bawah |
| `tangkapan[0..n]` | file (png) | snapshot per tantangan (bukti tambahan) |

**`segmen_tantangan`** = array; tiap item menandai kapan tantangan ke-i muncul di
video (ms relatif terhadap awal rekaman), kode tantangan, dan filter overlay yang
dipakai (bukti real-time):
```json
[
  { "kode_tantangan": "BLINK", "dimulai_ms": 0,    "selesai_ms": 2500, "filter": "..." },
  { "kode_tantangan": "NOD",   "dimulai_ms": 5000, "selesai_ms": 7500, "filter": "..." }
]
```

Kode tantangan yang dipakai klien: `BLINK`, `OPEN_MOUTH`, `SMILE`, `TURN_LEFT`,
`TURN_RIGHT`, `NOD`.

**Tugas server:**
1. Verifikasi tiap tantangan benar dilakukan pada segmen waktunya di video.
2. **Anti-spoofing**: deteksi foto-di-layar / video-replay / wajah statis
   (gerakan, kedip, head-pose, tekstur/kedalaman bila tersedia).
3. Balas sukses/gagal lewat amplop standar (gagal → `FACE_SERVICE_ERROR` atau
   `VALIDATION_ERROR` dengan pesan ramah).

---

## 3. Verifikasi Wajah (Foto) & Vision

- `POST /registrasi/foto-wajah` (multipart, field `face`/foto) — verifikasi
  kecocokan wajah vs foto dokumen; gagal/terblokir → `FACE_PHOTO_BLOCKED` (percobaan
  habis) atau `FACE_SERVICE_ERROR`.
- `POST /registrasi/foto-dokumen` (multipart, field `document`) — OCR/validasi KTP.
- Error analisis gambar → `VISION_ERROR`.

---

## 4. Endpoint Registrasi — ⚠️ MASALAH 404 (perlu disepakati path)

Saat pengujian, klien menerima **404** pada beberapa endpoint registrasi karena
**ketidaksesuaian path** antara klien dan backend:

- Konstanta `Endpoints` di klien memakai **`/registrasi/*`** (Bahasa Indonesia),
  TAPI sebagian kode klien masih *hardcode* **`/auth/register/*`** (Inggris) →
  inilah yang **404**.

**Mohon sepakati path kanonik.** Rekomendasi: gunakan **`/registrasi/*`** (konsisten
dengan `Endpoints`). Daftar fungsi yang dibutuhkan:

| Fungsi | Path rekomendasi | Method |
|---|---|---|
| Mulai sesi registrasi (kembalikan `token`/`session_token`) | `/registrasi/mulai` | POST |
| Kirim identitas | `/registrasi/identitas` | POST |
| Unggah foto dokumen | `/registrasi/foto-dokumen` | POST (multipart) |
| Unggah foto wajah | `/registrasi/foto-wajah` | POST (multipart) |
| Unggah video liveness | `/registrasi/liveness` | POST (multipart) |
| Ambil tantangan suara | `/registrasi/tantangan-suara` | GET |
| Unggah rekaman suara | `/registrasi/suara` | POST (multipart) |
| Verifikasi sidik jari | `/registrasi/sidik-jari` | POST |
| Persetujuan kebijakan | `/registrasi/persetujuan` | POST |
| Submit final | `/registrasi/finalkan` | POST |

> **Catatan:** sisi klien akan saya selaraskan ke path yang disepakati (saat ini
> beberapa masih `/auth/register/*`). Konfirmasikan path final agar tidak 404.

**Sidik jari (device biometric)** — body JSON:
```json
{ "registration_session_id": "...", "biometric_type": "fingerprint",
  "biometric_available": true, "biometric_verified": true,
  "verified_at": "ISO8601", "source": "device", "device_metadata": { ... } }
```
> Path *scanner eksternal* (`encrypted_template`) **dinonaktifkan di klien** sampai
> enkripsi template biometrik nyata tersedia — jangan andalkan field itu dulu.

---

## 5. Idempotency (cegah duplikasi submit)

Klien mengirim header **`X-Idempotency-Key`** (UUID per submission) pada endpoint
mutasi penting (submit permohonan, registrasi sidik jari, dan disarankan untuk
semua POST registrasi + `/permohonan` ajukan).

**Server WAJIB men-dedup** berdasarkan key ini: request dengan key sama → kembalikan
hasil yang sama, jangan proses dua kali. Ini mencegah data ganda pada jaringan tidak
stabil di Maluku Utara.

---

## 6. Lain-lain

**Maintenance** — agar tidak salah-positif: kirim `MAINTENANCE_MODE` **hanya** saat
benar-benar pemeliharaan (body `error.code = MAINTENANCE_MODE`, boleh via 503).
**503 transien biasa (gateway)** jangan diberi code itu — cukup error server biasa,
supaya app tidak mengunci layar ke halaman maintenance.

**Notifikasi** — sediakan `GET /pemberitahuan/jumlah-belum-dibaca` (badge tab),
list `GET /pemberitahuan` berhalaman (`meta`), dan idealnya **FCM push** untuk
status real-time (saat ini klien polling 45 detik).

**Refresh token** — `/auth/segarkan-token` (rotasi token; klien sudah single-flight
& retry-once). Pastikan rotasi meng-*invalidate* token lama.

**Cert pinning (rencana hardening)** — mohon sediakan **SPKI hash** sertifikat
`bakudapa.malutprov.go.id` (primary + backup) agar app bisa pin TLS, plus prosedur
rotasi.

---

## Prioritas yang disarankan
1. **§4** Sepakati path registrasi & deploy (hilangkan 404) — blocker registrasi.
2. **§0** Amplop & kode error konsisten — fondasi semua fitur.
3. **§1** Kontrak AI `/ai/tanya` (konteks + aksi + safety) — fitur asisten.
4. **§2** Verifikasi liveness server-side + anti-spoofing — keamanan KYC.
5. **§5** Idempotency, **§6** maintenance/FCM/SPKI.
