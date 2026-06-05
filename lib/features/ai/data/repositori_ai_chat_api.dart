import 'package:dio/dio.dart';

import '../../../core/ai/model_ai_chat.dart';
import '../../../core/config/endpoints.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../domain/repositori_ai_chat.dart';

class RepositoriAiChatApi implements RepositoriAiChat {
  RepositoriAiChatApi({Dio? dio}) : _dio = dio ?? KlienJaringan.instance.dio;

  final Dio _dio;

  @override
  Future<HasilBalasanAi> tanya({
    required String pesan,
    String? sesiId,
    Map<String, dynamic>? konteks,
    bool lanjutkan = false,
  }) async {
    try {
      final res = await _dio.post(
        Endpoints.aiTanya,
        data: {
          'pesan': pesan,
          if (sesiId != null && sesiId.isNotEmpty) 'sesi_id': sesiId,
          if (konteks != null && konteks.isNotEmpty) 'konteks': konteks,
          if (lanjutkan) 'lanjutkan': true,
        },
        options: Options(receiveTimeout: const Duration(seconds: 90)),
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const KesalahanAi('Respons AI tidak valid.');
      }
      return HasilBalasanAi.dariJson(data);
    } on Kesalahan {
      rethrow;
    } on DioException catch (e) {
      if (e.error is Kesalahan) throw e.error! as Kesalahan;
      throw const KesalahanAi();
    } catch (_) {
      throw const KesalahanAi();
    }
  }
}
