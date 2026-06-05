import 'dart:async';
import 'dart:math' as math;

class BantuanCobaUlang {
  const BantuanCobaUlang._();

  static Future<T> jalankan<T>({
    required Future<T> Function() aksi,
    int maksPercobaan = 3,
    Duration jedaAwal = const Duration(milliseconds: 600),
    bool Function(Object galat)? bolehCobaUlang,
  }) async {
    var percobaan = 0;
    Object? galatTerakhir;
    while (percobaan < maksPercobaan) {
      try {
        return await aksi();
      } catch (e) {
        galatTerakhir = e;
        percobaan++;
        final bolehLanjut = bolehCobaUlang == null || bolehCobaUlang(e);
        if (!bolehLanjut || percobaan >= maksPercobaan) {
          rethrow;
        }
        final tunggu = Duration(
          milliseconds: (jedaAwal.inMilliseconds *
                  math.pow(2, percobaan - 1).toInt())
              .clamp(jedaAwal.inMilliseconds, 8000),
        );
        await Future<void>.delayed(tunggu);
      }
    }
    throw galatTerakhir ?? StateError('Coba ulang gagal tanpa galat.');
  }
}
