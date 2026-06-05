import 'teks.dart';

class TeksId extends Teks {
  const TeksId();
  @override
  String get lanjut => 'Lanjut';
  @override
  String get lanjutkan => 'Lanjutkan';
  @override
  String get kembali => 'Kembali';
  @override
  String get selesai => 'Selesai';
  @override
  String get batal => 'Batal';
  @override
  String get setuju => 'Setuju';
  @override
  String get sayaMengertiDanSetuju => 'Saya Mengerti dan Setuju';
  @override
  String get cobaLagi => 'Coba Lagi';
  @override
  String get tetapLanjutkan => 'Tetap Lanjutkan';
  @override
  String get prosesVerifikasiAiJudul => 'Verifikasi sedang berjalan';
  @override
  String get prosesVerifikasiAiSub =>
      'Sistem sedang memeriksa keaslian dan kelengkapan data biometrik Anda. Mohon tunggu sebentar.';
  @override
  String get langkahAiKirimIdentitas => 'Mengirim data identitas...';
  @override
  String get langkahAiKirimDokumen => 'Mengunggah berkas verifikasi...';
  @override
  String get langkahAiAnalisisFoto => 'Menganalisis kecocokan foto wajah...';
  @override
  String get langkahAiAnalisisLiveness => 'Memverifikasi liveness...';
  @override
  String get langkahAiAnalisisSuara => 'Memvalidasi rekaman suara...';
  @override
  String get langkahAiMenyelesaikan => 'Menyimpan hasil verifikasi...';
  @override
  String get jangantutupHalamanIni =>
      'Jangan tutup atau keluar dari halaman ini.';
  @override
  String get ulangi => 'Ulangi';
  @override
  String get mulai => 'Mulai';
  @override
  String get keluar => 'Keluar';
  @override
  String get keluarAplikasi => 'Keluar Aplikasi';
  @override
  String get bukaPengaturan => 'Buka Pengaturan';
  @override
  String get tutup => 'Tutup';
  @override
  String get kirim => 'Kirim';
  @override
  String get edit => 'Edit';
  @override
  String get lewati => 'Lewati';
  @override
  String get nanti => 'Nanti';
  @override
  String get masuk => 'Masuk';
  @override
  String get daftar => 'Daftar';
  @override
  String get registrasi => 'Registrasi';
  @override
  String get verifikasiAkun => 'Verifikasi Akun';
  @override
  String get masukDenganAkun => 'Masuk menggunakan\nakun Disdukcapil Anda';
  @override
  String get gunakanNikAtau =>
      'Gunakan NIK 16 digit, email, atau nomor HP yang terdaftar.';
  @override
  String get nikEmailNoHp => 'NIK / Email / Nomor HP';
  @override
  String get kataSandi => 'Kata Sandi';
  @override
  String get lupaKataSandi => 'Lupa kata sandi?';
  @override
  String get belumPunyaAkun => 'Belum punya akun?';
  @override
  String get sudahPunyaAkun => 'Sudah punya akun?';
  @override
  String get atauMasukMenggunakan => 'Atau masuk menggunakan';
  @override
  String get masukkanKodeUnik => 'Masukkan Kode Unik Yang Kami Kirim';
  @override
  String get periksaSms => 'Silakan periksa SMS Anda dan masukkan kode 6 digit';
  @override
  String get kirimUlang => 'Kirim ulang';
  @override
  String get butuhBantuan => 'Butuh bantuan masuk?';
  @override
  String get hubungiDisdukcapil => 'Hubungi Disdukcapil';
  @override
  String langkahXDariY(int current, int total) =>
      'Langkah $current dari $total';
  @override
  String get dataIdentitas => 'Data Identitas';
  @override
  String get dataIdentitasDasar => 'Data identitas dasar';
  @override
  String get pastikanDataSesuaiKtp =>
      'Pastikan data yang Anda masukkan sesuai KTP elektronik.';
  @override
  String get nik => 'NIK';
  @override
  String get namaLengkap => 'Nama Lengkap';
  @override
  String get tanggalLahir => 'Tanggal Lahir';
  @override
  String get tempatLahir => 'Tempat Lahir';
  @override
  String get jenisKelamin => 'Jenis Kelamin';
  @override
  String get lakiLaki => 'Laki-laki';
  @override
  String get perempuan => 'Perempuan';
  @override
  String get nomorHp => 'Nomor HP';
  @override
  String get email => 'Email';
  @override
  String get pilih => 'Pilih';
  @override
  String get pilihTanggal => 'Pilih tanggal';
  @override
  String get fotoKtpEl => 'Foto KTP-el';
  @override
  String get fotoKtp => 'Foto KTP';
  @override
  String get fotoWajah => 'Foto Wajah';
  @override
  String get ambilFotoKtp => 'Ambil foto KTP-el';
  @override
  String get ambilFotoWajah => 'Ambil foto wajah';
  @override
  String get periksaFotoWajah => 'Periksa foto wajah';
  @override
  String get pengambilanFotoWajah => 'Pengambilan foto wajah';
  @override
  String get fotoWajahDigunakan =>
      'Satu foto wajah netral, untuk dicocokkan dengan data foto KTP elektronik Anda.';
  @override
  String get posisikanWajahDiLingkaran => 'Posisikan wajah di dalam lingkaran';
  @override
  String get pastikanWajahJelas =>
      'Pastikan wajah terlihat jelas dan pencahayaan cukup.';
  @override
  String get gunakanFotoIni => 'Gunakan Foto Ini';
  @override
  String get lanjutKeLiveness => 'Lanjut';
  @override
  String get sisaPercobaan => 'Sisa percobaan';
  @override
  String get terlaluJauh => 'Terlalu jauh';
  @override
  String get terlaluDekat => 'Terlalu dekat';
  @override
  String get geserKeTengah => 'Geser ke tengah';
  @override
  String get wajahTidakTerdeteksi => 'Wajah tidak terdeteksi';
  @override
  String get wajahTerdeteksi => 'Wajah terdeteksi';
  @override
  String get wajahSiap => 'Wajah siap';
  @override
  String get verifikasiWajah => 'Verifikasi Wajah';
  @override
  String get verifikasiWajahAktif => 'Verifikasi wajah aktif';
  @override
  String get mulaiVerifikasi => 'Mulai Verifikasi';
  @override
  String get mulaiVerifikasiLiveness => 'Mulai Verifikasi';
  @override
  String get bersiap => 'Bersiap';
  @override
  String get sedangMerekam => 'Sedang merekam';
  @override
  String get kameraDitolak => 'Kamera ditolak';
  @override
  String get aksesKameraDitolak => 'Akses Kamera Ditolak';
  @override
  String get verifikasiSuara => 'Verifikasi Suara';
  @override
  String get ucapkanKalimatBerikut => 'Ucapkan kalimat berikut';
  @override
  String get tekanTombolRekam =>
      'Tekan tombol rekam, lalu ucapkan kalimat di bawah dengan suara jelas.';
  @override
  String get rekamanTersedia => 'Rekaman tersedia';
  @override
  String get lanjutKeReview => 'Lanjut ke Review';
  @override
  String get verifikasiSidikJari => 'Verifikasi Sidik Jari';
  @override
  String get masukDenganBiometrik => 'Masuk dengan Biometrik';
  @override
  String get persetujuanSebelumAktivasi => 'Persetujuan sebelum aktivasi';
  @override
  String get mulaiVerifikasiSidikJari => 'Mulai Verifikasi Sidik Jari';
  @override
  String get tempelkanJariSensor => 'Tempelkan jari pada sensor';
  @override
  String get sidikJariBerhasilDiverifikasi =>
      'Sidik jari berhasil diverifikasi';
  @override
  String get verifikasiBelumBerhasil => 'Verifikasi belum berhasil';
  @override
  String get sensorSidikJariSiap => 'Sensor sidik jari siap';
  @override
  String get sidikJariTidakTersedia => 'Sidik jari tidak tersedia';
  @override
  String get tinjauData => 'Tinjau Data';
  @override
  String get tinjauDataAnda => 'Tinjau data Anda';
  @override
  String get persetujuan => 'Persetujuan';
  @override
  String get persetujuanKebijakan => 'Persetujuan kebijakan';
  @override
  String get kirimRegistrasi => 'Kirim Registrasi';
  @override
  String get kebijakanPrivasi => 'Kebijakan Privasi';
  @override
  String get kebijakanLayanan => 'Kebijakan Layanan';
  @override
  String get penafianSistem => 'Penafian Sistem';
  @override
  String get pemrosesanDataBiometrik => 'Pemrosesan Data Biometrik';
  @override
  String get pernyataanKebenaranData => 'Pernyataan Kebenaran Data';
  @override
  String get bacaKebijakan => 'Baca Kebijakan';
  @override
  String get bacaDulu => 'Baca dulu';
  @override
  String get gulirSampaiAkhir =>
      'Gulir sampai akhir untuk mengaktifkan tombol setuju.';
  @override
  String get verifikasiBerhasilDikirim => 'Verifikasi Berhasil Dikirim';
  @override
  String get menungguVerifikasiOperator => 'Menunggu Verifikasi Operator';
  @override
  String get registrasiBerhasil => 'Registrasi Berhasil';
  @override
  String get registrasiDitolak => 'Registrasi Ditolak';
  @override
  String get nomorRegistrasi => 'Nomor Registrasi';
  @override
  String get tanggalPengajuan => 'Tanggal Pengajuan';
  @override
  String get menyiapkan => 'Menyiapkan';
  @override
  String get aktif => 'Aktif';
  @override
  String get cariWajah => 'Cari wajah';
  @override
  String get hintNik => '16 digit Nomor Induk Kependudukan';
  @override
  String get hintNoHp => '8xxxxxxxxxx';
  @override
  String get hintNamaSesuaiKtp => 'Sesuai KTP elektronik';
  @override
  String get hintTempatLahir => 'Mis. Ternate';
  @override
  String get hintEmail => 'nama@email.com';
  @override
  String get sessionExpired =>
      'Sesi Anda telah berakhir. Silakan masuk kembali.';
  @override
  String get jaringanBermasalah => 'Periksa koneksi internet Anda.';
  @override
  String get terjadiKesalahan => 'Terjadi kesalahan tak terduga.';
  @override
  String get mohonTunggu => 'Mohon tunggu…';
  @override
  String get pilihBahasa => 'Pilih Bahasa';
  @override
  String get bahasaAntarmuka => 'Bahasa antarmuka aplikasi';
  @override
  String get selamatDatang =>
      'Berhasil masuk. Selamat datang di BAKUDAPA MOBILE.';
  @override
  String get aksesDitolak => 'Akses Ditolak';
  @override
  String get akunDiblokir => 'Akun Diblokir';
  @override
  String get terlaluBanyakPercobaan => 'Terlalu Banyak Percobaan';
  @override
  String get tidakDapatMasuk => 'Tidak dapat masuk. Silakan coba lagi.';
  @override
  String get mohonTungguSebentar =>
      'Mohon tunggu sebentar sebelum mencoba lagi.';
  @override
  String get periksaDataLogin => 'Periksa kembali data login Anda';
  @override
  String get denganMasukSayaSetuju => 'Dengan masuk, saya setuju dengan ';
  @override
  String get syaratKetentuan => 'Syarat & Ketentuan';
  @override
  String get danPenghubung => ' dan ';
  @override
  String get disdukcapilSuffix => ' Disdukcapil Maluku Utara.';
  @override
  String get lupaKataSandiJudul => 'Lupa Kata Sandi?';
  @override
  String get masukkanNikEmail =>
      'Masukkan NIK atau email yang terdaftar. Kami akan mengirim tautan untuk membuat kata sandi baru.';
  @override
  String get nikEmail => 'NIK / Email';
  @override
  String get kirimTautanReset => 'Kirim Tautan Reset';
  @override
  String get kembaliKeHalamanMasuk => 'Kembali ke halaman masuk';
  @override
  String get tautanResetTerkirim => 'Tautan reset telah dikirim ke email Anda.';
  @override
  String get verifikasiBerhasil => 'Verifikasi berhasil.';
  @override
  String get kodeTerkirimUlang => 'Kode verifikasi telah dikirim ulang.';
  @override
  String get tidakMenerimaSms => 'Tidak menerima SMS? ';
  @override
  String get kirimKodeLewatEmail => 'Kirim kode lewat email';
  @override
  String get kirimKodeLewatTelepon => 'Kirim kode lewat telepon';
  @override
  String kirimUlangDalam(int detik) => 'Kirim ulang dalam ${detik}s';
  @override
  String silakanPeriksaSmsKe(String tujuan) =>
      'Silakan periksa SMS Anda dan masukkan kode 6 digit yang kami kirimkan ke $tujuan';
  @override
  String get kataSandiLabel => 'Kata sandi';
  @override
  String get tanggalLahirWajib => 'Tanggal lahir wajib dipilih.';
  @override
  String get jenisKelaminWajib => 'Jenis kelamin wajib dipilih.';
  @override
  String get gagalMemprosesIdentitas => 'Gagal memproses identitas.';
  @override
  String get bantuanNoHpTanpaNol =>
      'Tanpa angka 0 di awal. Contoh: 81234567890';
  @override
  String get namaLengkapLabel => 'Nama lengkap';
  @override
  String get tempatLahirLabel => 'Tempat lahir';
  @override
  String get tidakDapatBukaKameraDepan => 'Tidak dapat membuka kamera depan.';
  @override
  String get gagalMengambilFoto => 'Gagal mengambil foto. Coba lagi.';
  @override
  String get gagalMenyimpanVideoLiveness => 'Gagal menyimpan video liveness.';
  @override
  String get kualitasFotoBaik => 'Kualitas foto baik';
  @override
  String get memeriksa => 'Memeriksa…';
  @override
  String get menyelesaikan => 'Menyelesaikan…';
  @override
  String get langkahIntroFotoWajah1Judul => 'Aktifkan kamera depan';
  @override
  String get langkahIntroFotoWajah1Deskripsi =>
      'Anda hanya akan mengambil satu foto diam, bukan video. Pastikan kamera depan dapat diakses.';
  @override
  String get langkahIntroFotoWajah2Judul => 'Pose netral menghadap kamera';
  @override
  String get langkahIntroFotoWajah2Deskripsi =>
      'Tatap lensa lurus tanpa tersenyum atau memiringkan kepala. Tahan posisi diam saat tombol diketuk.';
  @override
  String get langkahIntroFotoWajah3Judul => 'Cahaya rata dari arah depan';
  @override
  String get langkahIntroFotoWajah3Deskripsi =>
      'Hindari cahaya membelakangi wajah atau lampu satu sisi yang membuat bayangan tajam pada pipi.';
  @override
  String get langkahIntroFotoWajah4Judul => 'Wajah tanpa penghalang';
  @override
  String get langkahIntroFotoWajah4Deskripsi =>
      'Lepas masker, kacamata hitam, topi, dan ikat rambut depan. Dahi, mata, hidung, dan mulut harus terlihat utuh.';
  @override
  String catatanSisaPercobaan(int sisa) =>
      'Anda memiliki sisa $sisa kali percobaan. Ikuti panduan di atas agar foto berhasil pada percobaan berikutnya.';
  @override
  String get catatanKualitasFoto =>
      'Sistem akan memeriksa kualitas foto (terang, fokus, tidak buram) sebelum dikirim untuk verifikasi.';
  @override
  String get subJudulIntroLiveness => 'Verifikasi Wajah Diperlukan';
  @override
  String get langkahIntroLiveness1Judul =>
      'Kamera akan merekam selama ~10 detik';
  @override
  String get langkahIntroLiveness1Deskripsi =>
      'Berbeda dari langkah foto, di sini sistem mengambil video singkat untuk membaca pergerakan wajah Anda.';
  @override
  String get langkahIntroLiveness2Judul =>
      'Jaga wajah tetap di dalam lingkaran';
  @override
  String get langkahIntroLiveness2Deskripsi =>
      'Selama merekam, wajah harus tetap berada di lingkaran panduan walaupun Anda menoleh atau mengangguk.';
  @override
  String get langkahIntroLiveness3Judul => 'Ikuti tiga instruksi gerakan acak';
  @override
  String get langkahIntroLiveness3Deskripsi =>
      'Sistem meminta menoleh, mengangguk, atau menatap pusat. Setiap instruksi punya batas waktu beberapa detik.';
  @override
  String get langkahIntroLiveness4Judul => 'Untuk mencegah pemalsuan identitas';
  @override
  String get langkahIntroLiveness4Deskripsi =>
      'Rekaman membuktikan Anda orang nyata, bukan foto atau replay layar. Tidak disimpan ke galeri perangkat.';
  @override
  String get catatanIntroLiveness =>
      'Proses ini aman. Data biometrik diproses sesuai Kebijakan Privasi dan hanya digunakan untuk verifikasi akun.';
  @override
  String get poinSidikJari1 =>
      'Anda dapat menggunakan biometrik sidik jari untuk memperkuat keamanan registrasi.';
  @override
  String get poinSidikJari2 =>
      'Jika menggunakan sensor sidik jari perangkat, aplikasi hanya menerima status berhasil/gagal dari sistem perangkat data sidik jari mentah tidak meninggalkan perangkat.';
  @override
  String get poinSidikJari3 =>
      'Jika tersedia perangkat scanner resmi, hasil pemindaian dikirim secara aman dan terenkripsi ke backend untuk ditinjau operator berwenang.';
  @override
  String get poinSidikJari4 =>
      'Data biometrik digunakan hanya untuk kebutuhan verifikasi keamanan akun dan layanan administrasi kependudukan Disdukcapil Maluku Utara.';
  @override
  String get poinSidikJari5 =>
      'Anda bertanggung jawab penuh atas keamanan biometrik yang terdaftar/tersimpan dalam perangkat Anda.';
  @override
  String get poinSidikJari6 =>
      'Hubungi layanan dukungan Disdukcapil untuk informasi lebih lanjut atau penonaktifan biometrik.';
  @override
  String get persetujuanAktivasiBiometrik =>
      'Dengan ini saya menyetujui aktivasi dan pemrosesan biometrik sidik jari untuk verifikasi registrasi.';
  @override
  String get verifikasiWajahSelesai => 'Verifikasi wajah selesai';
  @override
  String get gerakanBenar => 'Gerakan benar';
  @override
  String get arahBelumSesuai => 'Arah belum sesuai';
  @override
  String cobaLagiPercobaan(int p, int maks) => 'Coba lagi · $p/$maks';
  @override
  String get verifikasiBelumBerhasilLengkap =>
      'Beberapa instruksi belum berhasil dilakukan dalam batas percobaan. Mari mulai ulang verifikasi wajah.';
  @override
  String get persiapanKamera => 'Mempersiapkan kamera…';
  @override
  String get aksesKameraDiperlukan => 'Akses kamera diperlukan';
  @override
  String get bukaPengaturanKamera =>
      'Aktifkan izin kamera untuk dari menu pengaturan aplikasi pada perangkat Anda.';
  @override
  String get buatKataSandiBaru => 'Buat kata sandi baru';
  @override
  String get bersiapMengambilFoto => 'Bersiap mengambil foto';
  @override
  String get instruksiUmumLiveness => 'Lakukan gerakan sesuai instruksi.';
  @override
  String get tahanStabil => 'Tahan stabil';
  @override
  String get jangkauanLayanan => 'Jangkauan layanan';
  @override
  String get gagalMemulaiPerekaman => 'Gagal memulai perekaman.';
  @override
  String get verifikasiBelumBerhasilJudul => 'Verifikasi Belum Berhasil';
  @override
  String get verifikasiGagal => 'Verifikasi Gagal';
  @override
  String get verifikasiWajahBelumBerhasilPesan =>
      'Verifikasi wajah belum berhasil. Pastikan wajah terlihat jelas dan ikuti instruksi yang muncul.';
  @override
  String get gerakanTerdeteksiLanjut =>
      'Gerakan terdeteksi. Lanjut ke instruksi berikutnya.';
  @override
  String get lanjutkanKeVerifikasiSuara =>
      'Lanjutkan ke verifikasi suara untuk menyelesaikan registrasi.';
  @override
  String sedangMerekamDetik(int detik) => 'Sedang merekam · $detik dtk';
  @override
  String get arahkanWajahDanIkutiInstruksi =>
      'Arahkan wajah ke tengah dan ikuti instruksi yang muncul.';
  @override
  String get fotoIdentitas => 'Foto Identitas';
  @override
  String get ambilFotoKtpEl => 'Ambil foto KTP elektronik';
  @override
  String get periksaHasilFotoKtpEl => 'Periksa hasil foto KTP elektronik';
  @override
  String get pastikanDokumenJelas =>
      'Pastikan dokumen terlihat jelas, tidak buram, tidak terpotong, dan seluruh bagian identitas masuk ke dalam area panduan.';
  @override
  String get tidakDapatBukaKamera => 'Tidak dapat membuka kamera.';
  @override
  String get gagalMengunggahFoto => 'Gagal mengunggah foto.';
  @override
  String get bukaPanduan => 'Buka Panduan';
  @override
  String get fotoBelumVerifikasi => 'Foto belum berhasil diverifikasi';
  @override
  String get butuhCobaSekaliLagi => 'Perlu coba sekali lagi';
  @override
  String get sistemBelumDapatMemverifikasi =>
      'Sistem belum dapat memverifikasi foto wajah Anda. Ikuti panduan singkat berikut, lalu coba sekali lagi.';
  @override
  String get andaTelahMenggunakanKuota =>
      'Anda telah menggunakan seluruh kuota percobaan. Silakan baca panduan, lalu mulai kembali dari halaman utama.';
  @override
  String get panduanTambahan => 'PANDUAN TAMBAHAN';
  @override
  String get panduan1 =>
      'Cari ruangan dengan cahaya alami atau lampu yang merata.';
  @override
  String get panduan2 =>
      'Posisikan wajah lurus ke kamera, tidak terlalu dekat atau jauh.';
  @override
  String get panduan3 =>
      'Tahan ponsel dengan stabil. Bersihkan lensa kamera bila perlu.';
  @override
  String get panduan4 =>
      'Lepas masker, kacamata gelap, atau penutup wajah lainnya.';
  @override
  String get percobaanHabis => 'Percobaan habis';
  @override
  String sisaPercobaanFormat(int sisa, int total) =>
      'Sisa percobaan · $sisa/$total';
  @override
  String percobaanHabisFormat(int total) => 'Percobaan habis · $total/$total';
  @override
  String get gunakanSidikJariMemperkuat =>
      'Gunakan sidik jari untuk keamanan registrasi akun anda';
  @override
  String get memeriksaKetersediaan => 'Memeriksa ketersediaan…';
  @override
  String get memeriksaKemampuanBiometrik =>
      'Memeriksa kemampuan biometrik perangkat Anda.';
  @override
  String get tekanLaluTempelkanJari =>
      'Tekan tombol di bawah lalu tempelkan jari pada sensor.';
  @override
  String get dapatLewatiJikaTidakWajib =>
      'Anda dapat melewati langkah ini jika tidak wajib.';
  @override
  String get ikutiInstruksiPerangkat =>
      'Ikuti instruksi pada layar perangkat Anda.';
  @override
  String get statusVerifikasiDikirim =>
      'Status verifikasi akan dikirim ke server Disdukcapil.';
  @override
  String get cobaLagiAtauLewati => 'Silakan coba lagi atau lewati langkah ini.';
  @override
  String get dataSidikJariTidakKirim =>
      'Data sidik jari tidak meninggalkan perangkat. Hanya status verifikasi yang dikirim ke server.';
  @override
  String get pastikanSensorAktif =>
      'Pastikan sensor sidik jari pada perangkat Anda sudah aktif dan jari Anda kering.';
  @override
  String get lewatiLangkahIni => 'Lewati Langkah Ini';
  @override
  String get lanjutKeTinjauData => 'Lanjut ke Tinjau Data';
  @override
  String get perangkatTidakMendukungSidikJari =>
      'Perangkat ini tidak mendukung verifikasi sidik jari. Anda tetap dapat melanjutkan jika metode ini tidak diwajibkan oleh sistem.';
  @override
  String get belumAdaSidikJari =>
      'Belum ada sidik jari yang terdaftar pada perangkat. Daftarkan terlebih dahulu di pengaturan perangkat.';
  @override
  String get gagalKirimStatusSidikJari =>
      'Gagal mengirim status verifikasi sidik jari.';
  @override
  String get dilewatiPengguna => 'Dilewati pengguna';
  @override
  String get izinMikrofonBelumDiberikan => 'Izin mikrofon belum diberikan.';
  @override
  String get gagalMemulaiPerekamanSuara => 'Gagal memulai perekaman suara.';
  @override
  String get rekamanBelumTerdengarJelas =>
      'Rekaman belum terdengar jelas. Silakan ulangi di tempat yang lebih tenang.';
  @override
  String get kodeVerifikasi => 'KODE VERIFIKASI';
  @override
  String get rekamSuaraMinimal =>
      'Rekam suara minimal 8 detik. Jangan ditutup dengan tangan.';
  @override
  String get tinjauDataPeriksa =>
      'Periksa kembali sebelum melanjutkan ke persetujuan kebijakan.';
  @override
  String get identitasDasar => 'Identitas Dasar';
  @override
  String get berkasVerifikasi => 'Berkas Verifikasi';
  @override
  String get fotoIdentitasLabel => 'Foto identitas';
  @override
  String get fotoWajahLabel => 'Foto wajah';
  @override
  String get videoLiveness => 'Video liveness';
  @override
  String get rekamanSuara => 'Rekaman suara';
  @override
  String get sidikJariLabel => 'Sidik jari';
  @override
  String instruksiTerverifikasi(int n) => '$n instruksi terverifikasi';
  @override
  String get siap => 'Siap';
  @override
  String get belum => 'Belum';
  @override
  String get lanjutKePersetujuan => 'Lanjut ke Persetujuan';
  @override
  String get statusSidikDiverifikasiPerangkat =>
      'Diverifikasi melalui perangkat ini';
  @override
  String get statusSidikDilewati => 'Dilewati pengguna';
  @override
  String get statusSidikPerangkatTidakDukung => 'Perangkat tidak mendukung';
  @override
  String get statusSidikBelumAdaDiPerangkat =>
      'Belum ada sidik jari di perangkat';
  @override
  String get statusSidikDibatalkan => 'Verifikasi dibatalkan pengguna';
  @override
  String get statusSidikGagal => 'Verifikasi gagal';
  @override
  String get statusSidikBelumDiperiksa => 'Belum diverifikasi';
  @override
  String get gagalMengirimRegistrasi =>
      'Gagal mengirim registrasi. Silakan coba lagi.';
  @override
  String get bukaTautanBacaSetelah =>
      'Buka tautan "Baca" untuk membaca isi kebijakan. Centang akan terisi otomatis setelah Anda menyetujui isi.';
  @override
  String get kebijakanPrivasiDeskripsi =>
      'Pengumpulan, penggunaan, dan perlindungan data pribadi Anda.';
  @override
  String get kebijakanLayananDeskripsi =>
      'Ketentuan penggunaan layanan BAKUDAPA MOBILE.';
  @override
  String get penafianSistemJudulLengkap =>
      'Penafian Ketersediaan & Keamanan Sistem';
  @override
  String get penafianSistemDeskripsi =>
      'Penafian ketersediaan layanan dan tanggung jawab penyelenggara.';
  @override
  String get pemrosesanDataBiometrikDeskripsi =>
      'Persetujuan pemrosesan foto wajah, liveness, suara, dan sidik jari untuk verifikasi.';
  @override
  String get pernyataanKebenaranDataDeskripsi =>
      'Pernyataan bahwa data yang dikirim benar dan dapat dipertanggungjawabkan.';
  @override
  String get bacaKebijakanPrivasi => 'Baca Kebijakan Privasi';
  @override
  String get bacaKebijakanLayanan => 'Baca Kebijakan Layanan';
  @override
  String get bacaPenafianSistem => 'Baca Penafian Sistem';
  @override
  String get bacaPersetujuanBiometrik => 'Baca Persetujuan Biometrik';
  @override
  String get bacaPernyataanKebenaran => 'Baca Pernyataan Kebenaran';
  @override
  String get pastikanDataDiperbarui =>
      'Pastikan data Anda telah diperbarui melalui menu Konsolidasi Data setiap 6 bulan.';
  @override
  String get layananCepat => 'Layanan Cepat';
  @override
  String get lihatSemua => 'Lihat semua';
  @override
  String get pintasan => 'Pintasan';
  @override
  String get panduanPengguna => 'Panduan Pengguna';
  @override
  String get tutorialLangkah => 'Tutorial langkah demi langkah';
  @override
  String get pusatBantuan => 'Pusat Bantuan';
  @override
  String get hubungiKamiFaq => 'Hubungi kami atau FAQ';
  @override
  String get profil => 'Profil';
  @override
  String get tanpaNama => 'Tanpa Nama';
  @override
  String get terverifikasi => 'Terverifikasi';
  @override
  String get akunDanKeamanan => 'Akun & Keamanan';
  @override
  String get dataPribadi => 'Data Pribadi';
  @override
  String get dataPribadiSub => 'Lihat informasi NIK, email, dan kontak.';
  @override
  String get keamananAkun => 'Keamanan Akun';
  @override
  String get keamananAkunSub => 'Ubah kata sandi, atur biometrik.';
  @override
  String get pemberitahuan => 'Pemberitahuan';
  @override
  String get pemberitahuanSub => 'Pengaturan notifikasi sistem.';
  @override
  String get bantuanDanInformasi => 'Bantuan & Informasi';
  @override
  String get tutorialMenggunakanApp => 'Tutorial menggunakan aplikasi.';
  @override
  String get hubungiKamiAtauFaq => 'Hubungi kami atau FAQ.';
  @override
  String get kebijakanPrivasiSub => 'Bagaimana data Anda dilindungi.';
  @override
  String get kebijakanLayananSub => 'Ketentuan penggunaan layanan.';
  @override
  String get penafianKetersediaanSistem => 'Penafian Ketersediaan Sistem';
  @override
  String get pernyataanKetersediaan => 'Pernyataan ketersediaan layanan.';
  @override
  String get keluarDariAplikasi => 'Keluar dari Aplikasi?';
  @override
  String get andaAkanKeluarSesi =>
      'Anda akan keluar dari sesi pada perangkat ini. Anda harus masuk kembali untuk mengakses layanan.';
  @override
  String get andaTelahKeluar => 'Anda telah keluar dari aplikasi.';
  @override
  String get versiAplikasi => 'Versi 1.0.0';
  @override
  String get pengaturan => 'Pengaturan';
  @override
  String get bahasa => 'Bahasa';
  @override
  String get bahasaIndonesia => 'Bahasa Indonesia';
  @override
  String get englishLabel => 'English';
  @override
  String get tema => 'Tema';
  @override
  String get terang => 'Terang';
  @override
  String get gelap => 'Gelap';
  @override
  String get otomatis => 'Otomatis';
  @override
  String get tentangAplikasi => 'Tentang Aplikasi';
  @override
  String get layanan => 'Layanan';
  @override
  String get semuaLayanan => 'Semua Layanan';
  @override
  String get cariLayanan => 'Cari layanan…';
  @override
  String get tidakAdaLayanan => 'Tidak ada layanan ditemukan.';
  @override
  String get bantuan => 'Bantuan';
  @override
  String get faq => 'Pertanyaan Umum';
  @override
  String get hubungiKami => 'Hubungi Kami';
  @override
  String get permohonan => 'Permohonan';
  @override
  String get riwayatPermohonan => 'Riwayat Permohonan';
  @override
  String get pemberitahuanJudul => 'Pemberitahuan';
  @override
  String get tidakAdaPemberitahuan => 'Belum ada pemberitahuan.';
  @override
  String get tandaiSudahDibaca => 'Tandai sudah dibaca';
  @override
  String get panduanJudul => 'Panduan Penggunaan';
  @override
  String get onboardingJudul1 => 'Layanan Disdukcapil dalam Genggaman';
  @override
  String get onboardingDesc1 =>
      'Akses layanan administrasi kependudukan resmi Provinsi Maluku Utara dari ponsel Anda.';
  @override
  String get onboardingJudul2 => 'Aman dan Terverifikasi';
  @override
  String get onboardingDesc2 =>
      'Verifikasi identitas berlapis dengan biometrik untuk melindungi akun dan data Anda.';
  @override
  String get onboardingJudul3 => 'Pantau Status Real-time';
  @override
  String get onboardingDesc3 =>
      'Lihat status pengajuan dokumen secara langsung tanpa perlu datang ke kantor.';
  @override
  String get mulaiSekarang => 'Mulai Sekarang';
  @override
  String get sayaSudahMemilikiAkun => 'Saya Sudah Memiliki Akun';
  @override
  String get tandaiSemuaSudahDibaca => 'Tandai Semua Sudah Dibaca?';
  @override
  String get semuaPemberitahuanDitandai =>
      'Semua pemberitahuan akan ditandai sebagai sudah dibaca.';
  @override
  String get tandaiSemua => 'Tandai Semua';
  @override
  String get semuaPemberitahuanDitandaiDibaca =>
      'Semua pemberitahuan ditandai dibaca.';
  @override
  String get belumAdaPemberitahuan => 'Belum ada pemberitahuan';
  @override
  String get pembaruanStatusAkanMuncul =>
      'Pembaruan status permohonan Anda akan muncul di sini.';
  @override
  String get hariIni => 'HARI INI';
  @override
  String get kemarin => 'KEMARIN';
  @override
  String get mingguIni => 'MINGGU INI';
  @override
  String get sebelumnya => 'SEBELUMNYA';
  @override
  String get pertanyaanUmum => 'Pertanyaan Umum';
  @override
  String get hubungiKamiSub => 'Tim Disdukcapil siap membantu Anda.';
  @override
  String get bantuanLaporkanKendala => 'Laporkan kendala atau pertanyaan.';
  @override
  String get bantuanPanggilCs => 'Panggil Pusat Layanan';
  @override
  String get bantuanEmailKami => 'Email kami';
  @override
  String get bantuanKantorPusat => 'Kantor Disdukcapil Maluku Utara';
  @override
  String get judulPanduan => 'Panduan Pengguna';
  @override
  String get hapus => 'Hapus';
  @override
  String get muat => 'Muat ulang';
  @override
  String get gagalMemuat => 'Gagal memuat data.';
  @override
  String get tidakAdaPermohonan => 'Belum ada permohonan';
  @override
  String get permohonanAndaAkanMuncul =>
      'Permohonan layanan yang Anda ajukan akan tampil di sini.';
  @override
  String get statusPermohonan => 'Status Permohonan';
  @override
  String get diterima => 'Diterima';
  @override
  String get ditolak => 'Ditolak';
  @override
  String get diproses => 'Diproses';
  @override
  String get menunggu => 'Menunggu';
  @override
  String get emailResmi => 'Email Resmi';
  @override
  String get telepon => 'Telepon';
  @override
  String get situsWeb => 'Situs Web';
  @override
  String get alamat => 'Alamat';
  @override
  String get pertanyaanUmumLengkap => 'Pertanyaan Umum (FAQ)';
  @override
  String get faq1Q => 'Apa itu BAKUDAPA MOBILE?';
  @override
  String get faq1A =>
      'BAKUDAPA MOBILE adalah aplikasi resmi Disdukcapil Provinsi Maluku Utara untuk mengakses layanan administrasi kependudukan secara daring tanpa perlu datang ke kantor.';
  @override
  String get faq2Q => 'Apakah aplikasi ini gratis?';
  @override
  String get faq2A =>
      'Ya. Semua layanan resmi tidak dipungut biaya. Waspadai pihak yang meminta pembayaran tidak resmi.';
  @override
  String get faq3Q => 'Berapa lama proses permohonan?';
  @override
  String get faq3A =>
      'Setiap layanan memiliki SLA berbeda. Status permohonan dapat dipantau secara langsung pada menu Riwayat.';
  @override
  String get faq4Q => 'Bagaimana jika permohonan saya ditolak?';
  @override
  String get faq4A =>
      'Periksa catatan pada detail permohonan. Anda dapat mengajukan ulang setelah memperbaiki kelengkapan data atau dokumen.';
  @override
  String get faq5Q => 'Bagaimana cara mengubah data pribadi?';
  @override
  String get faq5A =>
      'Gunakan menu Konsolidasi Data untuk pemutakhiran. Beberapa data hanya dapat diubah oleh petugas Disdukcapil.';
  @override
  String get faq6Q => 'Apakah data saya aman?';
  @override
  String get faq6A =>
      'Token akses disimpan dengan enkripsi pada Keystore/Keychain perangkat. Data sensitif disamarkan pada tampilan dan tidak dicatat di log.';
  @override
  String get tabMemulai => 'Memulai';
  @override
  String get tabLayanan => 'Layanan';
  @override
  String get tabKeamanan => 'Tips Keamanan';
  @override
  String get dokumenDisiapkan => 'Dokumen yang Disiapkan';
  @override
  String get opsional => 'opsional';
  @override
  String get riwayat => 'Riwayat';
  @override
  String get cariKodeReferensi => 'Cari kode referensi atau jenis layanan';
  @override
  String get belumAdaPermohonan => 'Belum ada permohonan';
  @override
  String get riwayatPermohonanAnda =>
      'Riwayat permohonan Anda akan muncul di sini.';
  @override
  String get langkahPengajuan => 'Langkah Pengajuan';
  @override
  String get ajukanSekarang => 'Ajukan Sekarang';
  @override
  String get isiFormulir => 'Isi Formulir';
  @override
  String get unggahDokumen => 'Unggah Dokumen';
  @override
  String get kirimPermohonan => 'Kirim Permohonan';
  @override
  String get permohonanDikirim => 'Permohonan berhasil dikirim.';
  @override
  String get gagalKirimPermohonan => 'Gagal mengirim permohonan.';
  @override
  String get detailPermohonan => 'Detail Permohonan';
  @override
  String get kodeReferensi => 'Kode Referensi';
  @override
  String get jenisLayanan => 'Jenis Layanan';
  @override
  String get diajukanPada => 'Diajukan Pada';
  @override
  String get diperbaruiPada => 'Diperbarui Pada';
  @override
  String get catatan => 'Catatan';
  @override
  String get dokumen => 'Dokumen';
  @override
  String get unduhDokumenHasil => 'Unduh Dokumen Hasil';
  @override
  String get selamatPagi => 'Selamat pagi';
  @override
  String get selamatSiang => 'Selamat siang';
  @override
  String get selamatSore => 'Selamat sore';
  @override
  String get selamatMalam => 'Selamat malam';
  @override
  String get wargaMalukuUtara => 'Warga Maluku Utara';
  @override
  String get berjalan => 'Berjalan';
  @override
  String get statusSelesai => 'Selesai';
  @override
  String wajibDiisi(String label) => '$label wajib diisi.';
  @override
  String minimalKarakter(String label, int n) => '$label minimal $n karakter.';
  @override
  String get kolomIniLabel => 'Kolom ini';
  @override
  String get nikHarus16Digit => 'NIK harus 16 digit.';
  @override
  String get nikHanyaAngka => 'NIK hanya boleh berisi angka.';
  @override
  String get noKkLabel => 'Nomor KK';
  @override
  String get noKkHarus16Digit => 'Nomor KK harus 16 digit.';
  @override
  String get noKkHanyaAngka => 'Nomor KK hanya boleh berisi angka.';
  @override
  String get formatEmailTidakValid => 'Format email tidak valid.';
  @override
  String get noHpTidakValid => 'Nomor HP tidak valid.';
  @override
  String get hapusAngka0DiAwal => 'Hapus angka 0 di awal.';
  @override
  String get noHpHarus9Digit => 'Nomor HP harus 9–13 digit.';
  @override
  String get kataSandiMin8 => 'Minimal 8 karakter.';
  @override
  String get sertakanHurufBesar => 'Sertakan minimal 1 huruf besar.';
  @override
  String get sertakanAngka => 'Sertakan minimal 1 angka.';
  @override
  String get konfirmasiKataSandiLabel => 'Konfirmasi kata sandi';
  @override
  String get kataSandiTidakCocok => 'Kata sandi tidak cocok.';
  @override
  String get nikAtauEmailLabel => 'NIK atau email';
  @override
  String get identitasTidakValid => 'Identitas tidak valid.';
  @override
  String get nikLabel => 'NIK';
  @override
  String get nomorHpLabel => 'Nomor HP';
  @override
  String get emailLabel => 'Email';
  @override
  String get jaringanTidakAdaJudul => 'Tidak Ada Koneksi Internet';
  @override
  String get jaringanTidakAdaPesan =>
      'Perangkat Anda tidak terhubung ke internet. Periksa koneksi jaringan Anda lalu coba kembali.';
  @override
  String get jaringanTidakStabilJudul => 'Jaringan Tidak Stabil';
  @override
  String get jaringanTidakStabilPesan =>
      'Koneksi internet Anda sedang tidak stabil. Demi menjaga keamanan dan mencegah data registrasi gagal terkirim, proses ini belum dapat dilanjutkan. Silakan pindah ke lokasi dengan jaringan yang lebih baik atau gunakan koneksi yang lebih stabil.';
  @override
  String get jaringanServerTakTerjangkauJudul => 'Server Tidak Terjangkau';
  @override
  String get jaringanServerTakTerjangkauPesan =>
      'Saat ini server Disdukcapil tidak dapat dijangkau. Periksa koneksi Anda atau coba beberapa saat lagi.';
  @override
  String get jaringanLambatUntukUploadJudul => 'Koneksi Belum Memadai';
  @override
  String get jaringanLambatUntukUploadPesan =>
      'Kecepatan jaringan saat ini berisiko membuat unggahan biometrik gagal. Pindah ke jaringan yang lebih stabil sebelum melanjutkan.';
  @override
  String get memeriksaJaringan => 'Memeriksa jaringan…';
  @override
  String get periksaUlang => 'Periksa Ulang';
  @override
  String get jaringanStabil => 'Jaringan stabil';
  @override
  String get jaringanSedang => 'Jaringan sedang';
  @override
  String get jaringanLambat => 'Jaringan lambat';
  @override
  String get jaringanOffline => 'Tidak ada koneksi';
  @override
  String get maintenanceJudul => 'Sistem Sedang Pemeliharaan';
  @override
  String get maintenancePesanSingkat =>
      'BAKUDAPA MOBILE sedang dalam proses pemeliharaan untuk peningkatan keamanan dan kualitas layanan. Selama pemeliharaan berlangsung, login, registrasi, dan aktivitas layanan belum dapat digunakan. Silakan coba kembali beberapa saat lagi.';
  @override
  String get maintenancePesanLengkap =>
      'Kami sedang melakukan pemeliharaan sistem untuk meningkatkan keamanan, stabilitas, dan kualitas layanan BAKUDAPA MOBILE. Selama proses berlangsung, login, registrasi, dan aktivitas layanan untuk sementara tidak tersedia.';
  @override
  String get maintenanceHalamanJudul => 'Sistem Sedang Pemeliharaan';
  @override
  String get maintenanceHalamanPesan =>
      'Layanan sedang dalam pemeliharaan untuk menjaga keamanan dan kualitas sistem. Silakan coba kembali setelah proses pemeliharaan selesai.';
  @override
  String estimasiSelesai(String tanggal) => 'Estimasi selesai: $tanggal';
  @override
  String kontakLayanan(String kontak) => 'Kontak layanan: $kontak';
  @override
  String get keluarAplikasiLabel => 'Keluar Aplikasi';
  @override
  String get bahasaApaYangInginDigunakan =>
      'Bahasa apa yang ingin Anda gunakan?';
  @override
  String get bahasaIndonesiaLabel => 'Bahasa Indonesia';
  @override
  String get englishUkLabel => 'English (UK)';
  @override
  String get gunakanBahasaIndonesia => 'Gunakan Bahasa Indonesia';
  @override
  String get useEnglish => 'Use English';
  @override
  String get bahasaBerhasilDiubah => 'Bahasa berhasil diubah.';
  @override
  String get asistenAi => 'Asisten AI';
  @override
  String get sapaanAi =>
      'Tanyakan apa saja seputar layanan Disdukcapil Provinsi Maluku Utara. Saya siap membantu menjelaskan langkah dan persyaratan.';
  @override
  String get ketikPertanyaan => 'Tulis pertanyaan…';
  @override
  String get lanjutkanAi => 'Lanjutkan';
  @override
  String get mulaiSesiBaru => 'Mulai sesi baru';
  @override
  String get menyimpanIdentitas =>
      'Sedang menyimpan data identitas Anda. Mohon jangan menutup aplikasi.';
  @override
  String get mengirimRegistrasi =>
      'Sedang mengirim registrasi Anda ke Disdukcapil. Mohon jangan menutup aplikasi.';
  @override
  String get mengunggahBerkas =>
      'Sedang mengunggah berkas ke server yang aman.';
  @override
  String get memprosesPermintaan => 'Sedang memproses permintaan Anda.';
  @override
  String get mengunggahFotoDokumen =>
      'Sedang mengunggah foto identitas Anda. Mohon jangan menutup aplikasi.';
  @override
  String get mengunggahFotoWajah =>
      'Sedang mengunggah foto wajah Anda. Mohon jangan menutup aplikasi.';
  @override
  String get mengunggahLiveness =>
      'Sedang mengunggah data verifikasi wajah. Mohon jangan menutup aplikasi.';
  @override
  String get mengunggahSuara =>
      'Sedang mengunggah rekaman suara Anda. Mohon jangan menutup aplikasi.';
  @override
  String get mengirimSidikJari => 'Sedang mengirim verifikasi sidik jari Anda.';
  @override
  String get memverifikasiAkun => 'Sedang memverifikasi akun Anda.';
  @override
  String get memverifikasiKode => 'Sedang memverifikasi kode OTP Anda.';
  @override
  String get tabBeranda => 'Beranda';
  @override
  String get tabPermohonan => 'Permohonan';
  @override
  String get tabAsisten => 'Asisten';
  @override
  String get tabNotifikasi => 'Notifikasi';
  @override
  String get tabProfil => 'Profil';
  @override
  String get instansiSingkat => 'Disdukcapil Maluku Utara';
  @override
  String get akunTerverifikasi => 'Terverifikasi';
  @override
  String get akunBelumTerverifikasi => 'Belum Terverifikasi';
  @override
  String get buatPermohonan => 'Buat Permohonan';
  @override
  String get permohonanAktif => 'Permohonan Aktif';
  @override
  String get bakudapaAi => 'BAKUDAPA AI';
  @override
  String get asistenAjakan => 'Tanya layanan & status permohonan';
  @override
  String get mulaiPercakapan => 'Mulai percakapan';
  @override
  String get tanpaPermohonanAktif => 'Belum ada permohonan aktif';
  @override
  String ringkasanPermohonanAktif(int n) => '$n permohonan sedang diproses';
  @override
  String get disclaimerAi =>
      'Informasi asisten bersifat bantuan, bukan keputusan resmi Disdukcapil.';
  @override
  String get cobaTanya => 'Coba tanya';
  @override
  String get saranStatusPermohonan => 'Apa status permohonan saya?';
  @override
  String get saranSyaratKk => 'Apa syarat membuat KK?';
  @override
  String get saranApaItuKia => 'Apa itu KIA?';
  @override
  String get saranPindahDomisili => 'Bagaimana cara pindah domisili?';
  @override
  String get asistenMengetik => 'Asisten sedang mengetik…';
  @override
  String get menyiapkanKamera => 'Menyiapkan kamera…';
  @override
  String get izinKamera => 'Izin kamera';
  @override
  String get izinKameraArahan =>
      'Aktifkan izin kamera agar verifikasi wajah dapat dilanjutkan.';
  @override
  String get cahayaKurang => 'Cahaya kurang';
  @override
  String get cahayaKurangArahan =>
      'Pencahayaan belum cukup. Pindah ke area yang lebih terang atau arahkan wajah ke sumber cahaya.';
  @override
  String get posisikanWajah => 'Posisikan Wajah';
  @override
  String get ambilFoto => 'Ambil Foto';
  @override
  String get memproses => 'Memproses…';
  @override
  String get arahanPosisikanWajah =>
      'Posisikan wajah Anda di dalam lingkaran agar sistem dapat memverifikasi.';
  @override
  String get arahanTerlaluJauh =>
      'Dekatkan wajah sedikit ke kamera hingga memenuhi area panduan.';
  @override
  String get arahanTerlaluDekat =>
      'Jauhkan wajah sedikit dari kamera agar seluruh wajah terlihat jelas.';
  @override
  String get arahanSatuWajah =>
      'Pastikan hanya ada satu wajah di dalam bingkai.';
  @override
  String get siapVerifikasiWajah => 'Siap melakukan verifikasi wajah';
  @override
  String get tersedia => 'Tersedia';
  @override
  String get tersediaOnline => 'Online';
  @override
  String get layananLoket => 'Loket';
  @override
  String get layananBelumOnlinePesan =>
      'Layanan ini belum dapat diajukan online. Silakan datang langsung ke loket Disdukcapil terdekat.';
  @override
  String get perluVerifikasiPesan =>
      'Verifikasi akun Anda terlebih dahulu untuk dapat mengajukan permohonan.';
  @override
  String get kataSandiBaru => 'Kata Sandi Baru';
  @override
  String get konfirmasiKataSandiBaru => 'Konfirmasi Kata Sandi Baru';
  @override
  String get buatKataSandiBaruJudul => 'Buat Kata Sandi Baru';
  @override
  String get buatKataSandiBaruSub =>
      'Masukkan kata sandi baru untuk akun Anda. Pastikan minimal 8 karakter, mengandung huruf besar dan angka.';
  @override
  String get kataSandiBerhasilDiubah => 'Kata sandi berhasil diubah.';
  @override
  String get simpanKataSandiBaru => 'Simpan Kata Sandi Baru';
  @override
  String get tantanganSuaraKosongJudul => 'Kalimat verifikasi belum tersedia';
  @override
  String get tantanganSuaraKosongPesan =>
      'Tantangan suara belum disiapkan oleh operator. Silakan hubungi Disdukcapil Provinsi Maluku Utara untuk melanjutkan registrasi.';
  @override
  String get tantanganSuaraGagalMuat =>
      'Gagal memuat kalimat verifikasi. Silakan coba lagi.';
  @override
  String get tantanganSuaraBelumDimuat =>
      'Kalimat verifikasi belum termuat. Silakan tunggu atau coba lagi.';
  @override
  String get rekamanBelumCocokKalimat =>
      'Rekaman tampaknya belum sesuai dengan kalimat di atas. Ulangi dan ucapkan kalimat secara lengkap.';
  @override
  String get hubungiDisdukcapilCta => 'Hubungi Disdukcapil';
}
