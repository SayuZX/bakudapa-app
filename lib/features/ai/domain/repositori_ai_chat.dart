import 'package:dio/dio.dart';

import '../../../core/ai/model_ai_chat.dart';

abstract class RepositoriAiChat {
  Future<HasilBalasanAi> tanya({
    required String pesan,
    String? sesiId,
    Map<String, dynamic>? konteks,
    bool lanjutkan = false,
    CancelToken? batal,
  });
}
