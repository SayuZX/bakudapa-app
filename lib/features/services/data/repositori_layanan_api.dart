import 'package:dio/dio.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../domain/detail_layanan.dart';
import '../domain/repositori_layanan.dart';

class RepositoriLayananApi implements RepositoriLayanan {
  RepositoriLayananApi({Dio? dio}) : _dio = dio ?? KlienJaringan.instance.dio;

  final Dio _dio;

  @override
  Future<List<RingkasanLayanan>> mintaDaftar({
    String? cari,
    String? kategori,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.layanan,
        queryParameters: {
          if (cari != null && cari.isNotEmpty) 'cari': cari,
          if (kategori != null && kategori.isNotEmpty) 'kategori': kategori,
        },
      );
      return _bacaDaftar(res.data)
          .map(RingkasanLayanan.dariJson)
          .where((e) => e.kode.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _kesalahan(e);
    }
  }

  @override
  Future<DetailLayanan> mintaDetail(String kodeLayanan) async {
    try {
      final res = await _dio.get(Endpoints.layananDetail(kodeLayanan));
      return DetailLayanan.dariJson(_bacaObjek(res.data), kode: kodeLayanan);
    } on DioException catch (e) {
      throw _kesalahan(e);
    }
  }

  Kesalahan _kesalahan(DioException e) =>
      e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();

  List<Map<String, dynamic>> _bacaDaftar(dynamic body) {
    dynamic isi = body;
    if (isi is Map) {
      isi = isi['layanan'] ??
          isi['data'] ??
          isi['items'] ??
          isi['list'] ??
          isi.values.firstWhere((v) => v is List, orElse: () => null);
    }
    if (isi is List) {
      return isi
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Map<String, dynamic> _bacaObjek(dynamic body) {
    if (body is Map) {
      final inner = body['layanan'] ?? body['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return Map<String, dynamic>.from(body);
    }
    return const {};
  }
}
