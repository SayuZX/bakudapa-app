import 'package:dio/dio.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';

abstract class RepositoriProfil {
  Future<void> gantiBahasa(String bahasa);
  Future<Map<String, int>> ringkasanStatus();
}

class RepositoriProfilApi implements RepositoriProfil {
  RepositoriProfilApi({Dio? dio}) : _dio = dio ?? KlienJaringan.instance.dio;
  final Dio _dio;

  @override
  Future<void> gantiBahasa(String bahasa) async {
    try {
      await _dio.put(Endpoints.profilBahasa, data: {'bahasa': bahasa});
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<Map<String, int>> ringkasanStatus() async {
    try {
      final res = await _dio.get(Endpoints.profilRingkasanStatus);
      final data = res.data is Map ? Map<String, dynamic>.from(res.data) : {};
      int ambil(String kunci) {
        final v = data[kunci];
        if (v is int) return v;
        return int.tryParse('$v') ?? 0;
      }

      return {
        'menunggu': ambil('menunggu'),
        'diproses': ambil('diproses'),
        'selesai': ambil('selesai'),
      };
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }
}
