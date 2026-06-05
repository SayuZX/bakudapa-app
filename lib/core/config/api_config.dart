class ApiConfig {
  ApiConfig._();

  static const String baseUrlProd = 'https://bakudapa.malutprov.go.id/api';

  static const String baseUrl = String.fromEnvironment(
    'BAKUDAPA_BASE_URL',
    defaultValue: baseUrlProd,
  );

  static const String apiVersion = '1';
  static const String defaultLocale = 'id';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 120);

  static const Duration tokenAksesTtl = Duration(hours: 1);
  static const Duration tokenRefreshTtl = Duration(days: 30);

  static Map<String, String> get defaultHeaders => {
        'Accept': 'application/json',
        'Accept-Version': apiVersion,
        'Accept-Language': defaultLocale,
      };
}
