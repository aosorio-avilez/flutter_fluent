import 'package:fluent_networking/fluent_networking.dart';

/// Definition of the networking configuration
class NetworkingConfig {
  NetworkingConfig({
    this.baseUrl = '',
    this.interceptors = const [],
  });

  /// Base url to make the http request
  final String baseUrl;

  /// Interceptor to add additional validation before/after each request
  final List<NetworkingInterceptor> interceptors;
}
