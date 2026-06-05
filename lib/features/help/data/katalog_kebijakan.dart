import 'package:bakudapa_mobile/core/enums/jenis_kebijakan.dart';

import '../../../shared/providers/penyedia_bahasa.dart';

export 'package:bakudapa_mobile/core/enums/jenis_kebijakan.dart';

class Pasal {
  const Pasal(this.judul, this.isi);
  final String judul;
  final String isi;
}

class IsiKebijakan {
  const IsiKebijakan({
    required this.judul,
    required this.pasal,
    required this.kontak,
    required this.versi,
    required this.berlakuSejak,
    required this.terakhirDiperbaruiPrefix,
    required this.versiPrefix,
    required this.hubungiTeks,
    required this.kembali,
    required this.sayaMengertiDanSetuju,
    required this.gulirSampaiAkhir,
  });

  final String judul;
  final List<Pasal> pasal;
  final String kontak;
  final String versi;
  final String berlakuSejak;
  final String terakhirDiperbaruiPrefix;
  final String versiPrefix;
  final String hubungiTeks;
  final String kembali;
  final String sayaMengertiDanSetuju;
  final String gulirSampaiAkhir;
}

class KatalogKebijakan {
  const KatalogKebijakan._();

  static IsiKebijakan ambil(JenisKebijakan jenis, KodeBahasa bahasa) {
    final isEn = bahasa == KodeBahasa.en;
    final judul = _judul(jenis, isEn);
    final pasal = _pasal(jenis, isEn);
    return IsiKebijakan(
      judul: judul,
      pasal: pasal,
      kontak: isEn
          ? 'North Maluku Province Civil Registration Office'
          : 'Dinas Kependudukan dan Pencatatan Sipil Provinsi Maluku Utara',
      versi: 'v1.0',
      berlakuSejak: isEn ? 'May 22, 2026' : '22 Mei 2026',
      terakhirDiperbaruiPrefix:
          isEn ? 'Last updated' : 'Terakhir diperbarui',
      versiPrefix: isEn ? 'Version' : 'Versi',
      hubungiTeks: isEn
          ? 'Contact {kontak} for questions regarding this policy.'
          : 'Hubungi {kontak} untuk pertanyaan terkait kebijakan ini.',
      kembali: isEn ? 'Back' : 'Kembali',
      sayaMengertiDanSetuju:
          isEn ? 'I Understand and Agree' : 'Saya Mengerti dan Setuju',
      gulirSampaiAkhir: isEn
          ? 'Scroll to the bottom to enable the agree button.'
          : 'Gulir sampai akhir untuk mengaktifkan tombol setuju.',
    );
  }

  static String _judul(JenisKebijakan jenis, bool isEn) {
    switch (jenis) {
      case JenisKebijakan.privasi:
        return isEn ? 'Privacy Policy' : 'Kebijakan Privasi';
      case JenisKebijakan.layanan:
        return isEn ? 'Service Policy' : 'Kebijakan Layanan';
      case JenisKebijakan.syaratKetentuan:
        return isEn ? 'Terms & Conditions' : 'Syarat & Ketentuan';
      case JenisKebijakan.penafian:
        return isEn
            ? 'System Availability & Security Disclaimer'
            : 'Penafian Ketersediaan & Keamanan Sistem';
      case JenisKebijakan.biometrik:
        return isEn
            ? 'Biometric Data Processing Consent'
            : 'Persetujuan Pemrosesan Data Biometrik';
      case JenisKebijakan.kebenaranData:
        return isEn
            ? 'Statement of Data Truth'
            : 'Pernyataan Kebenaran Data';
    }
  }

  static List<Pasal> _pasal(JenisKebijakan jenis, bool isEn) {
    switch (jenis) {
      case JenisKebijakan.privasi:
        return isEn ? _privasiEn : _privasiId;
      case JenisKebijakan.layanan:
        return isEn ? _layananEn : _layananId;
      case JenisKebijakan.syaratKetentuan:
        return isEn ? _syaratEn : _syaratId;
      case JenisKebijakan.penafian:
        return isEn ? _penafianEn : _penafianId;
      case JenisKebijakan.biometrik:
        return isEn ? _biometrikEn : _biometrikId;
      case JenisKebijakan.kebenaranData:
        return isEn ? _kebenaranEn : _kebenaranId;
    }
  }
}

