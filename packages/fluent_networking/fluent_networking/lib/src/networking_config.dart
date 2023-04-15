import 'package:fluent_networking/fluent_networking.dart';

class NetworkingConfig {
  NetworkingConfig({
    this.baseUrl = '',
    this.interceptors = const [],
  });

  final String baseUrl;
  final List<RestApiInterceptor> interceptors;
}
