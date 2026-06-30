import 'package:dio/dio.dart';

import '../utils/waktu_server.dart';

class PencegatAmplop extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map && body['success'] == true && body.containsKey('data')) {
      response.data = body['data'];
      final meta = body['meta'];
      if (meta != null) {
        response.extra['meta'] = meta;
        if (meta is Map) {
          final serverTime = meta['server_time'];
          if (serverTime is String && serverTime.isNotEmpty) {
            final waktu = DateTime.tryParse(serverTime);
            if (waktu != null) WaktuServer.perbarui(waktu.toUtc());
          }
        }
      }
    }
    handler.next(response);
  }
}
