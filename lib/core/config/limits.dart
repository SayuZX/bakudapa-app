class UploadLimits {
  UploadLimits._();

  static const int fotoDokumenMaxByte = 5 * 1024 * 1024;
  static const int fotoWajahMaxByte = 3 * 1024 * 1024;
  static const int videoLivenessMaxByte = 15 * 1024 * 1024;
  static const int audioSuaraMaxByte = 5 * 1024 * 1024;
  static const int dokumenPermohonanMaxByte = 10 * 1024 * 1024;

  static const List<String> fotoMimeTypes = ['image/jpeg', 'image/jpg', 'image/png'];
  static const List<String> videoMimeTypes = ['video/mp4', 'video/quicktime', 'video/webm'];
  static const List<String> audioMimeTypes = [
    'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/x-wav', 'audio/webm', 'audio/ogg'
  ];
  static const List<String> dokumenMimeTypes = [
    'application/pdf', 'image/jpeg', 'image/png'
  ];

  static int maxByteFor(String jenis) => switch (jenis) {
        'foto_dokumen' => fotoDokumenMaxByte,
        'foto_wajah' => fotoWajahMaxByte,
        'video_liveness' => videoLivenessMaxByte,
        'audio_suara' => audioSuaraMaxByte,
        'dokumen_permohonan' => dokumenPermohonanMaxByte,
        _ => 5 * 1024 * 1024,
      };
}

class PasswordRules {
  PasswordRules._();

  static const int minLength = 8;
  static const int maxLength = 64;
  static const String uppercasePattern = r'[A-Z]';
  static const String digitPattern = r'\d';
  static const String hint = 'Min 8 karakter, ada huruf besar dan angka';
}

class OtpRules {
  OtpRules._();

  static const int length = 6;
  static const Duration kedaluwarsa = Duration(minutes: 5);
  static const Duration resendCooldown = Duration(seconds: 60);
  static const int maxResendPerHour = 10;
}

class FotoWajahRules {
  FotoWajahRules._();

  static const int maxPercobaan = 3;
}

class LoginRules {
  LoginRules._();

  static const int maxPercobaan = 5;
  static const Duration lockoutDuration = Duration(minutes: 30);
}

class RateLimits {
  RateLimits._();

  static const int aiFaqPerJam = 30;
  static const int otpSendPerJam = 10;
  static const int registrasiMulaiPerJam = 20;
}
