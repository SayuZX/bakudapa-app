import 'package:dio/dio.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../../../shared/models/wilayah.dart';

abstract class RepositoriWilayah {
  Future<List<Wilayah>> kabupaten();
  Future<List<Wilayah>> kecamatan(String kabupatenKode);
  Future<List<Wilayah>> desa(String kecamatanKode);
}

class RepositoriWilayahApi implements RepositoriWilayah {
  RepositoriWilayahApi({Dio? dio}) : _dio = dio ?? KlienJaringan.instance.dio;

  final Dio _dio;

  final Options _opsiAnonim = Options(extra: const {'anonim': true});

  @override
  Future<List<Wilayah>> kabupaten() => _ambil(Endpoints.wilayahKabupaten, [
    'kabupaten',
  ]);

  @override
  Future<List<Wilayah>> kecamatan(String kabupatenKode) => _ambil(
    Endpoints.wilayahKecamatan,
    ['kecamatan'],
    query: {'kabupaten': kabupatenKode},
  );

  @override
  Future<List<Wilayah>> desa(String kecamatanKode) => _ambil(
    Endpoints.wilayahDesa,
    ['desa'],
    query: {'kecamatan': kecamatanKode},
  );

  Future<List<Wilayah>> _ambil(
    String path,
    List<String> kunci, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.get(
        path,
        queryParameters: query,
        options: _opsiAnonim,
      );
      return _baca(res.data, kunci);
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  List<Wilayah> _baca(dynamic body, List<String> kunci) {
    final daftar = _ekstrak(body, kunci);
    return daftar
        .whereType<Map>()
        .map((e) => Wilayah.dariJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List _ekstrak(dynamic body, List<String> kunci) {
    if (body is List) return body;
    if (body is Map) {
      for (final k in [...kunci, 'data', 'items', 'list']) {
        final nilai = body[k];
        if (nilai is List) return nilai;
      }
    }
    return const [];
  }
}
