import 'package:dio/dio.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';

/// Interceptor that retries a failed request based on the [RetryConfig].
class NetworkingRetryInterceptor extends Interceptor {
  /// Creates a [NetworkingRetryInterceptor].
  NetworkingRetryInterceptor({
    required this.dio,
    this.globalRetryConfig,
  });

  /// The [Dio] instance used to re-issue the request.
  final Dio dio;

  /// The global retry configuration to use if no per-request
  /// configuration is provided.
  final RetryConfig? globalRetryConfig;

  /// Key used to store the [RetryConfig] in [RequestOptions.extra].
  static const extraRetryConfig = 'retry_config';

  /// Key used to store the current retry count in [RequestOptions.extra].
  static const _extraRetryCount = 'retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final retryConfig =
        options.extra[extraRetryConfig] as RetryConfig? ?? globalRetryConfig;

    if (retryConfig == null || !_shouldRetry(err)) {
      return super.onError(err, handler);
    }

    // If this request already has a retry count, it means it's already
    // being handled by a retry loop. We call super.onError to let the
    // original caller handle the failure.
    if (options.extra.containsKey(_extraRetryCount)) {
      return super.onError(err, handler);
    }

    var lastError = err;
    var currentRetryCount = 0;

    while (currentRetryCount < retryConfig.maxRetries) {
      currentRetryCount++;
      // Mark the request as being retried to avoid recursive retries
      options.extra[_extraRetryCount] = currentRetryCount;

      await Future<void>.delayed(retryConfig.retryInterval);

      try {
        final response = await dio.fetch<dynamic>(options);
        return handler.resolve(response);
      } on DioException catch (e) {
        lastError = e;
        if (!_shouldRetry(e)) {
          break;
        }
      }
    }

    // If all retries failed, propagate the last error
    return super.onError(lastError, handler);
  }

  bool _shouldRetry(DioException err) {
    // Retry on timeouts, connection errors or server errors (5xx)
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.type == DioExceptionType.badResponse &&
            (err.response?.statusCode ?? 0) >= 500);
  }
}
