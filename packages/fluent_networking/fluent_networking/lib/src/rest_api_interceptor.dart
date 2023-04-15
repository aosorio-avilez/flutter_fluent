import 'package:dio/dio.dart';

class RestApiInterceptor extends InterceptorsWrapper {
  RestApiInterceptor({
    super.onRequest,
    super.onResponse,
    super.onError,
  });
}
