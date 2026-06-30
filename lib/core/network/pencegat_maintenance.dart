import 'package:dio/dio.dart';

import '../config/endpoints.dart';
import '../errors/kesalahan.dart';
import '../system/layanan_status_sistem.dart';

class PencegatMaintenance extends Interceptor {
  static const Set<String> _kodeMaintenance = {
    'SEDANG_MAINTENANCE',
    'MAINTENANCE_MODE',
  };

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_dikecualikan(response.requestOptions) &&
        _berkodeMaintenance(response.statusCode, response.data)) {
      _tandai(response.data);
      handler.reject(_galat(response.requestOptions, response, response.data));
      return;
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (!_dikecualikan(err.requestOptions) &&
        _berkodeMaintenance(response?.statusCode, response?.data)) {
      _tandai(response?.data);
      handler.reject(_galat(err.requestOptions, response, response?.data, err));
      return;
    }
    handler.next(err);
  }

  bool _dikecualikan(RequestOptions opsi) {
    final path = opsi.path;
    return path.contains(Endpoints.sistemMaintenance) ||
        path.contains(Endpoints.sistemPing);
  }

  bool _berkodeMaintenance(int? status, dynamic data) {
    if (status == 503) return true;
    if (data is! Map) return false;
    final error = data['error'];
    if (error is Map) {
      if (_kodeMaintenance.contains(error['code'])) return true;
      final details = error['details'];
      if (details is Map &&
          _kodeMaintenance.contains(details['maintenance_code'])) {
        return true;
      }
    }
    if (_kodeMaintenance.contains(data['code'])) return true;
    if (_kodeMaintenance.contains(data['error_code'])) return true;
    return false;
  }

  void _tandai(dynamic data) {
    LayananStatusSistem.instance.tandaiAktifDariResponseGalat(
      judul: _ambilJudul(data),
      pesan: _ambilPesan(data),
      estimasiSelesai: _ambilEstimasi(data),
    );
  }

  DioException _galat(
    RequestOptions opsi,
    Response? response,
    dynamic data, [
    DioException? asli,
  ]) {
    return DioException(
      requestOptions: opsi,
      response: response,
      type: asli?.type ?? DioExceptionType.badResponse,
      error: KesalahanMaintenance(
        pesan: _ambilPesan(data) ?? 'Layanan sedang dalam pemeliharaan.',
        judul: _ambilJudul(data),
      ),
    );
  }

  String? _ambilJudul(dynamic data) => _teks(data, 'title');

  String? _ambilPesan(dynamic data) => _teks(data, 'message');

  String? _teks(dynamic data, String kunci) {
    if (data is! Map) return null;
    final error = data['error'];
    if (error is Map && error[kunci] is String) return error[kunci] as String;
    if (data[kunci] is String) return data[kunci] as String;
    return null;
  }

  DateTime? _ambilEstimasi(dynamic data) {
    if (data is! Map) return null;
    final kandidat = <dynamic>[];
    final error = data['error'];
    if (error is Map) {
      final details = error['details'];
      if (details is Map) {
        kandidat
          ..add(details['perkiraan_selesai'])
          ..add(details['estimated_until']);
      }
    }
    kandidat
      ..add(data['perkiraan_selesai'])
      ..add(data['estimated_until']);
    for (final v in kandidat) {
      if (v is String && v.isNotEmpty) {
        final t = DateTime.tryParse(v);
        if (t != null) return t;
      }
    }
    return null;
  }
}
