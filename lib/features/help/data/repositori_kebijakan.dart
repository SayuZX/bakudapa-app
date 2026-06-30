import 'package:dio/dio.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/enums/jenis_kebijakan.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';

export '../../../core/enums/jenis_kebijakan.dart';

class Pasal {
  const Pasal(this.judul, this.isi);
  final String judul;
  final String isi;
}

class KontenKebijakan {
  const KontenKebijakan({
    required this.judul,
    required this.pasal,
    this.versi,
    this.berlakuSejak,
    this.kontak,
  });

  final String judul;
  final List<Pasal> pasal;
  final String? versi;
  final String? berlakuSejak;
  final String? kontak;

  factory KontenKebijakan.dariJson(
    Map<String, dynamic> json, {
    required String judulBawaan,
  }) {
    final judul = _teks(json, const ['judul', 'title', 'nama']);
    return KontenKebijakan(
      judul: judul.isEmpty ? judulBawaan : judul,
      versi: _teksOpsional(json, const ['versi', 'version']),
      berlakuSejak: _teksOpsional(
        json,
        const ['tanggal_berlaku', 'berlaku_sejak', 'effective_date', 'terakhir_diperbarui', 'updated_at'],
      ),
      kontak: _teksOpsional(json, const ['kontak', 'contact', 'narahubung']),
      pasal: _parsePasal(json),
    );
  }

  static List<Pasal> _parsePasal(Map<String, dynamic> json) {
    final mentah = json['pasal'] ??
        json['konten'] ??
        json['sections'] ??
        json['isi'] ??
        json['content'] ??
        json['body'];
    if (mentah is List) {
      final hasil = <Pasal>[];
      for (final item in mentah) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final judul = _teks(map, const ['judul', 'title', 'heading', 'nama']);
          final isi = _teks(map, const ['isi', 'teks', 'content', 'body', 'deskripsi']);
          if (isi.isNotEmpty || judul.isNotEmpty) {
            hasil.add(Pasal(judul, isi));
          }
        } else if (item != null && item.toString().trim().isNotEmpty) {
          hasil.add(Pasal('', item.toString().trim()));
        }
      }
      return hasil;
    }
    if (mentah is String && mentah.trim().isNotEmpty) {
      return [Pasal('', mentah.trim())];
    }
    return const [];
  }

  static String _teks(Map<String, dynamic> json, List<String> kunci) {
    for (final k in kunci) {
      final nilai = json[k];
      if (nilai != null && nilai.toString().trim().isNotEmpty) {
        return nilai.toString().trim();
      }
    }
    return '';
  }

  static String? _teksOpsional(Map<String, dynamic> json, List<String> kunci) {
    final hasil = _teks(json, kunci);
    return hasil.isEmpty ? null : hasil;
  }
}

abstract class RepositoriKebijakan {
  Future<KontenKebijakan> ambil(JenisKebijakan jenis);
}

class RepositoriKebijakanApi implements RepositoriKebijakan {
  RepositoriKebijakanApi({Dio? dio}) : _dio = dio ?? KlienJaringan.instance.dio;
  final Dio _dio;

  @override
  Future<KontenKebijakan> ambil(JenisKebijakan jenis) async {
    try {
      final res = await _dio.get(
        Endpoints.kebijakanDetail(jenis.pathSegment),
        options: Options(extra: const {'anonim': true}),
      );
      final data = res.data is Map
          ? Map<String, dynamic>.from(res.data)
          : <String, dynamic>{};
      return KontenKebijakan.dariJson(data, judulBawaan: jenis.labelId);
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }
}
