class ErrorCodes {
  ErrorCodes._();

  static const String validation = 'VALIDATION_ERROR';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String accountBlocked = 'ACCOUNT_BLOCKED';
  static const String notFound = 'NOT_FOUND';
  static const String conflict = 'CONFLICT';
  static const String rateLimited = 'RATE_LIMITED';
  static const String maintenanceMode = 'MAINTENANCE_MODE';
  static const String aiUnavailable = 'AI_UNAVAILABLE';
  static const String aiError = 'AI_ERROR';
  static const String visionError = 'VISION_ERROR';
  static const String faceServiceError = 'FACE_SERVICE_ERROR';
  static const String facePhotoBlocked = 'FACE_PHOTO_BLOCKED';
  static const String resourceEmpty = 'RESOURCE_EMPTY';

  static const Set<String> autoLogout = {unauthorized};
  static const Set<String> showRetry = {aiError, visionError, faceServiceError};
  static const Set<String> blockingDialog = {maintenanceMode, accountBlocked, facePhotoBlocked};
}
