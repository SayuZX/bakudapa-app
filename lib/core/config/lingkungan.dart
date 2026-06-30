class KonfigurasiLingkungan {
  const KonfigurasiLingkungan._();

  static const String _appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: '');
  static const String _hostOverride =
      String.fromEnvironment('BAKUDAPA_HOST', defaultValue: '');

  static const String _hostLokal = 'http://10.0.2.2:3000/api';
  static const String _hostProduksi = 'https://bakudapa.malutprov.go.id/api';

  static const bool _isDevLokal = _appEnv == 'dev_lokal';
  static const bool _adaOverride = _hostOverride != '';

  static const String baseUrl = _adaOverride
      ? _hostOverride
      : (_isDevLokal ? _hostLokal : _hostProduksi);

  static const bool isDevLokal = _isDevLokal;

  static const bool pinningAktif = !_isDevLokal && !_adaOverride;
}
