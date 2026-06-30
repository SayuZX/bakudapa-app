import 'package:dio/dio.dart';

import '../config/endpoints.dart';
import '../errors/kesalahan.dart';
import '../network/klien_jaringan.dart';
import 'model_verifikasi_wajah_ai.dart';

class LayananVerifikasiWajahAi {
  LayananVerifikasiWajahAi._();
  static final LayananVerifikasiWajahAi instance = LayananVerifikasiWajahAi._();

  Future<HasilVerifikasiWajahAi> verifikasi({
    required String kunciFotoDokumen,
    required String kunciFotoWajah,
  }) async {
    try {
      final r = await KlienJaringan.instance.dio.post(
        Endpoints.biometrikVerifikasiWajah,
        data: {
          'foto_dokumen_kunci': kunciFotoDokumen,
          'foto_wajah_kunci': kunciFotoWajah,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      final data = r.data;
      if (data is! Map<String, dynamic>) {
        throw const KesalahanLayananWajah(
          'Respons verifikasi wajah tidak valid.',
        );
      }
      return HasilVerifikasiWajahAi.dariJson(data);
    } on DioException catch (e) {
      if (e.error is Kesalahan) rethrow;
      throw const KesalahanLayananWajah();
    }
  }
}