const _privasiId = <Pasal>[
  Pasal(
    '1. Dasar Hukum',
    'Kebijakan ini disusun berdasarkan Undang-Undang Nomor 23 Tahun 2006 sebagaimana diubah dengan Undang-Undang Nomor 24 Tahun 2013 tentang Administrasi Kependudukan, Undang-Undang Nomor 27 Tahun 2022 tentang Pelindungan Data Pribadi, Peraturan Pemerintah Nomor 40 Tahun 2019, Peraturan Pemerintah Nomor 71 Tahun 2019, Peraturan Presiden Nomor 96 Tahun 2018, Permendagri Nomor 108 Tahun 2019, serta Permendagri Nomor 57 Tahun 2021 tentang Sistem Manajemen Keamanan Informasi Administrasi Kependudukan.',
  ),
  Pasal(
    '2. Jenis Data yang Dikumpulkan',
    'BAKUDAPA MOBILE memproses data berikut: (a) data identitas seperti NIK, nama lengkap, tempat dan tanggal lahir, jenis kelamin, nomor HP, dan alamat surat elektronik; (b) data dokumen seperti foto KTP-el atau dokumen kependudukan lain; (c) data biometrik berupa foto wajah, rekaman video verifikasi keaktifan (liveness), rekaman suara, serta status verifikasi sidik jari; (d) metadata perangkat seperti tipe perangkat, sistem operasi, dan versi aplikasi; (e) metadata lokasi untuk keperluan audit keamanan, tidak digunakan sebagai pembatas wilayah layanan.',
  ),
  Pasal(
    '3. Tujuan Pemrosesan',
    'Data diproses untuk: (a) verifikasi identitas calon pengguna layanan administrasi kependudukan; (b) keamanan akun dan pencegahan penyalahgunaan; (c) pelayanan administrasi kependudukan sesuai kewenangan Disdukcapil Provinsi Maluku Utara; (d) audit dan jejak aktivitas sesuai Permendagri 57/2021; (e) kewajiban pelaporan kepada instansi berwenang sebagaimana diatur peraturan perundang-undangan.',
  ),
  Pasal(
    '4. Dasar Pemrosesan',
    'Pemrosesan dilakukan atas dasar persetujuan eksplisit dari subjek data dan/atau dalam rangka pelaksanaan kewajiban hukum oleh penyelenggara, sebagaimana dimaksud dalam Pasal 20 UU 27/2022 tentang Pelindungan Data Pribadi.',
  ),
  Pasal(
    '5. Penyimpanan dan Keamanan',
    'Data disimpan pada infrastruktur Disdukcapil yang mengikuti standar Sistem Manajemen Keamanan Informasi sesuai Permendagri 57/2021. Komunikasi antara aplikasi dan server menggunakan koneksi terenkripsi (HTTPS/TLS). Token akses dan data sensitif pada perangkat disimpan dalam keystore yang dienkripsi.',
  ),
  Pasal(
    '6. Hak Subjek Data',
    'Anda berhak: (a) memperoleh informasi tentang pemrosesan data pribadi; (b) meminta akses, koreksi, dan pembaruan data; (c) menarik kembali persetujuan; (d) meminta penghapusan data sesuai ketentuan; (e) mengajukan keberatan, sebagaimana dimaksud Pasal 5–14 UU 27/2022. Pelaksanaan hak ini tunduk pada pengecualian yang diatur peraturan perundang-undangan.',
  ),
  Pasal(
    '7. Pembatasan Akses',
    'Akses data oleh operator dibatasi berdasarkan peran (role-based access). Akses data sensitif dicatat dalam audit log dan hanya boleh dilakukan untuk keperluan resmi layanan administrasi kependudukan.',
  ),
  Pasal(
    '8. Retensi Data',
    'Data identitas dan dokumen pendukung disimpan selama akun aktif dan jangka waktu tertentu pasca-penutupan akun sesuai ketentuan retensi Dukcapil. Data biometrik mentah dapat dihapus lebih awal apabila tidak lagi diperlukan untuk verifikasi.',
  ),
  Pasal(
    '9. Berbagi Data',
    'Data tidak diperjualbelikan dan tidak diserahkan kepada pihak ketiga di luar instansi pemerintah yang berwenang, kecuali atas dasar peraturan perundang-undangan yang berlaku.',
  ),
  Pasal(
    '10. Perubahan Kebijakan',
    'Kebijakan ini dapat diperbarui untuk menyesuaikan ketentuan hukum atau peningkatan layanan. Versi terbaru selalu ditampilkan dalam aplikasi disertai tanggal berlaku.',
  ),
];

