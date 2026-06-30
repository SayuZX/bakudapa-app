import '../../shared/models/perangkat_aktif.dart';
import '../localization/teks.dart';

sealed class Kesalahan implements Exception {
  const Kesalahan(this.pesan, {this.kode});

  final String pesan;
  final String? kode;

  @override
  String toString() => 'Kesalahan($kode): $pesan';
}

String pesanRamah(Object? e, {required String fallback, Teks? teks}) {
  if (e is! Kesalahan) return fallback;
  final pesan = teks?.pesanKesalahan(e.kode);
  if (pesan != null) return pesan;
  return e.pesan.isNotEmpty ? e.pesan : fallback;
}

class KesalahanJaringan extends Kesalahan {
  const KesalahanJaringan([super.pesan = 'Periksa koneksi internet Anda.'])
    : super(kode: 'JARINGAN');
}

class KesalahanBatasWaktu extends Kesalahan {
  const KesalahanBatasWaktu([
    super.pesan = 'Permintaan terlalu lama. Silakan coba lagi.',
  ]) : super(kode: 'BATAS_WAKTU');
}

class KesalahanTidakBerwenang extends Kesalahan {
  const KesalahanTidakBerwenang([
    super.pesan = 'Sesi Anda telah berakhir. Silakan masuk kembali.',
  ]) : super(kode: 'TIDAK_BERWENANG');
}

class KesalahanDilarang extends Kesalahan {
  const KesalahanDilarang([
    super.pesan = 'Anda tidak memiliki akses untuk tindakan ini.',
  ]) : super(kode: 'DILARANG');
}

class KesalahanTidakDitemukan extends Kesalahan {
  const KesalahanTidakDitemukan([super.pesan = 'Data tidak ditemukan.'])
    : super(kode: 'TIDAK_DITEMUKAN');
}

class KesalahanValidasi extends Kesalahan {
  const KesalahanValidasi(super.pesan, {this.kesalahanRuas})
    : super(kode: 'VALIDASI');

  final Map<String, String>? kesalahanRuas;
}

class KesalahanBatasFrekuensi extends Kesalahan {
  const KesalahanBatasFrekuensi([
    super.pesan = 'Terlalu banyak percobaan. Coba lagi nanti.',
  ]) : super(kode: 'BATAS_FREKUENSI');
}

class KesalahanServer extends Kesalahan {
  const KesalahanServer([
    super.pesan = 'Layanan sedang bermasalah. Mohon coba kembali.',
  ]) : super(kode: 'SERVER');
}

class KesalahanSimpanan extends Kesalahan {
  const KesalahanSimpanan([super.pesan = 'Gagal mengakses penyimpanan aman.'])
    : super(kode: 'SIMPANAN');
}

class KesalahanUnggah extends Kesalahan {
  const KesalahanUnggah(super.pesan) : super(kode: 'UNGGAH');
}

class KesalahanTakDikenal extends Kesalahan {
  const KesalahanTakDikenal([super.pesan = 'Terjadi kesalahan tak terduga.'])
    : super(kode: 'TAK_DIKENAL');
}

class KesalahanMaintenance extends Kesalahan {
  const KesalahanMaintenance({
    String pesan = 'Layanan sedang dalam pemeliharaan.',
    this.judul,
  }) : super(pesan, kode: 'MAINTENANCE_MODE');

  final String? judul;
}

class KesalahanKredensialSalah extends Kesalahan {
  const KesalahanKredensialSalah([
    super.pesan = 'Identitas atau kata sandi salah.',
  ]) : super(kode: 'INVALID_CREDENTIALS');
}

class KesalahanAkunDiblokir extends Kesalahan {
  const KesalahanAkunDiblokir({
    String pesan = 'Akun terblokir sementara. Hubungi CS Bantuan',
    this.terblokirSampai,
  }) : super(pesan, kode: 'ACCOUNT_BLOCKED');

  final DateTime? terblokirSampai;
}

class KesalahanKonflik extends Kesalahan {
  const KesalahanKonflik([super.pesan = 'Data sudah terdaftar.'])
    : super(kode: 'CONFLICT');
}

class KesalahanAiTidakTersedia extends Kesalahan {
  const KesalahanAiTidakTersedia([
    super.pesan = 'Asisten AI sedang tidak tersedia.',
  ]) : super(kode: 'AI_UNAVAILABLE');
}

