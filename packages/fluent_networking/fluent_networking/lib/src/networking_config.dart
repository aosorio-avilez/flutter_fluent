import 'package:fluent_networking/fluent_networking.dart';

/// Definition of the networking configuration
class NetworkingConfig {
  const NetworkingConfig({
    this.baseUrl = '',
    this.interceptors = const [],
    this.enableLog = false,
    this.enableCurlLog = false,
    this.sensitiveHeaders = const {},
    this.sensitiveBodyKeys = const {},
    this.sensitiveQueryParams = const {},
    this.retryConfig,
  });

  /// Base url to make the http request
  final String baseUrl;

  /// Interceptor to add additional validation before/after each request
  final List<NetworkingInterceptor> interceptors;

  /// Enable log to show the request and response
  final bool enableLog;

  /// Enable curl log to show outgoing requests as curl commands
  final bool enableCurlLog;

  /// Custom headers to redact in logs
  final Set<String> sensitiveHeaders;

  /// Keys in the JSON body to redact in logs
  final Set<String> sensitiveBodyKeys;

  /// Query parameters to redact in logs
  final Set<String> sensitiveQueryParams;

  /// Global retry configuration
  final RetryConfig? retryConfig;
}