const _privasiEn = <Pasal>[
  Pasal(
    '1. Legal Basis',
    'This policy is established under Law No. 23 of 2006 as amended by Law No. 24 of 2013 on Population Administration, Law No. 27 of 2022 on Personal Data Protection, Government Regulation No. 40 of 2019, Government Regulation No. 71 of 2019, Presidential Regulation No. 96 of 2018, Minister of Home Affairs Regulation No. 108 of 2019, and Minister of Home Affairs Regulation No. 57 of 2021 on the Information Security Management System for Population Administration.',
  ),
  Pasal(
    '2. Types of Data Collected',
    'BAKUDAPA MOBILE processes the following data: (a) identity data such as NIK, full name, place and date of birth, gender, phone number, and email address; (b) document data such as e-KTP photos or other population documents; (c) biometric data in the form of face photos, liveness verification video, voice recordings, and fingerprint verification status; (d) device metadata such as device type, operating system, and app version; (e) location metadata for security audit purposes, not used as a service-area restriction.',
  ),
  Pasal(
    '3. Processing Purposes',
    'Data is processed for: (a) verifying the identity of prospective users of population administration services; (b) account security and abuse prevention; (c) delivering population administration services within the authority of the North Maluku Civil Registration Office; (d) auditing and activity tracking in accordance with Minister of Home Affairs Regulation 57/2021; (e) reporting obligations to authorized agencies as required by law.',
  ),
  Pasal(
    '4. Processing Basis',
    'Processing is carried out based on the explicit consent of the data subject and/or for the fulfillment of the provider\'s legal obligation, as referred to in Article 20 of Law No. 27/2022 on Personal Data Protection.',
  ),
  Pasal(
    '5. Storage and Security',
    'Data is stored on the Disdukcapil infrastructure that follows the Information Security Management System standard pursuant to Minister of Home Affairs Regulation 57/2021. Communication between the app and server uses encrypted connections (HTTPS/TLS). Access tokens and sensitive data on the device are stored in an encrypted keystore.',
  ),
  Pasal(
    '6. Rights of Data Subjects',
    'You are entitled to: (a) obtain information about the processing of personal data; (b) request access, correction, and update of data; (c) withdraw consent; (d) request data deletion in accordance with applicable provisions; (e) raise objections, as referred to in Articles 5–14 of Law 27/2022. The exercise of these rights is subject to exceptions provided by law.',
  ),
  Pasal(
    '7. Access Restrictions',
    'Operator access is restricted on a role-based basis. Access to sensitive data is logged in an audit trail and is only permitted for official population administration purposes.',
  ),
  Pasal(
    '8. Data Retention',
    'Identity data and supporting documents are stored while the account is active and for a certain period after account closure in accordance with Disdukcapil retention policies. Raw biometric data may be deleted earlier if no longer required for verification.',
  ),
  Pasal(
    '9. Data Sharing',
    'Data is not sold and is not provided to third parties outside authorized government agencies, except as required by applicable law.',
  ),
  Pasal(
    '10. Policy Changes',
    'This policy may be updated to comply with legal requirements or to improve services. The latest version is always displayed in the app together with the effective date.',
  ),
];

const _layananId = <Pasal>[
  Pasal(
    '1. Ruang Lingkup',
    'BAKUDAPA MOBILE merupakan kanal digital resmi Dinas Kependudukan dan Pencatatan Sipil Provinsi Maluku Utara untuk pengajuan, pencatatan, dan pemantauan layanan administrasi kependudukan sebagaimana dimaksud dalam Undang-Undang Nomor 23 Tahun 2006 jo. Undang-Undang Nomor 24 Tahun 2013, Perpres 96/2018, serta Permendagri 108/2019.',
  ),
  Pasal(
    '2. Penerimaan Ketentuan',
    'Dengan menggunakan aplikasi, Anda menyatakan telah membaca, memahami, dan menyetujui seluruh ketentuan layanan, kebijakan privasi, dan dokumen pendukung lain yang dipublikasikan dalam aplikasi.',
  ),
  Pasal(
    '3. Akun Pengguna',
    'Anda bertanggung jawab atas kerahasiaan kredensial akun, termasuk kata sandi, kode OTP, biometrik perangkat, dan token akses. Aktivitas yang terjadi pada akun Anda merupakan tanggung jawab pemilik akun.',
  ),
  Pasal(
    '4. Kewajiban Pemohon',
    'Pemohon wajib mengisi data dengan benar serta menyertakan dokumen yang sah. Pemalsuan data, penyalahgunaan identitas orang lain, atau pemberian dokumen tidak sah dapat dikenai sanksi pidana sebagaimana diatur peraturan perundang-undangan.',
  ),
  Pasal(
    '5. Proses Verifikasi Operator',
    'Permohonan diverifikasi oleh operator/petugas berwenang Disdukcapil. Proses verifikasi membutuhkan waktu dan dapat mengalami antrean. Disdukcapil berhak menolak permohonan yang tidak memenuhi syarat.',
  ),
  Pasal(
    '6. Layanan Tidak Berbayar',
    'Layanan administrasi kependudukan dasar tidak dipungut biaya. Tidak ada permintaan pembayaran ke rekening pribadi. Laporkan setiap dugaan pungutan tidak resmi kepada Inspektorat atau saluran pengaduan resmi.',
  ),
  Pasal(
    '7. Penggunaan Aplikasi',
    'Anda dilarang menggunakan aplikasi untuk tujuan yang melawan hukum, melakukan rekayasa balik, mengakses sistem tanpa hak, atau menyebarkan kode berbahaya. Pelanggaran dapat berakibat pembatalan akun dan tindakan hukum.',
  ),
  Pasal(
    '8. Pembatasan Tanggung Jawab',
    'Keputusan akhir mengenai keabsahan dokumen dan penerbitan dokumen kependudukan tetap berada pada pejabat berwenang Disdukcapil. Aplikasi merupakan sarana pengajuan, bukan keputusan administratif final.',
  ),
];

