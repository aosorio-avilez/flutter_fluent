import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';

/// A secure networking interceptor that logs requests and responses.
///
/// It sanitizes sensitive headers (e.g., Authorization) and uses the
/// [LoggerApi] for output.
class NetworkingLogInterceptor extends Interceptor {
  /// Creates a [NetworkingLogInterceptor].
  NetworkingLogInterceptor({
    required LoggerApi? logger,
    Set<String>? sensitiveHeaders,
    Set<String>? sensitiveBodyKeys,
  }) : _logger = logger,
       _sensitiveHeaders = {
         ..._defaultSensitiveHeaders,
         if (sensitiveHeaders != null)
           ...sensitiveHeaders.map((e) => e.toLowerCase()),
       },
       _sensitiveBodyKeys =
           sensitiveBodyKeys?.map((e) => e.toLowerCase()).toSet() ?? const {};

  final LoggerApi? _logger;
  final Set<String> _sensitiveHeaders;
  final Set<String> _sensitiveBodyKeys;

  static const _defaultSensitiveHeaders = {
    'authorization',
    'cookie',
    'proxy-authorization',
    'set-cookie',
  };

  static const _extraStartTime = 'networking_start_time';

  static const _encoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_extraStartTime] = DateTime.now().millisecondsSinceEpoch;
    _log(_yieldRequestLog(options));
    super.onRequest(options, handler);
  }

  Iterable<String> _yieldRequestLog(RequestOptions options) sync* {
    yield '┌ HTTP REQUEST ───────────────────────────────────────────────────';
    yield '│ Method: ${options.method.toUpperCase()}';
    yield '│ URI: ${options.uri}';
    if (options.headers.isNotEmpty) {
      yield '│ Headers:';
      for (final header in _formatHeaders(options.headers)) {
        yield '│   $header';
      }
    }
    if (options.data != null) {
      yield '│ Body:';
      for (final line in LineSplitter.split(_formatData(options.data))) {
        yield '│   $line';
      }
    }
    yield '└──────────────────────────────────────────────────────────────────';
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(_yieldResponseLog(response));
    super.onResponse(response, handler);
  }

  Iterable<String> _yieldResponseLog(Response<dynamic> response) sync* {
    final duration = _getDuration(response.requestOptions);
    final status = response.statusCode;
    final statusName = response.statusMessage ?? 'Unknown';

    yield '┌ HTTP RESPONSE ──────────────────────────────────────────────────';
    yield '│ Success: [${response.requestOptions.method.toUpperCase()}] '
        '${response.requestOptions.uri}';
    yield '│ Status: $status $statusName';
    if (duration != null) {
      yield '│ Duration: ${duration}ms';
    }
    if (response.headers.map.isNotEmpty) {
      yield '│ Headers:';
      for (final header in _formatHeaders(response.headers.map)) {
        yield '│   $header';
      }
    }
    if (response.data != null) {
      yield '│ Body:';
      for (final line in LineSplitter.split(_formatData(response.data))) {
        yield '│   $line';
      }
    }
    yield '└──────────────────────────────────────────────────────────────────';
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(_yieldErrorLog(err), stackTrace: err.stackTrace);
    super.onError(err, handler);
  }

  Iterable<String> _yieldErrorLog(DioException err) sync* {
    final duration = _getDuration(err.requestOptions);
    final status = err.response?.statusCode;
    final message = err.message;

    yield '┌ HTTP ERROR ─────────────────────────────────────────────────────';
    yield '│ Failure: [${err.requestOptions.method.toUpperCase()}] '
        '${err.requestOptions.uri}';
    if (status != null) {
      yield '│ Status: $status';
    }
    yield '│ Message: $message';
    if (duration != null) {
      yield '│ Duration: ${duration}ms';
    }
    if (err.response?.headers.map.isNotEmpty ?? false) {
      yield '│ Response Headers:';
      for (final header in _formatHeaders(err.response!.headers.map)) {
        yield '│   $header';
      }
    }
    if (err.response?.data != null) {
      yield '│ Response Body:';
      for (final line in LineSplitter.split(_formatData(err.response!.data))) {
        yield '│   $line';
      }
    }
    if (err.error != null) {
      yield '│ Error: ${err.error}';
    }
    yield '└──────────────────────────────────────────────────────────────────';
  }

  Iterable<String> _formatHeaders(Map<String, dynamic> headers) {
    return headers.entries.map((entry) {
      final key = entry.key;
      final isSensitive = _sensitiveHeaders.contains(key.toLowerCase());
      final value = isSensitive ? '***REDACTED***' : entry.value.toString();
      return '$key: $value';
    });
  }

  String _formatData(dynamic data) {
    try {
      final sanitized = _sanitizeBody(data);
      if (sanitized is String) {
        final decoded = json.decode(sanitized);
        return _encoder.convert(_sanitizeBody(decoded));
      }
      return _encoder.convert(sanitized);
    } on Object catch (_) {
      // Return raw data if it fails to format as JSON
    }
    return data.toString();
  }

  dynamic _sanitizeBody(dynamic data) {
    if (_sensitiveBodyKeys.isEmpty) return data;

    if (data is Map) {
      Map<dynamic, dynamic>? result;
      data.forEach((key, value) {
        final isSensitive = _sensitiveBodyKeys.contains(
          key.toString().toLowerCase(),
        );
        if (isSensitive) {
          result ??= Map<dynamic, dynamic>.from(data);
          result![key] = '***REDACTED***';
        } else {
          final sanitizedValue = _sanitizeBody(value);
          if (!identical(sanitizedValue, value)) {
            result ??= Map<dynamic, dynamic>.from(data);
            result![key] = sanitizedValue;
          }
        }
      });
      return result ?? data;
    } else if (data is List) {
      List<dynamic>? result;
      for (var i = 0; i < data.length; i++) {
        final value = data[i];
        final sanitizedValue = _sanitizeBody(value);
        if (!identical(sanitizedValue, value)) {
          result ??= List<dynamic>.from(data);
          result[i] = sanitizedValue;
        }
      }
      return result ?? data;
    }
    return data;
  }

  int? _getDuration(RequestOptions options) {
    final startTime = options.extra[_extraStartTime] as int?;
    if (startTime == null) return null;
    return DateTime.now().millisecondsSinceEpoch - startTime;
  }

  void _log(Iterable<String> lines) {
    if (_logger == null) return;
    // Using for-in to avoid closure allocation, although linter prefers forEach
    // with tear-offs.
    // ignore: prefer_foreach
    for (final line in lines) {
      _logger.logInfo(line);
    }
  }

  void _logError(Iterable<String> lines, {StackTrace? stackTrace}) {
    if (_logger == null) return;

    final iterator = lines.iterator;
    if (!iterator.moveNext()) return;

    var current = iterator.current;
    while (iterator.moveNext()) {
      _logger.logError(current);
      current = iterator.current;
    }
    _logger.logError(current, stackTrace: stackTrace);
  }
}
