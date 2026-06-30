import 'package:dio/dio.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../../../shared/models/perangkat_aktif.dart';
import '../domain/repositori_perangkat.dart';

class RepositoriPerangkatApi implements RepositoriPerangkat {
  RepositoriPerangkatApi({Dio? dio})
    : _dio = dio ?? KlienJaringan.instance.dio;

  final Dio _dio;

  @override
  Future<List<PerangkatAktif>> mintaDaftar() async {
    try {
      final res = await _dio.get(Endpoints.authPerangkat);
      return _bacaDaftar(res.data);
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<List<PerangkatAktif>> mintaRiwayat() async {
    try {
      final res = await _dio.get(Endpoints.authPerangkatRiwayat);
      return _bacaDaftar(res.data, kunciUtama: 'riwayat');
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<void> cabut(String sesiId) async {
    try {
      await _dio.delete(Endpoints.authCabutPerangkat(sesiId));
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  List<PerangkatAktif> _bacaDaftar(dynamic body, {String? kunciUtama}) {
    final daftar = _ekstrakList(body, kunciUtama: kunciUtama);
    return daftar
        .whereType<Map>()
        .map((e) => PerangkatAktif.dariJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List _ekstrakList(dynamic body, {String? kunciUtama}) {
    if (body is List) return body;
    if (body is Map) {
      final kunciCari = [
        ?kunciUtama,
        'perangkat',
        'sesi',
        'devices',
        'data',
        'items',
        'list',
      ];
      for (final kunci in kunciCari) {
        final nilai = body[kunci];
        if (nilai is List) return nilai;
      }
    }
    return const [];
  }
}
