import 'package:bakudapa_mobile/core/services/layanan_tautan_dalam.dart';
import 'package:bakudapa_mobile/core/system/model_status_maintenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatusMaintenance.dariJson', () {
    test('alias bahasa Indonesia (sedang_maintenance/pesan/perkiraan_selesai)', () {
      final s = StatusMaintenance.dariJson({
        'sedang_maintenance': true,
        'judul': 'Sedang Pemeliharaan',
        'pesan': 'Mohon tunggu',
        'perkiraan_selesai': '2026-06-24T10:00:00Z',
        'kontak_dukungan': '0800-1',
        'fitur_diizinkan': ['login'],
      });

      expect(s.aktif, isTrue);
      expect(s.judul, 'Sedang Pemeliharaan');
      expect(s.pesan, 'Mohon tunggu');
      expect(s.estimasiSelesai?.toUtc().hour, 10);
      expect(s.kontakDukungan, '0800-1');
      expect(s.fiturDiizinkan, contains('login'));
    });

    test('alias bahasa Inggris (maintenance/message/estimated_until)', () {
      final s = StatusMaintenance.dariJson({
        'maintenance': true,
        'title': 'Under Maintenance',
        'message': 'Please wait',
        'estimated_until': '2026-06-24T12:00:00Z',
      });
      expect(s.aktif, isTrue);
      expect(s.judul, 'Under Maintenance');
      expect(s.estimasiSelesai?.toUtc().hour, 12);
    });

    test('tidak aktif saat flag false / kosong', () {
      expect(StatusMaintenance.dariJson({'sedang_maintenance': false}).aktif, isFalse);
      expect(StatusMaintenance.dariJson({}).aktif, isFalse);
    });

    test('estimasi null → tetap null', () {
      final s = StatusMaintenance.dariJson({'sedang_maintenance': true});
      expect(s.estimasiSelesai, isNull);
    });
  });

  group('LayananTautanDalam.tokenResetDari', () {
    test('universal link https valid', () {
      final t = LayananTautanDalam.tokenResetDari(
        Uri.parse(
          'https://bakudapa.malutprov.go.id/reset-password?token=ABC123',
        ),
      );
      expect(t, 'ABC123');
    });

    test('custom scheme valid', () {
      final t = LayananTautanDalam.tokenResetDari(
        Uri.parse('bakudapa://reset-password?token=XYZ'),
      );
      expect(t, 'XYZ');
    });

    test('host lain ditolak', () {
      final t = LayananTautanDalam.tokenResetDari(
        Uri.parse('https://contoh.com/reset-password?token=ABC'),
      );
      expect(t, isNull);
    });

    test('path lain ditolak', () {
      final t = LayananTautanDalam.tokenResetDari(
        Uri.parse('https://bakudapa.malutprov.go.id/beranda?token=ABC'),
      );
      expect(t, isNull);
    });

    test('token kosong ditolak', () {
      final t = LayananTautanDalam.tokenResetDari(
        Uri.parse('https://bakudapa.malutprov.go.id/reset-password'),
      );
      expect(t, isNull);
    });
  });
}
