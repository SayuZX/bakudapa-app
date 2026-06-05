import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Pencatat {
  Pencatat._()
      : _logger = Logger(
          filter: _FilterProduksi(),
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 3,
            lineLength: 80,
            colors: true,
            printEmojis: false,
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
        );

  static final Pencatat instance = Pencatat._();
  final Logger _logger;

  static const Set<String> _kunciSensitif = {
    'password',
    'kataSandi',
    'token',
    'tokenAkses',
    'tokenSegar',
    'nik',
    'noKk',
    'no_kk',
    'phone',
    'noHp',
    'email',
    'otp',
    'pin',
  };

  Map<String, dynamic> _saring(Map<String, dynamic> data) {
    return data.map((k, v) {
      if (_kunciSensitif.contains(k)) return MapEntry(k, '***');
      if (v is Map<String, dynamic>) return MapEntry(k, _saring(v));
      return MapEntry(k, v);
    });
  }

  void d(String pesan, [Map<String, dynamic>? data]) {
    if (!kDebugMode) return;
    _logger.d(data == null ? pesan : '$pesan ${_saring(data)}');
  }

  void i(String pesan, [Map<String, dynamic>? data]) {
    if (!kDebugMode) return;
    _logger.i(data == null ? pesan : '$pesan ${_saring(data)}');
  }

  void w(String pesan, [Map<String, dynamic>? data]) {
    _logger.w(data == null ? pesan : '$pesan ${_saring(data)}');
  }

  void e(String pesan, {Object? error, StackTrace? stackTrace}) {
    _logger.e(pesan, error: error, stackTrace: stackTrace);
  }
}

class _FilterProduksi extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    return true;
  }
}
