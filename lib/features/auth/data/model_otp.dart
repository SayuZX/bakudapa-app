import '../../../shared/models/pengguna.dart';

enum TipeOtp {
  login('login'),
  registrasi('registrasi'),
  resetKataSandi('reset_kata_sandi'),
  verifikasiUlang('verifikasi_ulang'),
  ubahKontak('ubah_kontak');

  const TipeOtp(this.kode);
  final String kode;
}

enum KanalOtp {
  sms('sms'),
  email('email');

  const KanalOtp(this.kode);
  final String kode;
}

sealed class HasilVerifikasiOtp {
  const HasilVerifikasiOtp();

  factory HasilVerifikasiOtp.dariJson(TipeOtp tipe, Map<String, dynamic> json) {
    switch (tipe) {
      case TipeOtp.login:
        return HasilVerifikasiOtpLogin.dariJson(json);
      case TipeOtp.resetKataSandi:
        return HasilVerifikasiOtpReset.dariJson(json);
      case TipeOtp.registrasi:
      case TipeOtp.verifikasiUlang:
      case TipeOtp.ubahKontak:
        return HasilVerifikasiOtpUmum.dariJson(json, tipe);
    }
  }
}

class HasilVerifikasiOtpLogin extends HasilVerifikasiOtp {
  const HasilVerifikasiOtpLogin({
    required this.tokenAkses,
    required this.tokenSegar,
    required this.kedaluwarsaPada,
    required this.pengguna,
    this.wajibGantiKataSandi = false,
  });

  final String tokenAkses;
  final String tokenSegar;
  final DateTime kedaluwarsaPada;
  final Pengguna pengguna;
  final bool wajibGantiKataSandi;

  factory HasilVerifikasiOtpLogin.dariJson(Map<String, dynamic> json) {
    return HasilVerifikasiOtpLogin(
      tokenAkses: json['token_akses']?.toString() ?? '',
      tokenSegar: json['token_refresh']?.toString() ??
          json['token_segar']?.toString() ??
          '',
      kedaluwarsaPada:
          DateTime.tryParse(json['kedaluwarsa_pada']?.toString() ?? '') ??
              DateTime.now().add(const Duration(hours: 1)),
      pengguna: Pengguna.dariJson(
          json['pengguna'] as Map<String, dynamic>? ?? const {}),
      wajibGantiKataSandi: json['wajib_ganti_kata_sandi'] == true,
    );
  }
}

class HasilVerifikasiOtpReset extends HasilVerifikasiOtp {
  const HasilVerifikasiOtpReset({required this.tokenReset});
  final String tokenReset;

  factory HasilVerifikasiOtpReset.dariJson(Map<String, dynamic> json) {
    return HasilVerifikasiOtpReset(
      tokenReset: json['token_reset']?.toString() ??
          json['reset_token']?.toString() ??
          '',
    );
  }
}

class HasilVerifikasiOtpUmum extends HasilVerifikasiOtp {
  const HasilVerifikasiOtpUmum({
    required this.diverifikasi,
    required this.tipe,
  });
  final bool diverifikasi;
  final TipeOtp tipe;

  factory HasilVerifikasiOtpUmum.dariJson(
      Map<String, dynamic> json, TipeOtp tipe) {
    return HasilVerifikasiOtpUmum(
      diverifikasi: json['diverifikasi'] == true,
      tipe: tipe,
    );
  }
}

class HasilKirimUlangOtp {
  const HasilKirimUlangOtp({
    required this.dikirim,
    required this.kanal,
    required this.tujuanSamar,
  });

  final bool dikirim;
  final String kanal;
  final String tujuanSamar;

  factory HasilKirimUlangOtp.dariJson(Map<String, dynamic> json) {
    return HasilKirimUlangOtp(
      dikirim: json['dikirim'] == true,
      kanal: json['kanal']?.toString() ?? 'sms',
      tujuanSamar: json['tujuan_samar']?.toString() ?? '',
    );
  }
}
