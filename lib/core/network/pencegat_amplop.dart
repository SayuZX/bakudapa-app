import 'package:dio/dio.dart';

class PencegatAmplop extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map && body['success'] == true && body.containsKey('data')) {
      response.data = body['data'];
      if (body['meta'] != null) {
        response.extra['meta'] = body['meta'];
      }
    }
    handler.next(response);
  }
}