const _layananEn = <Pasal>[
  Pasal(
    '1. Scope',
    'BAKUDAPA MOBILE is the official digital channel of the North Maluku Province Civil Registration Office for submitting, recording, and monitoring population administration services as referred to in Law No. 23 of 2006 jo. Law No. 24 of 2013, Presidential Regulation 96/2018, and Minister of Home Affairs Regulation 108/2019.',
  ),
  Pasal(
    '2. Acceptance of Terms',
    'By using the app, you confirm that you have read, understood, and agreed to all terms of service, the privacy policy, and other supporting documents published in the app.',
  ),
  Pasal(
    '3. User Account',
    'You are responsible for the confidentiality of your account credentials, including password, OTP code, device biometrics, and access tokens. Activities that occur on your account are the responsibility of the account holder.',
  ),
  Pasal(
    '4. Applicant Obligations',
    'Applicants must enter accurate data and provide valid documents. Falsifying data, misusing another person\'s identity, or providing invalid documents may be subject to criminal sanctions as provided by law.',
  ),
  Pasal(
    '5. Operator Verification Process',
    'Applications are verified by authorized Disdukcapil operators/officers. The verification process requires time and may experience queues. Disdukcapil reserves the right to reject applications that do not meet the requirements.',
  ),
  Pasal(
    '6. Free of Charge',
    'Basic population administration services are free of charge. There is no request for payment to personal accounts. Report any suspected unofficial fees to the Inspectorate or the official complaint channel.',
  ),
  Pasal(
    '7. App Usage',
    'You are prohibited from using the app for unlawful purposes, reverse engineering, unauthorized system access, or distributing malicious code. Violations may result in account termination and legal action.',
  ),
  Pasal(
    '8. Limitation of Liability',
    'Final decisions regarding document validity and the issuance of population documents remain with the authorized Disdukcapil official. The app is a submission channel, not a final administrative decision.',
  ),
];

const _penafianId = <Pasal>[
  Pasal(
    '1. Upaya Ketersediaan',
    'Sistem BAKUDAPA MOBILE diupayakan tersedia selama 24 jam dengan mekanisme pemulihan dan pemantauan layanan sesuai standar Permendagri 57/2021 dan PP 71/2019 tentang Penyelenggaraan Sistem dan Transaksi Elektronik.',
  ),
  Pasal(
    '2. Faktor di Luar Kendali',
    'Akses pengguna dapat terganggu oleh faktor di luar kendali langsung penyelenggara, antara lain: (a) jaringan internet pengguna; (b) layanan operator seluler; (c) gangguan pada infrastruktur cloud/server penyedia; (d) kondisi perangkat pengguna; (e) integrasi pihak ketiga; (f) pemeliharaan terjadwal; serta (g) keadaan kahar (force majeure) seperti bencana alam, gangguan keamanan informasi nasional, atau gangguan teknologi berskala luas.',
  ),
  Pasal(
    '3. Pemeliharaan Sistem',
    'Sistem dapat dihentikan sementara untuk pemeliharaan rutin atau pembaruan keamanan. Pemberitahuan diupayakan melalui aplikasi atau kanal resmi Disdukcapil sepanjang kondisi memungkinkan.',
  ),
  Pasal(
    '4. Upaya Pemulihan',
    'Pada saat gangguan terjadi, penyelenggara melakukan pencatatan insiden, mitigasi, serta upaya pemulihan layanan dalam waktu yang wajar. Penyelenggara tetap bertanggung jawab atas hal-hal yang berada dalam kendali langsungnya sesuai prinsip kewajaran.',
  ),
  Pasal(
    '5. Kebenaran Data',
    'Kebenaran data yang dimasukkan menjadi tanggung jawab pengguna. Kesalahan pengisian yang menyebabkan kegagalan layanan bukan menjadi tanggung jawab penyelenggara, namun pengguna tetap berhak mengajukan perbaikan sesuai prosedur.',
  ),
  Pasal(
    '6. Kondisi Darurat',
    'Pada situasi darurat keamanan informasi atau bencana, sebagian fitur dapat dinonaktifkan sementara untuk melindungi data pengguna dan integritas sistem.',
  ),
];

