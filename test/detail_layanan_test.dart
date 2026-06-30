import 'package:bakudapa_mobile/features/services/domain/definisi_formulir.dart';
import 'package:bakudapa_mobile/features/services/domain/detail_layanan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DetailLayanan.dariJson membaca kontrak backend nyata', () {
    final json = <String, dynamic>{
      'kode': 'birth-cert',
      'nama': 'Akta Kelahiran',
      'deskripsi': 'Pencatatan kelahiran.',
      'kategori': 'Akta Kelahiran',
      'langkah_panduan': ['Isi data', 'Unggah dokumen'],
      'berkas_disiapkan': ['Surat Keterangan Lahir', 'Kartu Keluarga'],
      'formulir_definisi': {
        'fields': [
          {'key': 'nama_anak', 'label': 'Nama Anak', 'type': 'string', 'required': true, 'max_length': 100},
          {
            'key': 'jenis_kelamin',
            'label': 'Jenis Kelamin',
            'type': 'enum',
            'required': true,
            'options': [
              {'value': 'L', 'label': 'Laki-laki'},
              {'value': 'P', 'label': 'Perempuan'},
            ],
          },
          {'key': 'tanggal_lahir', 'label': 'Tanggal Lahir', 'type': 'date', 'required': true},
        ],
      },
      'dokumen_definisi': [
        {'jenis': 'surat_keterangan_lahir', 'label': 'Surat Keterangan Lahir', 'wajib': true},
        {'jenis': 'kartu_keluarga', 'label': 'Kartu Keluarga', 'wajib': true},
      ],
    };

    final d = DetailLayanan.dariJson(json, kode: 'birth-cert');

    expect(d.kode, 'birth-cert');
    expect(d.dariServer, isTrue);

    final ruas = d.formulir.expand((g) => g.ruas).toList();
    expect(ruas.length, 3);
    expect(ruas.first.kunci, 'nama_anak');
    expect(ruas.first.panjangMaks, 100);

    final jk = ruas.firstWhere((r) => r.kunci == 'jenis_kelamin');
    expect(jk.tipe, TipeRuas.pilihan);
    expect(jk.pilihan.length, 2);
    expect(jk.pilihan.first.nilai, 'L');

    expect(ruas.firstWhere((r) => r.kunci == 'tanggal_lahir').tipe, TipeRuas.tanggal);

    expect(d.persyaratan.length, 2);
    expect(d.persyaratan.first.teks, 'Surat Keterangan Lahir');

    expect(d.dokumen.length, 2);
    expect(d.dokumen.first.kunci, 'surat_keterangan_lahir');
    expect(d.dokumen.first.wajib, isTrue);
  });

  test('DetailLayanan.dariJson membaca min_length & batasan dokumen nyata', () {
    final json = <String, dynamic>{
      'kode': 'birth-cert',
      'nama': 'Akta Kelahiran',
      'formulir_definisi': {
        'fields': [
          {
            'key': 'no_kk',
            'type': 'string',
            'label': 'Nomor Kartu Keluarga',
            'required': true,
            'max_length': 16,
            'min_length': 16,
          },
          {'key': 'surel', 'type': 'email', 'label': 'Surel', 'required': false},
        ],
      },
      'dokumen_definisi': [
        {
          'jenis': 'kartu_keluarga',
          'label': 'Kartu Keluarga',
          'wajib': true,
          'mime_types': ['application/pdf', 'image/jpeg', 'image/png'],
          'max_size_byte': 5242880,
        },
      ],
    };

    final d = DetailLayanan.dariJson(json, kode: 'birth-cert');
    final ruas = d.formulir.expand((g) => g.ruas).toList();

    final noKk = ruas.firstWhere((r) => r.kunci == 'no_kk');
    expect(noKk.panjangMin, 16);
    expect(noKk.panjangMaks, 16);
    expect(noKk.nomorIdentitas16, isTrue);
    expect(noKk.adalahNoKk, isTrue);

    expect(ruas.firstWhere((r) => r.kunci == 'surel').tipe, TipeRuas.email);

    final dok = d.dokumen.single;
    expect(dok.kunci, 'kartu_keluarga');
    expect(dok.maksByte, 5242880);
    expect(dok.mimeTypes, contains('image/jpeg'));
  });

  test('DetailLayanan.dariJson aman untuk definisi kosong', () {
    final d = DetailLayanan.dariJson(
      {'kode': 'x', 'nama': 'X', 'formulir_definisi': {}, 'dokumen_definisi': [], 'berkas_disiapkan': []},
      kode: 'x',
    );
    expect(d.formulir, isEmpty);
    expect(d.dokumen, isEmpty);
    expect(d.persyaratan, isEmpty);
  });
}
