import 'package:bakudapa_mobile/core/errors/error_codes.dart';
import 'package:bakudapa_mobile/shared/models/perangkat_aktif.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PerangkatAktif.dariJson', () {
    test('membaca kontrak backend Indonesia', () {
      final p = PerangkatAktif.dariJson({
        'sesi_id': 'abc123',
        'perangkat': 'Samsung Galaxy S23',
        'os': 'Android 14',
        'terakhir_aktif_pada': '2026-06-23T08:00:00Z',
        'perangkat_saat_ini': true,
      });

      expect(p.sesiId, 'abc123');
      expect(p.perangkat, 'Samsung Galaxy S23');
      expect(p.os, 'Android 14');
      expect(p.iniPerangkatSaatIni, isTrue);
      expect(p.terakhirAktif?.toUtc().hour, 8);
    });

    test('membaca alias bahasa Inggris', () {
      final p = PerangkatAktif.dariJson({
        'session_id': 'xyz',
        'device': 'iPhone 15',
        'device_os': 'iOS 18',
        'last_active_at': '2026-06-20T10:30:00Z',
        'is_current': false,
      });

      expect(p.sesiId, 'xyz');
      expect(p.perangkat, 'iPhone 15');
      expect(p.os, 'iOS 18');
      expect(p.iniPerangkatSaatIni, isFalse);
    });

    test('toleran terhadap data kosong', () {
      final p = PerangkatAktif.dariJson({});
      expect(p.sesiId, '');
      expect(p.terakhirAktif, isNull);
      expect(p.iniPerangkatSaatIni, isFalse);
    });
  });

  group('PerangkatAktif riwayat', () {
    test('membaca kontrak riwayat dengan status + masuk_pada', () {
      final p = PerangkatAktif.dariJson({
        'id_sesi': 's1',
        'model': 'Redmi Note 13',
        'os': 'Android 14',
        'app_version': '5.0.0',
        'masuk_pada': '2026-06-22T07:00:00Z',
        'terakhir_aktif': '2026-06-23T09:00:00Z',
        'status': 'dicabut',
        'ini_perangkat_ini': false,
      });

      expect(p.sesiId, 's1');
      expect(p.perangkat, 'Redmi Note 13');
      expect(p.appVersion, '5.0.0');
      expect(p.status, StatusPerangkat.dicabut);
      expect(p.masukPada?.toUtc().day, 22);
    });

    test('status enum memetakan alias EN dan nilai tak dikenal', () {
      expect(StatusPerangkat.dari('active'), StatusPerangkat.aktif);
      expect(StatusPerangkat.dari('expired'), StatusPerangkat.kedaluwarsa);
      expect(StatusPerangkat.dari('revoked'), StatusPerangkat.dicabut);
      expect(StatusPerangkat.dari('???'), StatusPerangkat.takDikenal);
    });
  });

  group('KelolaPerangkat.dariJson', () {
    test('parsing payload BATAS_PERANGKAT_TERCAPAI', () {
      final k = KelolaPerangkat.dariJson({
        'diperlukan': true,
        'batas': 2,
        'perangkat_aktif': [
          {'id_sesi': 'a', 'model': 'Pixel 8', 'os': 'Android 15'},
          {'session_id': 'b', 'device': 'iPad', 'device_os': 'iPadOS 18'},
        ],
      });

      expect(k.diperlukan, isTrue);
      expect(k.batas, 2);
      expect(k.perangkatAktif, hasLength(2));
      expect(k.perangkatAktif.first.perangkat, 'Pixel 8');
      expect(k.perangkatAktif.last.sesiId, 'b');
    });

    test('daftar kosong saat field tidak ada', () {
      final k = KelolaPerangkat.dariJson({'required': false});
      expect(k.diperlukan, isFalse);
      expect(k.perangkatAktif, isEmpty);
    });
  });

  test('ErrorCodes batas perangkat masuk set autoLogout sesi dicabut', () {
    expect(ErrorCodes.batasPerangkatTercapai, 'BATAS_PERANGKAT_TERCAPAI');
    expect(ErrorCodes.autoLogout, contains(ErrorCodes.sessionRevoked));
    expect(ErrorCodes.autoLogout, contains(ErrorCodes.invalidRefreshToken));
  });
}