const _penafianEn = <Pasal>[
  Pasal(
    '1. Availability Effort',
    'The BAKUDAPA MOBILE system is intended to be available 24 hours with recovery and service monitoring mechanisms in accordance with Minister of Home Affairs Regulation 57/2021 and Government Regulation 71/2019 on the Operation of Electronic Systems and Transactions.',
  ),
  Pasal(
    '2. Factors Beyond Control',
    "User access may be disrupted by factors beyond the provider's direct control, including: (a) the user's internet network; (b) mobile operator services; (c) disruptions in cloud/provider server infrastructure; (d) user device condition; (e) third-party integrations; (f) scheduled maintenance; and (g) force majeure such as natural disasters, national information security incidents, or large-scale technology disruptions.",
  ),
  Pasal(
    '3. System Maintenance',
    'The system may be temporarily suspended for routine maintenance or security updates. Notifications will be issued via the app or official Disdukcapil channels whenever circumstances permit.',
  ),
  Pasal(
    '4. Recovery Effort',
    'When disruptions occur, the provider records the incident, mitigates, and works to restore services within a reasonable time. The provider remains responsible for matters within its direct control according to the principle of reasonableness.',
  ),
  Pasal(
    '5. Data Accuracy',
    'The accuracy of the data entered is the responsibility of the user. Filling errors that cause service failure are not the responsibility of the provider, but the user has the right to request corrections according to the procedure.',
  ),
  Pasal(
    '6. Emergency Conditions',
    'In situations of information security emergencies or disasters, some features may be temporarily disabled to protect user data and system integrity.',
  ),
];

const _biometrikId = <Pasal>[
  Pasal(
    '1. Jenis Data Biometrik',
    'Data biometrik yang diproses untuk verifikasi registrasi mencakup: foto wajah, rekaman video verifikasi keaktifan (liveness), rekaman suara singkat, serta status verifikasi sidik jari. Apabila menggunakan sensor sidik jari perangkat, aplikasi hanya menerima status berhasil/gagal — data sidik jari mentah tidak meninggalkan perangkat Anda.',
  ),
  Pasal(
    '2. Tujuan Pemrosesan',
    'Data biometrik diproses untuk: (a) memastikan pemohon adalah subjek data sah; (b) deteksi pemalsuan dokumen dan pencegahan pendaftaran ganda; (c) pencegahan akses tidak sah; (d) memenuhi standar verifikasi identitas sebagaimana dimaksud peraturan perundang-undangan administrasi kependudukan.',
  ),
  Pasal(
    '3. Dasar Hukum',
    'Pemrosesan data biometrik tunduk pada Undang-Undang Nomor 27 Tahun 2022 tentang Pelindungan Data Pribadi, khususnya ketentuan mengenai data pribadi yang bersifat spesifik, serta UU 23/2006 jo. UU 24/2013 tentang Administrasi Kependudukan.',
  ),
  Pasal(
    '4. Pengamanan dan Pengiriman',
    'Data biometrik dikirim ke backend melalui koneksi terenkripsi (HTTPS/TLS) dan disimpan pada infrastruktur yang mematuhi Permendagri 57/2021. Akses operator dibatasi berdasarkan peran dan tercatat dalam audit log.',
  ),
  Pasal(
    '5. Pembatasan Akses Operator',
    'Raw data biometrik (foto/video/audio mentah) tidak ditampilkan pada antarmuka operator umum. Akses pada data mentah hanya diberikan kepada peran tertentu dengan otorisasi khusus dan dicatat secara audit.',
  ),
  Pasal(
    '6. Retensi dan Penghapusan',
    'Data biometrik disimpan selama akun aktif untuk kebutuhan verifikasi. Anda dapat mengajukan penghapusan dengan menutup akun, dengan pengecualian sesuai retensi minimum yang diatur perundang-undangan.',
  ),
  Pasal(
    '7. Persetujuan Eksplisit',
    'Pemrosesan data biometrik dilakukan setelah Anda memberikan persetujuan secara eksplisit melalui aplikasi. Anda dapat menarik kembali persetujuan dengan menutup akun dan mengajukan permintaan penghapusan data.',
  ),
  Pasal(
    '8. Tidak Diperjualbelikan',
    'Data biometrik tidak diperjualbelikan, tidak disewakan, dan tidak diserahkan kepada pihak ketiga di luar instansi pemerintah yang berwenang.',
  ),
];

