import 'package:bakudapa_mobile/features/registration/data/model/data_registrasi.dart';
import 'package:bakudapa_mobile/shared/models/pengguna.dart';
import 'package:bakudapa_mobile/shared/models/wilayah.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wilayah.dariJson', () {
    test('membaca kode/nama bahasa Indonesia', () {
      final w = Wilayah.dariJson({'kode': '8271', 'nama': 'Kota Ternate'});
      expect(w.kode, '8271');
      expect(w.nama, 'Kota Ternate');
    });

    test('membaca alias EN code/name', () {
      final w = Wilayah.dariJson({'code': '01', 'name': 'Ternate Tengah'});
      expect(w.kode, '01');
      expect(w.nama, 'Ternate Tengah');
    });

    test('equality berdasar kode+nama', () {
      const a = Wilayah(kode: '1', nama: 'A');
      const b = Wilayah(kode: '1', nama: 'A');
      expect(a, b);
    });
  });

  group('Pengguna.wilayah + domisili', () {
    test('parsing wilayah objek bertingkat {kode,nama}', () {
      final p = Pengguna.dariJson({
        'id': '1',
        'nik': '8271015005900002',
        'nama_lengkap': 'Budi',
        'username': 'budi.w',
        'wilayah': {
          'kabupaten': {'kode': '8271', 'nama': 'Kota Ternate'},
          'kecamatan': {'kode': '8271010', 'nama': 'Ternate Tengah'},
          'desa': {'kode': '8271010001', 'nama': 'Gamalama'},
        },
      });

      expect(p.username, 'budi.w');
      expect(p.kabupatenKota, 'Kota Ternate');
      expect(p.kecamatan, 'Ternate Tengah');
      expect(p.desaKelurahan, 'Gamalama');
      expect(p.desaKode, '8271010001');
      expect(p.domisili, 'Gamalama · Ternate Tengah · Kota Ternate');
    });

    test('parsing wilayah flat {kabupaten_nama, desa_kode}', () {
      final p = Pengguna.dariJson({
        'id': '2',
        'nik': '1',
        'nama_lengkap': 'Ani',
        'wilayah': {
          'kabupaten_nama': 'Kab A',
          'desa_nama': 'Desa B',
          'desa_kode': 'X1',
        },
      });
      expect(p.kabupatenKota, 'Kab A');
      expect(p.desaKelurahan, 'Desa B');
      expect(p.desaKode, 'X1');
    });

    test('domisili null saat tidak ada wilayah', () {
      final p = Pengguna.dariJson({'id': '3', 'nik': '1', 'nama_lengkap': 'C'});
      expect(p.domisili, isNull);
    });
  });

  group('IdentitasRegistrasi.toJson', () {
    test('mengirim kabupaten_kode/kecamatan_kode/desa_kode (kode bukan nama)', () {
      const identitas = IdentitasRegistrasi(
        nomorIdentitas: '8271015005900002',
        namaLengkap: 'Budi',
        tempatLahir: 'Ternate',
        noHp: '+628123456789',
        surel: 'budi@mail.com',
        kabupatenKode: '8271',
        kabupatenNama: 'Kota Ternate',
        kecamatanKode: '8271010',
        kecamatanNama: 'Ternate Tengah',
        desaKode: '8271010001',
        desaNama: 'Gamalama',
      );

      final json = identitas.toJson();
      expect(json['kabupaten_kode'], '8271');
      expect(json['kecamatan_kode'], '8271010');
      expect(json['desa_kode'], '8271010001');
      expect(json.containsKey('kabupaten_nama'), isFalse);
      expect(json.containsKey('kecamatan_nama'), isFalse);
    });
  });
}
