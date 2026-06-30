class ErrorCodes {
  ErrorCodes._();

  static const String validation = 'VALIDATION_ERROR';
  static const String validationFailed = 'VALIDATION_FAILED';
  static const String badRequest = 'BAD_REQUEST';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String accountBlocked = 'ACCOUNT_BLOCKED';
  static const String notFound = 'NOT_FOUND';
  static const String conflict = 'CONFLICT';
  static const String duplicateRecord = 'DUPLICATE_RECORD';
  static const String payloadTooLarge = 'PAYLOAD_TOO_LARGE';
  static const String rateLimited = 'RATE_LIMITED';
  static const String internalServerError = 'INTERNAL_SERVER_ERROR';
  static const String serviceUnavailable = 'SERVICE_UNAVAILABLE';
  static const String maintenanceMode = 'MAINTENANCE_MODE';
  static const String aiUnavailable = 'AI_UNAVAILABLE';
  static const String aiError = 'AI_ERROR';
  static const String visionError = 'VISION_ERROR';
  static const String faceServiceError = 'FACE_SERVICE_ERROR';
  static const String facePhotoBlocked = 'FACE_PHOTO_BLOCKED';
  static const String resourceEmpty = 'RESOURCE_EMPTY';
  static const String batasPerangkatTercapai = 'BATAS_PERANGKAT_TERCAPAI';
  static const String sessionRevoked = 'SESSION_REVOKED';
  static const String invalidRefreshToken = 'INVALID_REFRESH_TOKEN';
  static const String sesiTidakValid = 'SESI_TIDAK_VALID';
  static const String sesiSudahTidakAktif = 'SESI_SUDAH_TIDAK_AKTIF';
  static const String storageNotConfigured = 'STORAGE_NOT_CONFIGURED';
  static const String storageError = 'STORAGE_ERROR';

  static const Set<String> autoLogout = {
    unauthorized,
    sessionRevoked,
    invalidRefreshToken,
  };
  static const Set<String> showRetry = {aiError, visionError, faceServiceError};
  static const Set<String> blockingDialog = {maintenanceMode, accountBlocked, facePhotoBlocked};
}
