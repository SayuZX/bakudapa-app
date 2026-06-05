import 'teks.dart';

class TeksEn extends Teks {
  const TeksEn();
  @override
  String get lanjut => 'Continue';
  @override
  String get lanjutkan => 'Continue';
  @override
  String get kembali => 'Back';
  @override
  String get selesai => 'Done';
  @override
  String get batal => 'Cancel';
  @override
  String get setuju => 'Agree';
  @override
  String get sayaMengertiDanSetuju => 'I Understand and Agree';
  @override
  String get cobaLagi => 'Try Again';
  @override
  String get tetapLanjutkan => 'Continue Anyway';
  @override
  String get prosesVerifikasiAiJudul => 'Verification in progress';
  @override
  String get prosesVerifikasiAiSub =>
      'Our AI is checking the authenticity and completeness of your biometric data. Please wait a moment.';
  @override
  String get langkahAiKirimIdentitas => 'Sending identity data...';
  @override
  String get langkahAiKirimDokumen => 'Uploading verification files...';
  @override
  String get langkahAiAnalisisFoto => 'Analyzing face photo match...';
  @override
  String get langkahAiAnalisisLiveness => 'AI verifying liveness...';
  @override
  String get langkahAiAnalisisSuara => 'Validating voice recording...';
  @override
  String get langkahAiMenyelesaikan => 'Saving verification result...';
  @override
  String get jangantutupHalamanIni =>
      'Do not close or leave this page.';
  @override
  String get ulangi => 'Retry';
  @override
  String get mulai => 'Start';
  @override
  String get keluar => 'Sign Out';
  @override
  String get keluarAplikasi => 'Exit App';
  @override
  String get bukaPengaturan => 'Open Settings';
  @override
  String get tutup => 'Close';
  @override
  String get kirim => 'Submit';
  @override
  String get edit => 'Edit';
  @override
  String get lewati => 'Skip';
  @override
  String get nanti => 'Later';
  @override
  String get masuk => 'Sign In';
  @override
  String get daftar => 'Register';
  @override
  String get registrasi => 'Registration';
  @override
  String get verifikasiAkun => 'Account Verification';
  @override
  String get masukDenganAkun => 'Sign in with your\nDisdukcapil account';
  @override
  String get gunakanNikAtau =>
      'Use your 16-digit NIK, email, or registered phone number.';
  @override
  String get nikEmailNoHp => 'NIK / Email / Phone Number';
  @override
  String get kataSandi => 'Password';
  @override
  String get lupaKataSandi => 'Forgot password?';
  @override
  String get belumPunyaAkun => "Don't have an account?";
  @override
  String get sudahPunyaAkun => 'Already have an account?';
  @override
  String get atauMasukMenggunakan => 'Or sign in with';
  @override
  String get masukkanKodeUnik => 'Enter the unique code we sent';
  @override
  String get periksaSms => 'Check your SMS and enter the 6-digit code';
  @override
  String get kirimUlang => 'Resend';
  @override
  String get butuhBantuan => 'Need help signing in?';
  @override
  String get hubungiDisdukcapil => 'Contact Disdukcapil';
  @override
  String langkahXDariY(int current, int total) => 'Step $current of $total';
  @override
  String get dataIdentitas => 'Identity Data';
  @override
  String get dataIdentitasDasar => 'Basic identity data';
  @override
  String get pastikanDataSesuaiKtp =>
      'Make sure your data matches your e-KTP.';
  @override
  String get nik => 'NIK';
  @override
  String get namaLengkap => 'Full Name';
  @override
  String get tanggalLahir => 'Date of Birth';
  @override
  String get tempatLahir => 'Place of Birth';
  @override
  String get jenisKelamin => 'Gender';
  @override
  String get lakiLaki => 'Male';
  @override
  String get perempuan => 'Female';
  @override
  String get nomorHp => 'Phone Number';
  @override
  String get email => 'Email';
  @override
  String get pilih => 'Select';
  @override
  String get pilihTanggal => 'Select date';
  @override
  String get fotoKtpEl => 'e-KTP Photo';
  @override
  String get fotoKtp => 'KTP Photo';
  @override
  String get fotoWajah => 'Face Photo';
  @override
  String get ambilFotoKtp => 'Take e-KTP photo';
  @override
  String get ambilFotoWajah => 'Take face photo';
  @override
  String get periksaFotoWajah => 'Review face photo';
  @override
  String get pengambilanFotoWajah => 'Face photo capture';
  @override
  String get fotoWajahDigunakan =>
      'A single neutral face photo, to be matched against your e-KTP photo data.';
  @override
  String get posisikanWajahDiLingkaran => 'Place your face inside the circle';
  @override
  String get pastikanWajahJelas =>
      'Make sure your face is clearly visible and well-lit.';
  @override
  String get gunakanFotoIni => 'Use This Photo';
  @override
  String get lanjutKeLiveness => 'Continue to Liveness';
  @override
  String get sisaPercobaan => 'Remaining attempts';
  @override
  String get terlaluJauh => 'Too far';
  @override
  String get terlaluDekat => 'Too close';
  @override
  String get geserKeTengah => 'Move to center';
  @override
  String get wajahTidakTerdeteksi => 'Face not detected';
  @override
  String get wajahTerdeteksi => 'Face detected';
  @override
  String get wajahSiap => 'Face ready';
  @override
  String get verifikasiWajah => 'Face Verification';
  @override
  String get verifikasiWajahAktif => 'Active face verification';
  @override
  String get mulaiVerifikasi => 'Start Verification';
  @override
  String get mulaiVerifikasiLiveness => 'Start Liveness Verification';
  @override
  String get bersiap => 'Ready';
  @override
  String get sedangMerekam => 'Recording';
  @override
  String get kameraDitolak => 'Camera denied';
  @override
  String get aksesKameraDitolak => 'Camera Access Denied';
  @override
  String get verifikasiSuara => 'Voice Verification';
  @override
  String get ucapkanKalimatBerikut => 'Say the following sentence';
  @override
  String get tekanTombolRekam =>
      'Press the record button, then say the sentence below clearly.';
  @override
  String get rekamanTersedia => 'Recording available';
  @override
  String get lanjutKeReview => 'Continue to Review';
  @override
  String get verifikasiSidikJari => 'Fingerprint Verification';
  @override
  String get masukDenganBiometrik => 'Sign in with Biometrics';
  @override
  String get persetujuanSebelumAktivasi => 'Consent before activation';
  @override
  String get mulaiVerifikasiSidikJari => 'Start Fingerprint Verification';
  @override
  String get tempelkanJariSensor => 'Place your finger on the sensor';
  @override
  String get sidikJariBerhasilDiverifikasi =>
      'Fingerprint verified successfully';
  @override
  String get verifikasiBelumBerhasil => 'Verification not yet successful';
  @override
  String get sensorSidikJariSiap => 'Fingerprint sensor ready';
  @override
  String get sidikJariTidakTersedia => 'Fingerprint not available';
  @override
  String get tinjauData => 'Review Data';
  @override
  String get tinjauDataAnda => 'Review your data';
  @override
  String get persetujuan => 'Agreement';
  @override
  String get persetujuanKebijakan => 'Policy Agreement';
  @override
  String get kirimRegistrasi => 'Submit Registration';
  @override
  String get kebijakanPrivasi => 'Privacy Policy';
  @override
  String get kebijakanLayanan => 'Service Policy';
  @override
  String get penafianSistem => 'System Disclaimer';
  @override
  String get pemrosesanDataBiometrik => 'Biometric Data Processing';
  @override
  String get pernyataanKebenaranData => 'Data Truth Declaration';
  @override
  String get bacaKebijakan => 'Read Policy';
  @override
  String get bacaDulu => 'Read first';
  @override
  String get gulirSampaiAkhir =>
      'Scroll to the bottom to enable the agree button.';
  @override
  String get verifikasiBerhasilDikirim =>
      'Verification Successfully Submitted';
  @override
  String get menungguVerifikasiOperator => 'Awaiting Operator Verification';
  @override
  String get registrasiBerhasil => 'Registration Successful';
  @override
  String get registrasiDitolak => 'Registration Rejected';
  @override
  String get nomorRegistrasi => 'Registration Number';
  @override
  String get tanggalPengajuan => 'Submission Date';
  @override
  String get menyiapkan => 'Preparing';
  @override
  String get aktif => 'Active';
  @override
  String get cariWajah => 'Find face';
  @override
  String get hintNik => '16-digit Population Identification Number';
  @override
  String get hintNoHp => '8xxxxxxxxxx';
  @override
  String get hintNamaSesuaiKtp => 'As shown on e-KTP';
  @override
  String get hintTempatLahir => 'e.g., Ternate';
  @override
  String get hintEmail => 'name@email.com';
  @override
  String get sessionExpired => 'Your session has ended. Please sign in again.';
  @override
  String get jaringanBermasalah => 'Please check your internet connection.';
  @override
  String get terjadiKesalahan => 'An unexpected error occurred.';
  @override
  String get mohonTunggu => 'Please wait…';
  @override
  String get pilihBahasa => 'Choose Language';
  @override
  String get bahasaAntarmuka => 'App interface language';
  @override
  String get selamatDatang =>
      'Signed in successfully. Welcome to BAKUDAPA MOBILE.';
  @override
  String get aksesDitolak => 'Access Denied';
  @override
  String get akunDiblokir => 'Account Blocked';
  @override
  String get terlaluBanyakPercobaan => 'Too Many Attempts';
  @override
  String get tidakDapatMasuk => 'Unable to sign in. Please try again.';
  @override
  String get mohonTungguSebentar =>
      'Please wait a moment before trying again.';
  @override
  String get periksaDataLogin => 'Please re-check your login details';
  @override
  String get denganMasukSayaSetuju => 'By signing in, I agree to the ';
  @override
  String get syaratKetentuan => 'Terms & Conditions';
  @override
  String get danPenghubung => ' and ';
  @override
  String get disdukcapilSuffix => ' of Disdukcapil Maluku Utara.';
  @override
  String get lupaKataSandiJudul => 'Forgot Password?';
  @override
  String get masukkanNikEmail =>
      'Enter your registered NIK or email. We will send a link to create a new password.';
  @override
  String get nikEmail => 'NIK / Email';
  @override
  String get kirimTautanReset => 'Send Reset Link';
  @override
  String get kembaliKeHalamanMasuk => 'Back to sign in';
  @override
  String get tautanResetTerkirim => 'Reset link has been sent to your email.';
  @override
  String get verifikasiBerhasil => 'Verification successful.';
  @override
  String get kodeTerkirimUlang => 'Verification code has been resent.';
  @override
  String get tidakMenerimaSms => "Didn't receive an SMS? ";
  @override
  String get kirimKodeLewatEmail => 'Send code via email';
  @override
  String get kirimKodeLewatTelepon => 'Send code via phone';
  @override
  String kirimUlangDalam(int detik) => 'Resend in ${detik}s';
  @override
  String silakanPeriksaSmsKe(String tujuan) =>
      'Check your SMS and enter the 6-digit code we sent to $tujuan';
  @override
  String get kataSandiLabel => 'Password';
  @override
  String get tanggalLahirWajib => 'Date of birth is required.';
  @override
  String get jenisKelaminWajib => 'Gender is required.';
  @override
  String get gagalMemprosesIdentitas => 'Failed to process identity.';
  @override
  String get bantuanNoHpTanpaNol =>
      'Without leading zero. Example: 81234567890';
  @override
  String get namaLengkapLabel => 'Full name';
  @override
  String get tempatLahirLabel => 'Place of birth';
  @override
  String get tidakDapatBukaKameraDepan => 'Unable to open front camera.';
  @override
  String get gagalMengambilFoto => 'Failed to capture photo. Please try again.';
  @override
  String get gagalMenyimpanVideoLiveness =>
      'Failed to save liveness video.';
  @override
  String get kualitasFotoBaik => 'Photo quality is good';
  @override
  String get memeriksa => 'Checking…';
  @override
  String get menyelesaikan => 'Finishing…';
  @override
  String get langkahIntroFotoWajah1Judul => 'Turn on the front camera';
  @override
  String get langkahIntroFotoWajah1Deskripsi =>
      'You will take only one still photo, not a video. Make sure the front camera is accessible.';
  @override
  String get langkahIntroFotoWajah2Judul =>
      'Neutral pose facing the camera';
  @override
  String get langkahIntroFotoWajah2Deskripsi =>
      'Look straight at the lens, do not smile or tilt your head. Hold still when the button is tapped.';
  @override
  String get langkahIntroFotoWajah3Judul =>
      'Even front-facing lighting';
  @override
  String get langkahIntroFotoWajah3Deskripsi =>
      'Avoid backlighting or single-side lamps that create harsh shadows on your cheeks.';
  @override
  String get langkahIntroFotoWajah4Judul => 'Unobstructed face';
  @override
  String get langkahIntroFotoWajah4Deskripsi =>
      'Remove masks, sunglasses, hats, and front hair ties. Forehead, eyes, nose, and mouth must be fully visible.';
  @override
  String catatanSisaPercobaan(int sisa) =>
      'You have $sisa attempts remaining. Follow the guide above so the next attempt succeeds.';
  @override
  String get catatanKualitasFoto =>
      'The system will check the photo quality (brightness, focus, no blur) before sending it for verification.';
  @override
  String get subJudulIntroLiveness =>
      'A short movement-based check — not a photo — to prove your face is real.';
  @override
  String get langkahIntroLiveness1Judul =>
      'The camera will record for ~10 seconds';
  @override
  String get langkahIntroLiveness1Deskripsi =>
      'Unlike the photo step, this uses a short video to read your facial movements.';
  @override
  String get langkahIntroLiveness2Judul =>
      'Keep your face inside the circle';
  @override
  String get langkahIntroLiveness2Deskripsi =>
      'While recording, your face must stay inside the guide circle even when you turn or nod.';
  @override
  String get langkahIntroLiveness3Judul =>
      'Follow three random movement prompts';
  @override
  String get langkahIntroLiveness3Deskripsi =>
      'The system will ask you to turn, nod, or look at center. Each prompt has a few-second limit.';
  @override
  String get langkahIntroLiveness4Judul =>
      'To prevent identity spoofing';
  @override
  String get langkahIntroLiveness4Deskripsi =>
      'The recording proves you are a real person, not a photo or screen replay. Not saved to your device gallery.';
  @override
  String get catatanIntroLiveness =>
      'This process is safe. Biometric data is processed in accordance with the BAKUDAPA MOBILE Privacy Policy and used only for account verification.';
  @override
  String get poinSidikJari1 =>
      'You can use fingerprint biometrics to strengthen the security of your BAKUDAPA MOBILE registration.';
  @override
  String get poinSidikJari2 =>
      'When using the device fingerprint sensor, the app only receives a success/failure status from the device system — raw fingerprint data never leaves the device.';
  @override
  String get poinSidikJari3 =>
      'If an official scanner device is available, the scan result is sent securely and encrypted to the backend to be reviewed by an authorized operator.';
  @override
  String get poinSidikJari4 =>
      'Biometric data is used only for account security verification and population administration services of Disdukcapil Maluku Utara.';
  @override
  String get poinSidikJari5 =>
      'You are fully responsible for the security of biometrics registered/stored on your device.';
  @override
  String get poinSidikJari6 =>
      'Contact Disdukcapil support service for more information or to deactivate biometrics.';
  @override
  String get persetujuanAktivasiBiometrik =>
      'I hereby consent to the activation and processing of fingerprint biometrics for BAKUDAPA MOBILE registration verification.';
  @override
  String get verifikasiWajahSelesai => 'Face verification complete';
  @override
  String get gerakanBenar => 'Correct gesture';
  @override
  String get arahBelumSesuai => 'Direction not matching';
  @override
  String cobaLagiPercobaan(int p, int maks) => 'Try again · $p/$maks';
  @override
  String get verifikasiBelumBerhasilLengkap =>
      'Some instructions were not completed within the attempt limit. Let\'s restart face verification.';
  @override
  String get persiapanKamera => 'Preparing camera…';
  @override
  String get aksesKameraDiperlukan => 'Camera access required';
  @override
  String get bukaPengaturanKamera =>
      'Enable camera permission from the app settings menu on your device.';
  @override
  String get buatKataSandiBaru => 'Create a new password';
  @override
  String get bersiapMengambilFoto => 'Getting ready to take the photo';
  @override
  String get instruksiUmumLiveness => 'Perform the gesture as instructed.';
  @override
  String get tahanStabil => 'Hold steady';
  @override
  String get jangkauanLayanan => 'Service coverage';
  @override
  String get gagalMemulaiPerekaman => 'Failed to start recording.';
  @override
  String get verifikasiBelumBerhasilJudul => 'Verification Not Yet Successful';
  @override
  String get verifikasiGagal => 'Verification Failed';
  @override
  String get verifikasiWajahBelumBerhasilPesan =>
      'Face verification was not successful. Make sure your face is clearly visible and follow the on-screen instructions.';
  @override
  String get gerakanTerdeteksiLanjut =>
      'Gesture detected. Moving to the next instruction.';
  @override
  String get lanjutkanKeVerifikasiSuara =>
      'Continue to voice verification to complete registration.';
  @override
  String sedangMerekamDetik(int detik) => 'Recording · ${detik}s';
  @override
  String get arahkanWajahDanIkutiInstruksi =>
      'Center your face and follow the on-screen instructions.';
  @override
  String get fotoIdentitas => 'Identity Photo';
  @override
  String get ambilFotoKtpEl => 'Take e-KTP photo';
  @override
  String get periksaHasilFotoKtpEl => 'Review e-KTP photo result';
  @override
  String get pastikanDokumenJelas =>
      'Make sure the document is clearly visible, not blurry, not cut off, and the entire identity card fits within the guide area.';
  @override
  String get tidakDapatBukaKamera => 'Unable to open camera.';
  @override
  String get gagalMengunggahFoto => 'Failed to upload photo.';
  @override
  String get bukaPanduan => 'Open Guide';
  @override
  String get fotoBelumVerifikasi => 'Photo not yet verified';
  @override
  String get butuhCobaSekaliLagi => 'Need to try once more';
  @override
  String get sistemBelumDapatMemverifikasi =>
      'The system could not verify your face photo yet. Follow this short guide, then try once more.';
  @override
  String get andaTelahMenggunakanKuota =>
      'You have used all your attempts. Please read the guide, then start again from the main page.';
  @override
  String get panduanTambahan => 'ADDITIONAL GUIDE';
  @override
  String get panduan1 =>
      'Find a room with natural light or evenly distributed lighting.';
  @override
  String get panduan2 =>
      'Position your face straight to the camera, not too close or far.';
  @override
  String get panduan3 =>
      'Hold the phone steady. Clean the camera lens if needed.';
  @override
  String get panduan4 =>
      'Remove masks, dark glasses, or other face coverings.';
  @override
  String get percobaanHabis => 'Attempts exhausted';
  @override
  String sisaPercobaanFormat(int sisa, int total) =>
      'Attempts left · $sisa/$total';
  @override
  String percobaanHabisFormat(int total) =>
      'Attempts exhausted · $total/$total';
  @override
  String get gunakanSidikJariMemperkuat =>
      'Use your fingerprint to strengthen BAKUDAPA MOBILE registration security.';
  @override
  String get memeriksaKetersediaan => 'Checking availability…';
  @override
  String get memeriksaKemampuanBiometrik =>
      "Checking your device's biometric capability.";
  @override
  String get tekanLaluTempelkanJari =>
      'Press the button below, then place your finger on the sensor.';
  @override
  String get dapatLewatiJikaTidakWajib =>
      'You can skip this step if it is not required.';
  @override
  String get ikutiInstruksiPerangkat =>
      'Follow the on-screen instructions on your device.';
  @override
  String get statusVerifikasiDikirim =>
      'The verification status will be sent to the Disdukcapil server.';
  @override
  String get cobaLagiAtauLewati => 'Please try again or skip this step.';
  @override
  String get dataSidikJariTidakKirim =>
      'Fingerprint data never leaves the device. Only the verification status is sent to the server.';
  @override
  String get pastikanSensorAktif =>
      "Make sure your device's fingerprint sensor is active and your finger is dry.";
  @override
  String get lewatiLangkahIni => 'Skip This Step';
  @override
  String get lanjutKeTinjauData => 'Continue to Review Data';
  @override
  String get perangkatTidakMendukungSidikJari =>
      'This device does not support fingerprint verification. You may still continue if this method is not required by the system.';
  @override
  String get belumAdaSidikJari =>
      'No fingerprint registered on this device. Please register one first in the device settings.';
  @override
  String get gagalKirimStatusSidikJari =>
      'Failed to send fingerprint verification status.';
  @override
  String get dilewatiPengguna => 'Skipped by user';
  @override
  String get izinMikrofonBelumDiberikan => 'Microphone permission not granted.';
  @override
  String get gagalMemulaiPerekamanSuara => 'Failed to start voice recording.';
  @override
  String get rekamanBelumTerdengarJelas =>
      'The recording was not clear enough. Please try again in a quieter place.';
  @override
  String get kodeVerifikasi => 'VERIFICATION CODE';
  @override
  String get rekamSuaraMinimal =>
      'Record at least 8 seconds. Do not cover the microphone with your hand.';
  @override
  String get tinjauDataPeriksa =>
      'Review carefully before proceeding to the policy agreement.';
  @override
  String get identitasDasar => 'Basic Identity';
  @override
  String get berkasVerifikasi => 'Verification Files';
  @override
  String get fotoIdentitasLabel => 'Identity photo';
  @override
  String get fotoWajahLabel => 'Face photo';
  @override
  String get videoLiveness => 'Liveness video';
  @override
  String get rekamanSuara => 'Voice recording';
  @override
  String get sidikJariLabel => 'Fingerprint';
  @override
  String instruksiTerverifikasi(int n) => '$n instructions verified';
  @override
  String get siap => 'Ready';
  @override
  String get belum => 'Pending';
  @override
  String get lanjutKePersetujuan => 'Continue to Agreement';
  @override
  String get statusSidikDiverifikasiPerangkat => 'Verified via this device';
  @override
  String get statusSidikDilewati => 'Skipped by user';
  @override
  String get statusSidikPerangkatTidakDukung => 'Device not supported';
  @override
  String get statusSidikBelumAdaDiPerangkat =>
      'No fingerprint on this device';
  @override
  String get statusSidikDibatalkan => 'Verification cancelled by user';
  @override
  String get statusSidikGagal => 'Verification failed';
  @override
  String get statusSidikBelumDiperiksa => 'Not yet verified';
  @override
  String get gagalMengirimRegistrasi =>
      'Failed to submit registration. Please try again.';
  @override
  String get bukaTautanBacaSetelah =>
      'Open the "Read" link to view the policy. The checkbox will be checked automatically after you accept.';
  @override
  String get kebijakanPrivasiDeskripsi =>
      'Collection, use, and protection of your personal data.';
  @override
  String get kebijakanLayananDeskripsi =>
      'Terms of use for the BAKUDAPA MOBILE service.';
  @override
  String get penafianSistemJudulLengkap =>
      'System Availability & Security Disclaimer';
  @override
  String get penafianSistemDeskripsi =>
      'Disclaimer of service availability and provider responsibility.';
  @override
  String get pemrosesanDataBiometrikDeskripsi =>
      'Consent to process face, liveness, voice, and fingerprint biometrics for verification.';
  @override
  String get pernyataanKebenaranDataDeskripsi =>
      'Declaration that the submitted data is correct and accountable.';
  @override
  String get bacaKebijakanPrivasi => 'Read Privacy Policy';
  @override
  String get bacaKebijakanLayanan => 'Read Service Policy';
  @override
  String get bacaPenafianSistem => 'Read System Disclaimer';
  @override
  String get bacaPersetujuanBiometrik => 'Read Biometric Consent';
  @override
  String get bacaPernyataanKebenaran => 'Read Truth Statement';
  @override
  String get pastikanDataDiperbarui =>
      'Make sure your data is updated through the Data Consolidation menu every 6 months.';
  @override
  String get layananCepat => 'Quick Services';
  @override
  String get lihatSemua => 'See all';
  @override
  String get pintasan => 'Shortcuts';
  @override
  String get panduanPengguna => 'User Guide';
  @override
  String get tutorialLangkah => 'Step-by-step tutorial';
  @override
  String get pusatBantuan => 'Help Center';
  @override
  String get hubungiKamiFaq => 'Contact us or FAQ';
  @override
  String get profil => 'Profile';
  @override
  String get tanpaNama => 'No Name';
  @override
  String get terverifikasi => 'Verified';
  @override
  String get akunDanKeamanan => 'Account & Security';
  @override
  String get dataPribadi => 'Personal Data';
  @override
  String get dataPribadiSub =>
      'View your NIK, email, and contact information.';
  @override
  String get keamananAkun => 'Account Security';
  @override
  String get keamananAkunSub => 'Change password, set up biometrics.';
  @override
  String get pemberitahuan => 'Notifications';
  @override
  String get pemberitahuanSub => 'System notification settings.';
  @override
  String get bantuanDanInformasi => 'Help & Information';
  @override
  String get tutorialMenggunakanApp => 'Tutorial for using the app.';
  @override
  String get hubungiKamiAtauFaq => 'Contact us or FAQ.';
  @override
  String get kebijakanPrivasiSub => 'How your data is protected.';
  @override
  String get kebijakanLayananSub => 'Terms of service usage.';
  @override
  String get penafianKetersediaanSistem => 'System Availability Disclaimer';
  @override
  String get pernyataanKetersediaan => 'Service availability statement.';
  @override
  String get keluarDariAplikasi => 'Sign Out of the App?';
  @override
  String get andaAkanKeluarSesi =>
      'You will sign out from your BAKUDAPA MOBILE session on this device. You will need to sign in again to access services.';
  @override
  String get andaTelahKeluar => 'You have signed out of the app.';
  @override
  String get versiAplikasi => 'Version 1.0.0';
  @override
  String get pengaturan => 'Settings';
  @override
  String get bahasa => 'Language';
  @override
  String get bahasaIndonesia => 'Bahasa Indonesia';
  @override
  String get englishLabel => 'English';
  @override
  String get tema => 'Theme';
  @override
  String get terang => 'Light';
  @override
  String get gelap => 'Dark';
  @override
  String get otomatis => 'Automatic';
  @override
  String get tentangAplikasi => 'About App';
  @override
  String get layanan => 'Services';
  @override
  String get semuaLayanan => 'All Services';
  @override
  String get cariLayanan => 'Search services…';
  @override
  String get tidakAdaLayanan => 'No services found.';
  @override
  String get bantuan => 'Help';
  @override
  String get faq => 'FAQ';
  @override
  String get hubungiKami => 'Contact Us';
  @override
  String get permohonan => 'Applications';
  @override
  String get riwayatPermohonan => 'Application History';
  @override
  String get pemberitahuanJudul => 'Notifications';
  @override
  String get tidakAdaPemberitahuan => 'No notifications yet.';
  @override
  String get tandaiSudahDibaca => 'Mark as read';
  @override
  String get panduanJudul => 'User Manual';
  @override
  String get onboardingJudul1 => 'Disdukcapil Services in Your Pocket';
  @override
  String get onboardingDesc1 =>
      'Access official population administration services of North Maluku Province from your phone.';
  @override
  String get onboardingJudul2 => 'Safe and Verified';
  @override
  String get onboardingDesc2 =>
      'Layered identity verification with biometrics to protect your account and data.';
  @override
  String get onboardingJudul3 => 'Track Status in Real-time';
  @override
  String get onboardingDesc3 =>
      'See the status of your document submissions directly without visiting the office.';
  @override
  String get mulaiSekarang => 'Start Now';
  @override
  String get sayaSudahMemilikiAkun => 'I Already Have an Account';
  @override
  String get tandaiSemuaSudahDibaca => 'Mark All as Read?';
  @override
  String get semuaPemberitahuanDitandai =>
      'All notifications will be marked as read.';
  @override
  String get tandaiSemua => 'Mark All';
  @override
  String get semuaPemberitahuanDitandaiDibaca =>
      'All notifications marked as read.';
  @override
  String get belumAdaPemberitahuan => 'No notifications yet';
  @override
  String get pembaruanStatusAkanMuncul =>
      'Updates on your application status will appear here.';
  @override
  String get hariIni => 'TODAY';
  @override
  String get kemarin => 'YESTERDAY';
  @override
  String get mingguIni => 'THIS WEEK';
  @override
  String get sebelumnya => 'EARLIER';
  @override
  String get pertanyaanUmum => 'Frequently Asked';
  @override
  String get hubungiKamiSub => 'The Disdukcapil team is ready to help.';
  @override
  String get bantuanLaporkanKendala => 'Report an issue or question.';
  @override
  String get bantuanPanggilCs => 'Call the Service Center';
  @override
  String get bantuanEmailKami => 'Email us';
  @override
  String get bantuanKantorPusat => 'Disdukcapil North Maluku Office';
  @override
  String get judulPanduan => 'User Guide';
  @override
  String get hapus => 'Delete';
  @override
  String get muat => 'Reload';
  @override
  String get gagalMemuat => 'Failed to load data.';
  @override
  String get tidakAdaPermohonan => 'No applications yet';
  @override
  String get permohonanAndaAkanMuncul =>
      'Service applications you submit will appear here.';
  @override
  String get statusPermohonan => 'Application Status';
  @override
  String get diterima => 'Accepted';
  @override
  String get ditolak => 'Rejected';
  @override
  String get diproses => 'Processing';
  @override
  String get menunggu => 'Pending';
  @override
  String get emailResmi => 'Official Email';
  @override
  String get telepon => 'Phone';
  @override
  String get situsWeb => 'Website';
  @override
  String get alamat => 'Address';
  @override
  String get pertanyaanUmumLengkap => 'Frequently Asked Questions (FAQ)';
  @override
  String get faq1Q => 'What is BAKUDAPA MOBILE?';
  @override
  String get faq1A =>
      "BAKUDAPA MOBILE is the official application of North Maluku Province's Disdukcapil for accessing population administration services online without visiting the office.";
  @override
  String get faq2Q => 'Is this application free?';
  @override
  String get faq2A =>
      'Yes. All official services are free of charge. Beware of parties requesting unofficial payments.';
  @override
  String get faq3Q => 'How long does an application take?';
  @override
  String get faq3A =>
      'Each service has a different SLA. The application status can be monitored directly in the History menu.';
  @override
  String get faq4Q => 'What if my application is rejected?';
  @override
  String get faq4A =>
      'Check the notes in the application detail. You can resubmit after completing or correcting the required data or documents.';
  @override
  String get faq5Q => 'How do I change personal data?';
  @override
  String get faq5A =>
      'Use the Data Consolidation menu to update. Some data can only be modified by Disdukcapil officers.';
  @override
  String get faq6Q => 'Is my data safe?';
  @override
  String get faq6A =>
      "Access tokens are encrypted in the device's Keystore/Keychain. Sensitive data is masked on display and not recorded in logs.";
  @override
  String get tabMemulai => 'Getting Started';
  @override
  String get tabLayanan => 'Services';
  @override
  String get tabKeamanan => 'Security Tips';
  @override
  String get dokumenDisiapkan => 'Documents to Prepare';
  @override
  String get opsional => 'optional';
  @override
  String get riwayat => 'History';
  @override
  String get cariKodeReferensi => 'Search reference code or service type';
  @override
  String get belumAdaPermohonan => 'No applications yet';
  @override
  String get riwayatPermohonanAnda =>
      'Your application history will appear here.';
  @override
  String get langkahPengajuan => 'Submission Steps';
  @override
  String get ajukanSekarang => 'Apply Now';
  @override
  String get isiFormulir => 'Fill Form';
  @override
  String get unggahDokumen => 'Upload Documents';
  @override
  String get kirimPermohonan => 'Submit Application';
  @override
  String get permohonanDikirim => 'Application submitted successfully.';
  @override
  String get gagalKirimPermohonan => 'Failed to submit application.';
  @override
  String get detailPermohonan => 'Application Detail';
  @override
  String get kodeReferensi => 'Reference Code';
  @override
  String get jenisLayanan => 'Service Type';
  @override
  String get diajukanPada => 'Submitted On';
  @override
  String get diperbaruiPada => 'Updated On';
  @override
  String get catatan => 'Notes';
  @override
  String get dokumen => 'Documents';
  @override
  String get unduhDokumenHasil => 'Download Result Document';
  @override
  String get selamatPagi => 'Good morning';
  @override
  String get selamatSiang => 'Good afternoon';
  @override
  String get selamatSore => 'Good evening';
  @override
  String get selamatMalam => 'Good night';
  @override
  String get wargaMalukuUtara => 'North Maluku Citizen';
  @override
  String get berjalan => 'In Progress';
  @override
  String get statusSelesai => 'Completed';
  @override
  String wajibDiisi(String label) => '$label is required.';
  @override
  String minimalKarakter(String label, int n) =>
      '$label must be at least $n characters.';
  @override
  String get kolomIniLabel => 'This field';
  @override
  String get nikHarus16Digit => 'NIK must be 16 digits.';
  @override
  String get nikHanyaAngka => 'NIK must contain digits only.';
  @override
  String get noKkLabel => 'Family Card Number';
  @override
  String get noKkHarus16Digit => 'Family Card Number must be 16 digits.';
  @override
  String get noKkHanyaAngka =>
      'Family Card Number must contain digits only.';
  @override
  String get formatEmailTidakValid => 'Invalid email format.';
  @override
  String get noHpTidakValid => 'Invalid phone number.';
  @override
  String get hapusAngka0DiAwal => 'Remove the leading zero.';
  @override
  String get noHpHarus9Digit => 'Phone number must be 9–13 digits.';
  @override
  String get kataSandiMin8 => 'At least 8 characters.';
  @override
  String get sertakanHurufBesar => 'Include at least 1 uppercase letter.';
  @override
  String get sertakanAngka => 'Include at least 1 digit.';
  @override
  String get konfirmasiKataSandiLabel => 'Password confirmation';
  @override
  String get kataSandiTidakCocok => 'Passwords do not match.';
  @override
  String get nikAtauEmailLabel => 'NIK or email';
  @override
  String get identitasTidakValid => 'Invalid identity.';
  @override
  String get nikLabel => 'NIK';
  @override
  String get nomorHpLabel => 'Phone Number';
  @override
  String get emailLabel => 'Email';
  @override
  String get jaringanTidakAdaJudul => 'No Internet Connection';
  @override
  String get jaringanTidakAdaPesan =>
      'Your device is not connected to the internet. Please check your network and try again.';
  @override
  String get jaringanTidakStabilJudul => 'Unstable Network';
  @override
  String get jaringanTidakStabilPesan =>
      'Your internet connection is currently unstable. To protect your data and prevent failed submissions, this process cannot continue. Please move to an area with a stronger connection or use a more stable network.';
  @override
  String get jaringanServerTakTerjangkauJudul => 'Server Unreachable';
  @override
  String get jaringanServerTakTerjangkauPesan =>
      'The Disdukcapil server is currently unreachable. Please check your connection or try again in a moment.';
  @override
  String get jaringanLambatUntukUploadJudul => 'Connection Not Sufficient';
  @override
  String get jaringanLambatUntukUploadPesan =>
      'Your current network speed risks failing the biometric upload. Please switch to a more stable network before continuing.';
  @override
  String get memeriksaJaringan => 'Checking network…';
  @override
  String get periksaUlang => 'Check Again';
  @override
  String get jaringanStabil => 'Network stable';
  @override
  String get jaringanSedang => 'Network moderate';
  @override
  String get jaringanLambat => 'Network slow';
  @override
  String get jaringanOffline => 'No connection';
  @override
  String get maintenanceJudul => 'System Under Maintenance';
  @override
  String get maintenancePesanSingkat =>
      'BAKUDAPA MOBILE is currently undergoing maintenance to improve service quality and security. During maintenance, login, registration, and service activities are temporarily unavailable. Please try again later.';
  @override
  String get maintenancePesanLengkap =>
      'We are performing system maintenance to improve the security, stability, and quality of BAKUDAPA MOBILE service. While in progress, login, registration, and service activities are temporarily unavailable.';
  @override
  String get maintenanceHalamanJudul => 'System Under Maintenance';
  @override
  String get maintenanceHalamanPesan =>
      'The service is under maintenance to safeguard security and system quality. Please try again once maintenance is complete.';
  @override
  String estimasiSelesai(String tanggal) => 'Estimated completion: $tanggal';
  @override
  String kontakLayanan(String kontak) => 'Support contact: $kontak';
  @override
  String get keluarAplikasiLabel => 'Exit App';
  @override
  String get bahasaApaYangInginDigunakan =>
      'Which language would you like to use?';
  @override
  String get bahasaIndonesiaLabel => 'Indonesian';
  @override
  String get englishUkLabel => 'English (UK)';
  @override
  String get gunakanBahasaIndonesia => 'Use Indonesian';
  @override
  String get useEnglish => 'Use English';
  @override
  String get bahasaBerhasilDiubah => 'Language changed successfully.';
  @override
  String get asistenAi => 'AI Assistant';
  @override
  String get sapaanAi =>
      'Ask anything about Disdukcapil North Maluku services. I am ready to explain steps and requirements.';
  @override
  String get ketikPertanyaan => 'Type your question…';
  @override
  String get lanjutkanAi => 'Continue';
  @override
  String get mulaiSesiBaru => 'Start new session';
  @override
  String get menyimpanIdentitas =>
      'Saving your identity data. Please do not close the app.';
  @override
  String get mengirimRegistrasi =>
      'Submitting your registration to Disdukcapil. Please do not close the app.';
  @override
  String get mengunggahBerkas => 'Uploading file to the secure server.';
  @override
  String get memprosesPermintaan => 'Processing your request.';
  @override
  String get mengunggahFotoDokumen =>
      'Uploading your identity photo. Please do not close the app.';
  @override
  String get mengunggahFotoWajah =>
      'Uploading your face photo. Please do not close the app.';
  @override
  String get mengunggahLiveness =>
      'Uploading face verification data. Please do not close the app.';
  @override
  String get mengunggahSuara =>
      'Uploading your voice recording. Please do not close the app.';
  @override
  String get mengirimSidikJari => 'Submitting your fingerprint verification.';
  @override
  String get memverifikasiAkun => 'Verifying your account.';
  @override
  String get memverifikasiKode => 'Verifying your OTP code.';
  @override
  String get tabBeranda => 'Home';
  @override
  String get tabPermohonan => 'Requests';
  @override
  String get tabAsisten => 'Assistant';
  @override
  String get tabNotifikasi => 'Alerts';
  @override
  String get tabProfil => 'Profile';
  @override
  String get instansiSingkat => 'Disdukcapil North Maluku';
  @override
  String get akunTerverifikasi => 'Verified';
  @override
  String get akunBelumTerverifikasi => 'Not Verified';
  @override
  String get buatPermohonan => 'New Request';
  @override
  String get permohonanAktif => 'Active Requests';
  @override
  String get bakudapaAi => 'BAKUDAPA AI';
  @override
  String get asistenAjakan => 'Ask about services & request status';
  @override
  String get mulaiPercakapan => 'Start a conversation';
  @override
  String get tanpaPermohonanAktif => 'No active requests';
  @override
  String ringkasanPermohonanAktif(int n) => '$n request(s) in progress';
  @override
  String get disclaimerAi =>
      'Assistant info is guidance only, not an official Disdukcapil decision.';
  @override
  String get cobaTanya => 'Try asking';
  @override
  String get saranStatusPermohonan => 'What is my request status?';
  @override
  String get saranSyaratKk => 'What are the requirements for a Family Card?';
  @override
  String get saranApaItuKia => 'What is a KIA?';
  @override
  String get saranPindahDomisili => 'How do I change my domicile?';
  @override
  String get asistenMengetik => 'Assistant is typing…';
  @override
  String get menyiapkanKamera => 'Preparing camera…';
  @override
  String get izinKamera => 'Camera access';
  @override
  String get izinKameraArahan =>
      'Enable camera access to continue face verification.';
  @override
  String get cahayaKurang => 'Low light';
  @override
  String get cahayaKurangArahan =>
      'Lighting is too low. Move to a brighter area or face a light source.';
  @override
  String get posisikanWajah => 'Position Your Face';
  @override
  String get ambilFoto => 'Take Photo';
  @override
  String get memproses => 'Processing…';
  @override
  String get arahanPosisikanWajah =>
      'Position your face inside the circle so the system can verify it.';
  @override
  String get arahanTerlaluJauh =>
      'Move your face a little closer until it fills the guide area.';
  @override
  String get arahanTerlaluDekat =>
      'Move your face a little farther so your whole face is clearly visible.';
  @override
  String get arahanSatuWajah => 'Make sure only one face is inside the frame.';
  @override
  String get siapVerifikasiWajah => 'Ready for face verification';
  @override
  String get tersedia => 'Available';
  @override
  String get tersediaOnline => 'Online';
  @override
  String get layananLoket => 'Counter';
  @override
  String get layananBelumOnlinePesan =>
      'This service cannot be submitted online yet. Please visit the nearest Disdukcapil counter.';
  @override
  String get perluVerifikasiPesan =>
      'Verify your account first to submit an application.';
  @override
  String get kataSandiBaru => 'New Password';
  @override
  String get konfirmasiKataSandiBaru => 'Confirm New Password';
  @override
  String get buatKataSandiBaruJudul => 'Create New Password';
  @override
  String get buatKataSandiBaruSub =>
      'Enter your new password. Must be at least 8 characters with an uppercase letter and a digit.';
  @override
  String get kataSandiBerhasilDiubah => 'Password changed successfully.';
  @override
  String get simpanKataSandiBaru => 'Save New Password';
  @override
  String get tantanganSuaraKosongJudul => 'Verification sentence not available';
  @override
  String get tantanganSuaraKosongPesan =>
      'Voice challenge sentences have not been set up by the operator yet. Please contact Disdukcapil Provinsi Maluku Utara to continue registration.';
  @override
  String get tantanganSuaraGagalMuat =>
      'Failed to load verification sentence. Please try again.';
  @override
  String get tantanganSuaraBelumDimuat =>
      'Sentence not loaded yet. Please wait or try again.';
  @override
  String get rekamanBelumCocokKalimat =>
      'Your recording does not appear to match the sentence above. Please repeat and speak the full sentence.';
  @override
  String get hubungiDisdukcapilCta => 'Contact Disdukcapil';
}