class KesalahanAi extends Kesalahan {
  const KesalahanAi([super.pesan = 'Layanan AI sedang terganggu.'])
    : super(kode: 'AI_ERROR');
}

class KesalahanVisi extends Kesalahan {
  const KesalahanVisi([super.pesan = 'Analisis gambar gagal. Coba lagi nanti.'])
    : super(kode: 'VISION_ERROR');
}

class KesalahanLayananWajah extends Kesalahan {
  const KesalahanLayananWajah([
    super.pesan = 'Layanan verifikasi wajah sedang bermasalah.',
  ]) : super(kode: 'FACE_SERVICE_ERROR');
}

class KesalahanFotoWajahDiblokir extends Kesalahan {
  const KesalahanFotoWajahDiblokir([
    super.pesan =
        'Percobaan foto wajah habis. Datang ke loket Disdukcapil untuk verifikasi langsung.',
  ]) : super(kode: 'FACE_PHOTO_BLOCKED');
}

class KesalahanSumberKosong extends Kesalahan {
  const KesalahanSumberKosong([super.pesan = 'Sumber data belum tersedia.'])
    : super(kode: 'RESOURCE_EMPTY');
}

class KesalahanBatasPerangkat extends Kesalahan {
  const KesalahanBatasPerangkat({
    String pesan = 'Akun sudah digunakan pada 2 perangkat aktif.',
    this.perangkatAktif = const [],
    this.batas,
  }) : super(pesan, kode: 'BATAS_PERANGKAT_TERCAPAI');

  final List<PerangkatAktif> perangkatAktif;
  final int? batas;
}

class KesalahanSesiTidakValid extends Kesalahan {
  const KesalahanSesiTidakValid([super.pesan = 'Perangkat yang dipilih tidak valid.'])
    : super(kode: 'SESI_TIDAK_VALID');
}

class KesalahanSesiSudahTidakAktif extends Kesalahan {
  const KesalahanSesiSudahTidakAktif([
    super.pesan = 'Perangkat sudah tidak aktif.',
  ]) : super(kode: 'SESI_SUDAH_TIDAK_AKTIF');
}

class KesalahanBatasFrekuensiDenganRetry extends Kesalahan {
  const KesalahanBatasFrekuensiDenganRetry({
    String pesan = 'Terlalu banyak percobaan. Coba lagi nanti.',
    this.detikUlang,
  }) : super(pesan, kode: 'RATE_LIMITED');

  final int? detikUlang;
}

class KodeKesalahanBackend {
  const KodeKesalahanBackend._();

  static const validationError = 'VALIDATION_ERROR';
  static const validationFailed = 'VALIDATION_FAILED';
  static const badRequest = 'BAD_REQUEST';
  static const unauthorized = 'UNAUTHORIZED';
  static const forbidden = 'FORBIDDEN';
  static const invalidCredentials = 'INVALID_CREDENTIALS';
  static const accountBlocked = 'ACCOUNT_BLOCKED';
  static const notFound = 'NOT_FOUND';
  static const conflict = 'CONFLICT';
  static const duplicateRecord = 'DUPLICATE_RECORD';
  static const payloadTooLarge = 'PAYLOAD_TOO_LARGE';
  static const rateLimited = 'RATE_LIMITED';
  static const internalServerError = 'INTERNAL_SERVER_ERROR';
  static const serviceUnavailable = 'SERVICE_UNAVAILABLE';
  static const maintenanceMode = 'MAINTENANCE_MODE';
  static const aiUnavailable = 'AI_UNAVAILABLE';
  static const aiError = 'AI_ERROR';
  static const visionError = 'VISION_ERROR';
  static const faceServiceError = 'FACE_SERVICE_ERROR';
  static const facePhotoBlocked = 'FACE_PHOTO_BLOCKED';
  static const resourceEmpty = 'RESOURCE_EMPTY';
  static const batasPerangkatTercapai = 'BATAS_PERANGKAT_TERCAPAI';
  static const sessionRevoked = 'SESSION_REVOKED';
  static const invalidRefreshToken = 'INVALID_REFRESH_TOKEN';
  static const sesiTidakValid = 'SESI_TIDAK_VALID';
  static const sesiSudahTidakAktif = 'SESI_SUDAH_TIDAK_AKTIF';
  static const storageNotConfigured = 'STORAGE_NOT_CONFIGURED';
  static const storageError = 'STORAGE_ERROR';
}
