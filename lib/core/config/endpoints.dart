class Endpoints {
  Endpoints._();

  static const String sistemMaintenance = '/sistem/maintenance';
  static const String sistemPing = '/sistem/ping';
  static const String sistemKonfigurasi = '/sistem/konfigurasi';

  static const String authMasuk = '/auth/masuk';
  static const String authKeluar = '/auth/keluar';
  static const String authSegarkanToken = '/auth/segarkan-token';
  static const String authSaya = '/auth/saya';
  static const String authOtpVerifikasi = '/auth/otp/verifikasi';
  static const String authOtpKirimUlang = '/auth/otp/kirim-ulang';
  static const String authLupaKataSandi = '/auth/lupa-kata-sandi';
  static const String authResetKataSandi = '/auth/reset-kata-sandi';
  static const String authPerangkat = '/auth/perangkat';
  static const String authPerangkatRiwayat = '/auth/perangkat/riwayat';
  static const String authCabutDanMasuk = '/auth/perangkat/cabut-dan-masuk';
  static String authCabutPerangkat(String sesiId) => '/auth/perangkat/$sesiId';

  static const String wilayahKabupaten = '/wilayah/kabupaten';
  static const String wilayahKecamatan = '/wilayah/kecamatan';
  static const String wilayahDesa = '/wilayah/desa';

  static const String registrasiMulai = '/registrasi/mulai';
  static const String registrasiIdentitas = '/registrasi/identitas';
  static const String registrasiFotoDokumen = '/registrasi/foto-dokumen';
  static const String registrasiFotoWajah = '/registrasi/foto-wajah';
  static const String registrasiLiveness = '/registrasi/liveness';
  static const String registrasiPersetujuan = '/registrasi/persetujuan';
  static const String registrasiFinalkan = '/registrasi/finalkan';
  static const String registrasiProgres = '/registrasi/progres';

  static const String uploadInisiasi = '/upload/inisiasi';
  static const String uploadKonfirmasi = '/upload/konfirmasi';

  static const String layanan = '/layanan';
  static String layananDetail(String kode) => '/layanan/$kode';
  static String layananAjukan(String kode) => '/layanan/$kode/ajukan';

  static const String permohonan = '/permohonan';
  static String permohonanDetail(String id) => '/permohonan/$id';
  static String permohonanDokumen(String id) => '/permohonan/$id/dokumen';
  static String permohonanDokumenHasil(String id) =>
      '/permohonan/$id/dokumen-hasil';
  static String permohonanDokumenHasilDetail(String id, String dokumenId) =>
      '/permohonan/$id/dokumen-hasil/$dokumenId';

  static const String profil = '/profil/';
  static const String profilBahasa = '/profil/bahasa';
  static const String profilKataSandi = '/profil/kata-sandi';
  static const String profilKredensial = '/profil/kredensial';
  static const String profilCekUsername = '/profil/cek-username';
  static const String profilRingkasanStatus = '/profil/ringkasan-status';

  static const String pemberitahuan = '/pemberitahuan';
  static const String pemberitahuanJumlahBelumDibaca =
      '/pemberitahuan/jumlah-belum-dibaca';
  static const String pemberitahuanTandaiSemua =
      '/pemberitahuan/tandai-semua-dibaca';
  static String pemberitahuanTandaiDibaca(String id) =>
      '/pemberitahuan/$id/tandai-dibaca';

  static const String kebijakan = '/kebijakan';
  static String kebijakanDetail(String jenis) => '/kebijakan/$jenis';

  static const String biometrikAudit = '/biometrik/audit';
  static const String biometrikVerifikasiWajah = '/biometrik/verifikasi-wajah';
  static const String biometrikStatusPerangkat = '/biometrik/status-perangkat';

  static const String aiTanya = '/ai/tanya';
  static String aiPesan(String id) => '/pesan/$id';
  static String aiPesanStream(String id) => '/pesan/$id/stream';

  static const String aktivitasLog = '/aktivitas/log';
}
