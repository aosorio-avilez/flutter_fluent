import 'package:fluent_networking/fluent_networking.dart';

abstract class RestConfig {
  RestConfig({
    this.baseUrl = '',
    this.interceptors = const [],
  });

  final String baseUrl;
  final List<RestApiInterceptor> interceptors;
}
