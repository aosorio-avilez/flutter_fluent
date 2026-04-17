import 'package:fluent_networking/fluent_networking.dart';

/// Definition of the networking configuration
class NetworkingConfig {
  const NetworkingConfig({
    this.baseUrl = '',
    this.interceptors = const [],
    this.enableLog = false,
    this.retryConfig,
    this.sensitiveHeaders = const {},
    this.sensitiveBodyKeys = const {},
  });

  /// Base url to make the http request
  final String baseUrl;

  /// Interceptor to add additional validation before/after each request
  final List<NetworkingInterceptor> interceptors;

  /// Enable log to show the request and response
  final bool enableLog;

  /// Global retry configuration
  final RetryConfig? retryConfig;

  /// Additional headers to redact in the logs
  final Set<String> sensitiveHeaders;

  /// Body keys to redact in the logs
  final Set<String> sensitiveBodyKeys;
}