const _biometrikEn = <Pasal>[
  Pasal(
    '1. Types of Biometric Data',
    'Biometric data processed for registration verification includes: face photo, liveness verification video recording, a short voice recording, and fingerprint verification status. When using the device fingerprint sensor, the app only receives a success/failure status — raw fingerprint data never leaves your device.',
  ),
  Pasal(
    '2. Processing Purposes',
    'Biometric data is processed to: (a) ensure the applicant is the legitimate data subject; (b) detect document forgery and prevent duplicate registration; (c) prevent unauthorized access; (d) meet identity verification standards as referred to in population administration regulations.',
  ),
  Pasal(
    '3. Legal Basis',
    'Biometric data processing is governed by Law No. 27 of 2022 on Personal Data Protection, in particular the provisions concerning specific personal data, and Law 23/2006 jo. Law 24/2013 on Population Administration.',
  ),
  Pasal(
    '4. Security and Transmission',
    'Biometric data is transmitted to the backend through encrypted connections (HTTPS/TLS) and stored on infrastructure compliant with Minister of Home Affairs Regulation 57/2021. Operator access is restricted by role and recorded in the audit log.',
  ),
  Pasal(
    '5. Operator Access Restrictions',
    'Raw biometric data (raw photos/videos/audio) is not displayed on the general operator interface. Access to raw data is granted only to certain roles with special authorization and is audit-logged.',
  ),
  Pasal(
    '6. Retention and Deletion',
    'Biometric data is stored while the account is active for verification purposes. You may request deletion by closing your account, subject to minimum retention requirements set by law.',
  ),
  Pasal(
    '7. Explicit Consent',
    'Biometric data processing is performed after you provide explicit consent through the app. You may withdraw consent by closing your account and submitting a data deletion request.',
  ),
  Pasal(
    '8. No Commercial Sale',
    'Biometric data is not sold, leased, or shared with third parties outside authorized government agencies.',
  ),
];

const _kebenaranId = <Pasal>[
  Pasal(
    '1. Pernyataan Pengguna',
    'Saya menyatakan dengan sesungguhnya bahwa seluruh data identitas, dokumen, foto, video, dan rekaman suara yang saya berikan adalah benar, sah, lengkap, serta merupakan milik pribadi saya.',
  ),
  Pasal(
    '2. Tanggung Jawab Hukum',
    'Apabila di kemudian hari ditemukan adanya pemalsuan, manipulasi, atau penggunaan identitas pihak lain, saya bersedia menanggung seluruh akibat hukum sesuai ketentuan peraturan perundang-undangan, termasuk sanksi pidana sebagaimana diatur dalam Undang-Undang Administrasi Kependudukan dan ketentuan lain yang berlaku.',
  ),
  Pasal(
    '3. Hak Penyelenggara',
    'Disdukcapil Provinsi Maluku Utara berhak menolak, membatalkan, atau menarik kembali layanan yang telah diberikan apabila data terbukti tidak benar atau merupakan hasil pemalsuan.',
  ),
  Pasal(
    '4. Kesediaan Diverifikasi',
    'Saya bersedia mengikuti proses verifikasi, klarifikasi, dan kunjungan lapangan apabila diperlukan oleh operator/petugas berwenang dalam rangka memastikan kebenaran data.',
  ),
  Pasal(
    '5. Pernyataan Tanpa Tekanan',
    'Saya membuat pernyataan ini dengan kesadaran penuh, dalam keadaan sehat, dan tanpa paksaan atau tekanan dari pihak manapun.',
  ),
];

const _kebenaranEn = <Pasal>[
  Pasal(
    '1. User Statement',
    'I truly declare that all identity data, documents, photos, videos, and voice recordings I provide are true, valid, complete, and belong to me personally.',
  ),
  Pasal(
    '2. Legal Responsibility',
    'If at a later time falsification, manipulation, or use of another person\'s identity is found, I am willing to bear all legal consequences in accordance with applicable laws, including criminal sanctions as provided in the Population Administration Law and other applicable provisions.',
  ),
  Pasal(
    '3. Provider Rights',
    'The North Maluku Province Civil Registration Office reserves the right to reject, cancel, or withdraw services that have been granted if data is proven inaccurate or fabricated.',
  ),
  Pasal(
    '4. Willingness to Be Verified',
    'I am willing to undergo verification, clarification, and on-site visits where required by authorized operators/officers to confirm the accuracy of the data.',
  ),
  Pasal(
    '5. Statement Without Coercion',
    'I make this statement with full awareness, in good health, and without coercion or pressure from any party.',
  ),
];

