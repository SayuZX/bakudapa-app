enum LangkahDip {
  persiapan,
  pengambilan,
  praproses,
  thresholding,
  deteksiTepi,
  peningkatanKualitas,
  ekstraksiPola,
  validasiHasil,
  enkripsiKirim,
  selesai,
}

class DefinisiLangkahDip {
  const DefinisiLangkahDip({
    required this.langkah,
    required this.judulId,
    required this.judulEn,
    required this.deskripsiId,
    required this.deskripsiEn,
    required this.durasi,
  });

  final LangkahDip langkah;
  final String judulId;
  final String judulEn;
  final String deskripsiId;
  final String deskripsiEn;
  final Duration durasi;
}

const List<DefinisiLangkahDip> daftarLangkahDip = [
  DefinisiLangkahDip(
    langkah: LangkahDip.persiapan,
    judulId: 'Menyiapkan pemindaian',
    judulEn: 'Preparing scan',
    deskripsiId: 'Mempersiapkan sensor sidik jari dan saluran aman.',
    deskripsiEn: 'Initializing fingerprint sensor and secure channel.',
    durasi: Duration(milliseconds: 900),
  ),
  DefinisiLangkahDip(
    langkah: LangkahDip.pengambilan,
    judulId: 'Mengambil citra sidik jari',
    judulEn: 'Capturing fingerprint image',
    deskripsiId: 'Mengakuisisi pola sidik jari dari sensor perangkat.',
    deskripsiEn: 'Acquiring fingerprint pattern from device sensor.',
    durasi: Duration(milliseconds: 1400),
  ),
  DefinisiLangkahDip(
    langkah: LangkahDip.praproses,
    judulId: 'Praproses citra',
    judulEn: 'Image preprocessing',
    deskripsiId: 'Normalisasi kontras dan reduksi derau citra masukan.',
    deskripsiEn: 'Contrast normalization and noise reduction.',
    durasi: Duration(milliseconds: 900),
  ),
  DefinisiLangkahDip(
    langkah: LangkahDip.thresholding,
    judulId: 'Thresholding / Binarisasi',
    judulEn: 'Thresholding / Binarization',
    deskripsiId: 'Konversi citra ke biner menggunakan adaptive thresholding.',
    deskripsiEn: 'Converting image to binary via adaptive thresholding.',
    durasi: Duration(milliseconds: 1000),
  ),
  DefinisiLangkahDip(
    langkah: LangkahDip.deteksiTepi,
    judulId: 'Deteksi tepi (Sobel · Prewitt · Roberts)',
    judulEn: 'Edge detection (Sobel · Prewitt · Roberts)',
    deskripsiId:
        'Mengekstrak gradien tepi pola sidik jari secara multi-operator.',
    deskripsiEn:
        'Extracting ridge edge gradients via multi-operator pipeline.',
    durasi: Duration(milliseconds: 1500),
  ),
  DefinisiLangkahDip(
    langkah: LangkahDip.peningkatanKualitas,
    judulId: 'Peningkatan kualitas citra',
    judulEn: 'Image quality enhancement',
    deskripsiId: 'Penajaman ridge dan penghalusan derau berbasis filter Gabor.',
    deskripsiEn: 'Ridge sharpening and Gabor-filter smoothing.',
    durasi: Duration(milliseconds: 1000),
  ),
  DefinisiLangkahDip(
    langkah: LangkahDip.ekstraksiPola,
    judulId: 'Ekstraksi pola ridge',
    judulEn: 'Ridge pattern extraction',
    deskripsiId: 'Mendeteksi titik minutiae untuk dasar pencocokan.',
    deskripsiEn: 'Detecting minutiae points for matching.',
    durasi: Duration(milliseconds: 1100),
  ),
  DefinisiLangkahDip(
    langkah: LangkahDip.validasiHasil,
    judulId: 'Validasi hasil',
    judulEn: 'Result validation',
    deskripsiId: 'Memeriksa konsistensi pola dan kualitas keseluruhan.',
    deskripsiEn: 'Checking pattern consistency and overall quality.',
    durasi: Duration(milliseconds: 800),
  ),
  DefinisiLangkahDip(
    langkah: LangkahDip.enkripsiKirim,
    judulId: 'Enkripsi & pengiriman aman',
    judulEn: 'Secure encryption & transmission',
    deskripsiId: 'Mengenkripsi metadata verifikasi dan mengirim ke server.',
    deskripsiEn: 'Encrypting verification metadata and sending to server.',
    durasi: Duration(milliseconds: 1200),
  ),
  DefinisiLangkahDip(
    langkah: LangkahDip.selesai,
    judulId: 'Sidik jari berhasil diproses',
    judulEn: 'Fingerprint successfully processed',
    deskripsiId: 'Menunggu verifikasi operator.',
    deskripsiEn: 'Awaiting operator verification.',
    durasi: Duration(milliseconds: 500),
  ),
];
