import 'package:dio/dio.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

/// A secure networking interceptor that logs requests and responses.
///
/// It sanitizes sensitive headers (e.g., Authorization) and uses the
/// [LoggerApi] for output.
class NetworkingLogInterceptor extends Interceptor {
  /// Creates a [NetworkingLogInterceptor].
  const NetworkingLogInterceptor();

  static const _sensitiveHeaders = {
    'authorization',
    'cookie',
    'proxy-authorization',
    'set-cookie',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('NETWORK REQUEST: [${options.method}] ${options.uri}');
    _logHeaders('Request Headers', options.headers);
    if (options.data != null) {
      _log('Request Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(
      'NETWORK RESPONSE: [${response.requestOptions.method}] '
      '${response.requestOptions.uri} '
      'Status: ${response.statusCode} ${response.statusMessage}',
    );
    _logHeaders('Response Headers', response.headers.map);
    if (response.data != null) {
      _log('Response Body: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(
      'NETWORK ERROR: [${err.requestOptions.method}] '
      '${err.requestOptions.uri}\n'
      'Message: ${err.message}\n'
      'Error: ${err.error}',
      stackTrace: err.stackTrace,
    );
    if (err.response != null) {
      _logHeaders('Error Response Headers', err.response!.headers.map);
      _log('Error Response Body: ${err.response!.data}');
    }
    super.onError(err, handler);
  }

  void _logHeaders(String label, Map<String, dynamic> headers) {
    if (headers.isEmpty) return;

    final sanitizedHeaders = headers.map((key, value) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        return MapEntry(key, '***REDACTED***');
      }
      return MapEntry(key, value);
    });

    _log('$label: $sanitizedHeaders');
  }

  void _log(String message) {
    try {
      Fluent.get<LoggerApi>().logInfo(message);
    } on Object catch (_) {
      // If LoggerApi is not registered, we fall back to nothing or a basic
      // print in debug mode to avoid losing critical information during
      // development but only if it's not a production build.
      assert(
        () {
          /// Redundant print for debug mode.
          // ignore: avoid_print
          print(message);
          return true;
        }(),
        'LoggerApi is not registered',
      );
    }
  }

  void _logError(String message, {StackTrace? stackTrace}) {
    try {
      Fluent.get<LoggerApi>().logError(message, stackTrace: stackTrace);
    } on Object catch (_) {
      assert(
        () {
          /// Redundant print for debug mode.
          // ignore: avoid_print
          print(message);
          if (stackTrace != null) {
            /// Redundant print for debug mode.
            // ignore: avoid_print
            print(stackTrace);
          }
          return true;
        }(),
        'LoggerApi is not registered',
      );
    }
  }
}