const _syaratId = <Pasal>[
  Pasal(
    '1. Penerimaan Syarat',
    'Dengan mengunduh, memasang, mendaftar, dan/atau menggunakan aplikasi BAKUDAPA MOBILE, Anda secara sah dianggap telah membaca, memahami, dan menyetujui seluruh Syarat & Ketentuan ini. Apabila Anda tidak menyetujui sebagian atau seluruhnya, mohon untuk tidak menggunakan aplikasi.',
  ),
  Pasal(
    '2. Definisi',
    '(a) "Penyelenggara" adalah Dinas Kependudukan dan Pencatatan Sipil Provinsi Maluku Utara. (b) "Pengguna" adalah Warga Negara Indonesia atau pihak berwenang yang menggunakan aplikasi. (c) "Akun" adalah identitas digital pengguna yang diverifikasi. (d) "Layanan" adalah seluruh fitur administrasi kependudukan yang disediakan melalui aplikasi.',
  ),
  Pasal(
    '3. Kelayakan Pengguna',
    'Pengguna minimal berusia 17 tahun dan/atau telah memiliki NIK yang sah. Pengguna di bawah usia tersebut wajib menggunakan aplikasi dengan pendampingan orang tua atau wali sesuai dengan ketentuan administrasi kependudukan yang berlaku.',
  ),
  Pasal(
    '4. Pendaftaran dan Verifikasi',
    'Pengguna wajib mengisi data identitas yang sebenarnya dan menyelesaikan rangkaian verifikasi (NIK, OTP, foto wajah, liveness, suara, dan/atau sidik jari). Verifikasi tidak menjamin keberhasilan pengajuan layanan; keputusan akhir tetap pada operator berwenang Disdukcapil.',
  ),
  Pasal(
    '5. Tanggung Jawab Akun',
    'Pengguna bertanggung jawab penuh atas seluruh aktivitas yang terjadi pada akunnya. Pengguna wajib menjaga kerahasiaan kredensial (kata sandi, OTP, biometrik, dan token akses) serta segera melapor ke saluran resmi apabila terjadi dugaan penyalahgunaan akun.',
  ),
  Pasal(
    '6. Larangan Penggunaan',
    'Pengguna dilarang: (a) memberikan data palsu atau menggunakan identitas orang lain; (b) melakukan rekayasa balik, dekompilasi, atau modifikasi aplikasi; (c) mengakses sistem secara tidak sah; (d) menyebarkan kode berbahaya, virus, atau script otomatis; (e) menggunakan aplikasi untuk aktivitas melawan hukum atau merugikan pihak lain.',
  ),
  Pasal(
    '7. Hak Kekayaan Intelektual',
    'Seluruh hak cipta, merek, logo, dan kekayaan intelektual lainnya yang terkait dengan aplikasi BAKUDAPA MOBILE merupakan milik Penyelenggara atau pemberi lisensi yang sah. Pengguna tidak diperbolehkan menggandakan, mendistribusikan, atau memodifikasi konten aplikasi tanpa izin tertulis.',
  ),
  Pasal(
    '8. Pembaruan Aplikasi',
    'Penyelenggara berhak memperbarui aplikasi sewaktu-waktu untuk perbaikan, peningkatan fitur, atau pemenuhan ketentuan hukum. Pengguna diharapkan menggunakan versi terbaru untuk memperoleh pengalaman dan keamanan optimal.',
  ),
  Pasal(
    '9. Penghentian Akses',
    'Penyelenggara berhak membatasi atau menonaktifkan akun pengguna apabila terdapat indikasi pelanggaran terhadap Syarat & Ketentuan ini, pelanggaran hukum, atau alasan keamanan informasi. Pengguna dapat mengajukan klarifikasi melalui saluran resmi Disdukcapil.',
  ),
  Pasal(
    '10. Pembatasan Tanggung Jawab',
    'Penyelenggara akan berupaya memberikan layanan terbaik, namun tidak dapat menjamin aplikasi bebas dari gangguan teknis, kesalahan, atau keadaan kahar. Penyelenggara tidak bertanggung jawab atas kerugian tidak langsung yang timbul akibat penggunaan aplikasi di luar kewenangan dan kendalinya.',
  ),
  Pasal(
    '11. Hukum yang Berlaku',
    'Syarat & Ketentuan ini tunduk pada hukum Republik Indonesia, khususnya UU 23/2006 jo. UU 24/2013 tentang Administrasi Kependudukan, UU 11/2008 jo. UU 19/2016 tentang Informasi dan Transaksi Elektronik, UU 27/2022 tentang Pelindungan Data Pribadi, serta peraturan pelaksanaan terkait.',
  ),
  Pasal(
    '12. Penyelesaian Sengketa',
    'Setiap sengketa yang timbul dari penggunaan aplikasi diupayakan diselesaikan secara musyawarah. Apabila tidak tercapai mufakat, penyelesaian dilakukan melalui mekanisme hukum di wilayah Provinsi Maluku Utara sesuai ketentuan yang berlaku.',
  ),
  Pasal(
    '13. Perubahan Syarat & Ketentuan',
    'Penyelenggara dapat memperbarui Syarat & Ketentuan ini sewaktu-waktu. Versi terbaru akan ditampilkan dalam aplikasi dengan tanggal berlaku. Penggunaan aplikasi setelah pembaruan berarti pengguna menerima ketentuan baru tersebut.',
  ),
];

