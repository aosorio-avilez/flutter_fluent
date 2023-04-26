import 'package:dio/dio.dart';

/// Definition of a networking interceptor
class NetworkingInterceptor extends InterceptorsWrapper {
  NetworkingInterceptor({
    super.onRequest,
    super.onResponse,
    super.onError,
  });
}
