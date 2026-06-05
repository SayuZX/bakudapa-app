class Endpoints {
  Endpoints._();

  static const String sistemPing = '/sistem/ping';
  static const String sistemMaintenance = '/sistem/maintenance';
  static const String sistemKonfigurasi = '/sistem/konfigurasi';

  static const String authMasuk = '/auth/masuk';
  static const String authKeluar = '/auth/keluar';
  static const String authSegarkanToken = '/auth/segarkan-token';
  static const String authSaya = '/auth/saya';
  static const String authOtpVerifikasi = '/auth/otp/verifikasi';
  static const String authOtpKirimUlang = '/auth/otp/kirim-ulang';
  static const String authLupaKataSandi = '/auth/lupa-kata-sandi';
  static const String authResetKataSandi = '/auth/reset-kata-sandi';

  static const String registrasiMulai = '/registrasi/mulai';
  static const String registrasiFotoDokumen = '/registrasi/foto-dokumen';
  static const String registrasiFotoWajah = '/registrasi/foto-wajah';
  static const String registrasiLiveness = '/registrasi/liveness';
  static const String registrasiTantanganSuara = '/registrasi/tantangan-suara';
  static const String registrasiSuara = '/registrasi/suara';
  static const String registrasiSidikJari = '/registrasi/sidik-jari';
  static const String registrasiFinalkan = '/registrasi/finalkan';
  static const String registrasiProgres = '/registrasi/progres';

  static const String profil = '/profil';
  static const String profilBahasa = '/profil/bahasa';
  static const String profilKataSandi = '/profil/kata-sandi';
  static const String profilRingkasanStatus = '/profil/ringkasan-status';

  static const String layanan = '/layanan';
  static String layananDetail(String kode) => '/layanan/$kode';
  static String layananAjukan(String kode) => '/layanan/$kode/ajukan';

  static const String permohonan = '/permohonan';
  static String permohonanDetail(String id) => '/permohonan/$id';
  static String permohonanDokumen(String id) => '/permohonan/$id/dokumen';
  static String permohonanDokumenHasil(String id) => '/permohonan/$id/dokumen-hasil';
  static String permohonanDokumenHasilDetail(String id, String dokumenId) =>
      '/permohonan/$id/dokumen-hasil/$dokumenId';

  static const String pemberitahuan = '/pemberitahuan';
  static const String pemberitahuanUnread = '/pemberitahuan/jumlah-belum-dibaca';
  static String pemberitahuanMarkRead(String id) => '/pemberitahuan/$id/tandai-dibaca';
  static const String pemberitahuanMarkAllRead = '/pemberitahuan/tandai-semua-dibaca';

  static const String kebijakan = '/kebijakan';
  static String kebijakanDetail(String jenis) => '/kebijakan/$jenis';
  static String kebijakanVersi(String jenis, String versi) => '/kebijakan/$jenis/versi/$versi';
  static const String persetujuanSaya = '/persetujuan-saya';

  static const String biometrikAudit = '/biometrik/audit';
  static const String biometrikStatusPerangkat = '/biometrik/status-perangkat';
  static const String biometrikVerifikasiWajah = '/biometrik/verifikasi-wajah';

  static const String uploadInisiasi = '/upload/inisiasi';
  static const String uploadKonfirmasi = '/upload/konfirmasi';

  static const String aiTanya = '/ai/tanya';
}