const _syaratEn = <Pasal>[
  Pasal(
    '1. Acceptance of Terms',
    'By downloading, installing, registering, and/or using the BAKUDAPA MOBILE application, you are deemed to have read, understood, and agreed to all of these Terms & Conditions. If you do not agree to any or all of them, please do not use the application.',
  ),
  Pasal(
    '2. Definitions',
    '(a) "Provider" means the Civil Registration Office of North Maluku Province. (b) "User" means an Indonesian citizen or authorized party who uses the application. (c) "Account" means the digital identity of a verified user. (d) "Service" means all population administration features provided through the application.',
  ),
  Pasal(
    '3. User Eligibility',
    'Users must be at least 17 years old and/or already hold a valid NIK. Users below that age must use the application under the supervision of a parent or guardian in accordance with applicable population administration regulations.',
  ),
  Pasal(
    '4. Registration and Verification',
    'Users must enter accurate identity data and complete the verification sequence (NIK, OTP, face photo, liveness, voice, and/or fingerprint). Verification does not guarantee the success of a service request; the final decision remains with the authorized Disdukcapil operator.',
  ),
  Pasal(
    '5. Account Responsibility',
    'Users are fully responsible for all activities that occur on their accounts. Users must safeguard the confidentiality of their credentials (password, OTP, biometrics, and access tokens) and promptly report any suspected misuse to the official channel.',
  ),
  Pasal(
    '6. Prohibited Usage',
    'Users are prohibited from: (a) providing false data or using another person\'s identity; (b) reverse engineering, decompiling, or modifying the application; (c) accessing the system without authorization; (d) distributing malware, viruses, or automated scripts; (e) using the application for unlawful activities or to harm other parties.',
  ),
  Pasal(
    '7. Intellectual Property',
    'All copyrights, trademarks, logos, and other intellectual property rights related to the BAKUDAPA MOBILE application belong to the Provider or its legitimate licensors. Users may not reproduce, distribute, or modify the application content without written permission.',
  ),
  Pasal(
    '8. Application Updates',
    'The Provider has the right to update the application at any time for improvements, feature enhancements, or to comply with legal requirements. Users are expected to use the latest version for an optimal and secure experience.',
  ),
  Pasal(
    '9. Access Termination',
    'The Provider has the right to restrict or deactivate a user account if there are indications of violations of these Terms & Conditions, legal violations, or information security concerns. Users may request clarification through the official Disdukcapil channel.',
  ),
  Pasal(
    '10. Limitation of Liability',
    'The Provider will endeavor to deliver the best service but cannot guarantee that the application will be free of technical disruptions, errors, or force majeure events. The Provider is not liable for indirect losses arising from use of the application beyond its authority and control.',
  ),
  Pasal(
    '11. Governing Law',
    'These Terms & Conditions are governed by the laws of the Republic of Indonesia, in particular Law 23/2006 jo. Law 24/2013 on Population Administration, Law 11/2008 jo. Law 19/2016 on Electronic Information and Transactions, Law 27/2022 on Personal Data Protection, and related implementing regulations.',
  ),
  Pasal(
    '12. Dispute Resolution',
    'Any disputes arising from the use of the application shall first be resolved through deliberation. If consensus cannot be reached, resolution shall proceed through legal mechanisms within North Maluku Province in accordance with applicable provisions.',
  ),
  Pasal(
    '13. Changes to Terms & Conditions',
    'The Provider may update these Terms & Conditions at any time. The latest version will be displayed in the application with its effective date. Continued use of the application after an update means the user accepts the new provisions.',
  ),
];
