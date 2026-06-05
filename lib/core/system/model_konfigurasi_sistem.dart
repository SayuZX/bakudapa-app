class KonfigurasiSistem {
  const KonfigurasiSistem({
    required this.versiApi,
    required this.versiMinimumApp,
    required this.batasUnggahanByte,
    required this.otp,
    required this.login,
    required this.fotoWajah,
    required this.token,
    required this.bahasaDidukung,
  });

  final String versiApi;
  final String versiMinimumApp;
  final Map<String, int> batasUnggahanByte;
  final KonfigurasiOtp otp;
  final KonfigurasiLogin login;
  final KonfigurasiFotoWajah fotoWajah;
  final KonfigurasiToken token;
  final List<String> bahasaDidukung;

  factory KonfigurasiSistem.dariJson(Map<String, dynamic> json) {
    final batas = json['batas_unggahan_byte'];
    return KonfigurasiSistem(
      versiApi: json['versi_api'] as String? ?? '0.1.0',
      versiMinimumApp: json['versi_minimum_app'] as String? ?? '1.0.0',
      batasUnggahanByte: batas is Map
          ? batas.map((k, v) => MapEntry(k.toString(), (v as num).toInt()))
          : const {},
      otp: KonfigurasiOtp.dariJson(json['otp']),
      login: KonfigurasiLogin.dariJson(json['login']),
      fotoWajah: KonfigurasiFotoWajah.dariJson(json['foto_wajah']),
      token: KonfigurasiToken.dariJson(json['token']),
      bahasaDidukung: json['bahasa_didukung'] is List
          ? List<String>.from(json['bahasa_didukung'] as List)
          : const ['id', 'en'],
    );
  }

  int batasUntuk(String jenis, {int bawaan = 5 * 1024 * 1024}) {
    return batasUnggahanByte[jenis] ?? bawaan;
  }

  static const bawaan = KonfigurasiSistem(
    versiApi: '1',
    versiMinimumApp: '1.0.0',
    batasUnggahanByte: {
      'foto_dokumen': 5242880,
      'foto_wajah': 3145728,
      'video_liveness': 15728640,
      'audio_suara': 5242880,
      'dokumen_permohonan': 10485760,
    },
    otp: KonfigurasiOtp(panjang: 6, kedaluwarsaDetik: 300, cooldownDetik: 60),
    login: KonfigurasiLogin(maksPercobaan: 5, durasiKunciDetik: 1800),
    fotoWajah: KonfigurasiFotoWajah(maksPercobaan: 3),
    token: KonfigurasiToken(aksesTtlDetik: 3600, refreshTtlDetik: 2592000),
    bahasaDidukung: ['id', 'en'],
  );
}

class KonfigurasiOtp {
  const KonfigurasiOtp({
    required this.panjang,
    required this.kedaluwarsaDetik,
    required this.cooldownDetik,
  });

  final int panjang;
  final int kedaluwarsaDetik;
  final int cooldownDetik;

  factory KonfigurasiOtp.dariJson(dynamic json) {
    if (json is! Map) {
      return const KonfigurasiOtp(
          panjang: 6, kedaluwarsaDetik: 300, cooldownDetik: 60);
    }
    return KonfigurasiOtp(
      panjang: (json['panjang'] as num?)?.toInt() ?? 6,
      kedaluwarsaDetik: (json['kedaluwarsa_detik'] as num?)?.toInt() ?? 300,
      cooldownDetik: (json['cooldown_detik'] as num?)?.toInt() ?? 60,
    );
  }
}

class KonfigurasiLogin {
  const KonfigurasiLogin({
    required this.maksPercobaan,
    required this.durasiKunciDetik,
  });

  final int maksPercobaan;
  final int durasiKunciDetik;

  factory KonfigurasiLogin.dariJson(dynamic json) {
    if (json is! Map) {
      return const KonfigurasiLogin(maksPercobaan: 5, durasiKunciDetik: 1800);
    }
    return KonfigurasiLogin(
      maksPercobaan: (json['maks_percobaan'] as num?)?.toInt() ?? 5,
      durasiKunciDetik: (json['durasi_kunci_detik'] as num?)?.toInt() ?? 1800,
    );
  }
}

class KonfigurasiFotoWajah {
  const KonfigurasiFotoWajah({required this.maksPercobaan});
  final int maksPercobaan;

  factory KonfigurasiFotoWajah.dariJson(dynamic json) {
    if (json is! Map) return const KonfigurasiFotoWajah(maksPercobaan: 3);
    return KonfigurasiFotoWajah(
      maksPercobaan: (json['maks_percobaan'] as num?)?.toInt() ?? 3,
    );
  }
}

class KonfigurasiToken {
  const KonfigurasiToken({
    required this.aksesTtlDetik,
    required this.refreshTtlDetik,
  });

  final int aksesTtlDetik;
  final int refreshTtlDetik;

  factory KonfigurasiToken.dariJson(dynamic json) {
    if (json is! Map) {
      return const KonfigurasiToken(
          aksesTtlDetik: 3600, refreshTtlDetik: 2592000);
    }
    return KonfigurasiToken(
      aksesTtlDetik: (json['akses_ttl_detik'] as num?)?.toInt() ?? 3600,
      refreshTtlDetik: (json['refresh_ttl_detik'] as num?)?.toInt() ?? 2592000,
    );
  }
}
