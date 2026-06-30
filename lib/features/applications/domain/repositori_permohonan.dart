import 'dart:io';

import '../../../shared/models/halaman_data.dart';
import '../../../shared/models/permohonan.dart';

class RingkasanStatus {
  const RingkasanStatus({
    required this.menunggu,
    required this.berjalan,
    required this.selesai,
    required this.perluTindakan,
  });

  final int menunggu;
  final int berjalan;
  final int selesai;
  final int perluTindakan;

  int get total => menunggu + berjalan + selesai + perluTindakan;
}

class HasilAjukan {
  const HasilAjukan({
    required this.id,
    required this.nomorPermohonan,
    required this.slugLayanan,
  });

  final String id;
  final String nomorPermohonan;
  final String slugLayanan;
}

class DokumenHasil {
  const DokumenHasil({
    required this.id,
    required this.nama,
    this.jenis,
    this.namaBerkas,
    this.mimeType,
    this.dibuatPada,
  });

  final String id;
  final String nama;
  final String? jenis;
  final String? namaBerkas;
  final String? mimeType;
  final DateTime? dibuatPada;

  factory DokumenHasil.dariJson(Map<String, dynamic> json) {
    String teks(List<String> kunci) {
      for (final k in kunci) {
        final nilai = json[k];
        if (nilai != null && nilai.toString().trim().isNotEmpty) {
          return nilai.toString().trim();
        }
      }
      return '';
    }

    final namaBerkas = teks(const ['nama_berkas', 'file_name', 'berkas']);
    final nama = teks(const ['nama', 'judul', 'label', 'title']);
    return DokumenHasil(
      id: teks(const ['id', 'dokumen_id', 'document_id']),
      nama: nama.isNotEmpty ? nama : (namaBerkas.isNotEmpty ? namaBerkas : 'Dokumen Hasil'),
      jenis: teks(const ['jenis', 'type', 'kategori']).isEmpty
          ? null
          : teks(const ['jenis', 'type', 'kategori']),
      namaBerkas: namaBerkas.isEmpty ? null : namaBerkas,
      mimeType: teks(const ['mime_type', 'mime', 'tipe_konten']).isEmpty
          ? null
          : teks(const ['mime_type', 'mime', 'tipe_konten']),
      dibuatPada: DateTime.tryParse(
        teks(const ['dibuat_pada', 'created_at', 'diterbitkan_pada']),
      )?.toLocal(),
    );
  }
}

abstract class RepositoriPermohonan {
  Future<HalamanData<Permohonan>> mintaDaftar({
    int halaman = 1,
    int ukuran = 15,
    String? status,
    String? cari,
  });

  Future<List<Permohonan>> mintaGabunganTerbaru({int ukuran = 20});

  Future<Permohonan> mintaDetail(String id);

  Future<HasilAjukan> ajukan({
    required String kodeLayanan,
    required Map<String, String> dataFormulir,
    required Map<String, File> berkas,
    Map<String, bool> wajibBerkas = const <String, bool>{},
    Map<String, String> labelBerkas = const <String, String>{},
  });

  Future<void> batalkan(String id);

  Future<void> lampirkanDokumen({
    required String id,
    required File berkas,
    required String jenis,
    bool wajib = false,
  });

  Future<List<DokumenHasil>> mintaDokumenHasil(String id);

  Future<String> unduhDokumenHasil(String id, DokumenHasil dokumen);
}
