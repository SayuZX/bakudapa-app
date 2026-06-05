import 'package:dio/dio.dart';

import '../errors/kesalahan.dart';
import '../system/layanan_status_sistem.dart';

class PencegatMaintenance extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (response.statusCode == 503 || _berkodeMaintenance(data)) {
      final judul = _ambilJudul(data);
      final pesan = _ambilPesan(data);
      LayananStatusSistem.instance.tandaiAktifDariResponseGalat(
        judul: judul,
        pesan: pesan,
      );
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: KesalahanMaintenance(
            pesan: pesan ?? 'Layanan sedang dalam pemeliharaan.',
            judul: judul,
          ),
        ),
      );
      return;
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null &&
        (response.statusCode == 503 || _berkodeMaintenance(response.data))) {
      final judul = _ambilJudul(response.data);
      final pesan = _ambilPesan(response.data);
      LayananStatusSistem.instance.tandaiAktifDariResponseGalat(
        judul: judul,
        pesan: pesan,
      );
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: response,
          type: err.type,
          error: KesalahanMaintenance(
            pesan: pesan ?? 'Layanan sedang dalam pemeliharaan.',
            judul: judul,
          ),
        ),
      );
      return;
    }
    handler.next(err);
  }

  bool _berkodeMaintenance(dynamic data) {
    if (data is! Map) return false;
    final error = data['error'];
    if (error is Map && error['code'] == 'MAINTENANCE_MODE') return true;
    if (data['code'] == 'MAINTENANCE_MODE') return true;
    return false;
  }

  String? _ambilJudul(dynamic data) {
    if (data is! Map) return null;
    final error = data['error'];
    if (error is Map && error['title'] is String) {
      return error['title'] as String;
    }
    if (data['title'] is String) return data['title'] as String;
    return null;
  }

  String? _ambilPesan(dynamic data) {
    if (data is! Map) return null;
    final error = data['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    if (data['message'] is String) return data['message'] as String;
    return null;
  }
}
