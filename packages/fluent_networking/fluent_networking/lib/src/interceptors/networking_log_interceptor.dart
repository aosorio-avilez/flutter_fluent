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

    final output = [
      '┌ HTTP REQUEST ───────────────────────────────────────────────────',
      '│ Method: ${options.method.toUpperCase()}',
      '│ URI: ${options.uri}',
      if (options.headers.isNotEmpty) ...[
        '│ Headers:',
        ..._formatHeaders(options.headers).map((e) => '│   $e'),
      ],
      if (options.data != null) ...[
        '│ Body:',
        ..._formatData(options.data).split('\n').map((e) => '│   $e'),
      ],
      '└──────────────────────────────────────────────────────────────────',
    ];

    _log(output);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final duration = _getDuration(response.requestOptions);
    final status = response.statusCode;
    final statusName = response.statusMessage ?? 'Unknown';

    final summary =
        '│ Success: [${response.requestOptions.method.toUpperCase()}] '
        '${response.requestOptions.uri}';

    final output = [
      '┌ HTTP RESPONSE ──────────────────────────────────────────────────',
      summary,
      '│ Status: $status $statusName',
      if (duration != null) '│ Duration: ${duration}ms',
      if (response.headers.map.isNotEmpty) ...[
        '│ Headers:',
        ..._formatHeaders(response.headers.map).map((e) => '│   $e'),
      ],
      if (response.data != null) ...[
        '│ Body:',
        ..._formatData(response.data).split('\n').map((e) => '│   $e'),
      ],
      '└──────────────────────────────────────────────────────────────────',
    ];

    _log(output);

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final duration = _getDuration(err.requestOptions);
    final status = err.response?.statusCode;
    final message = err.message;

    final summary =
        '│ Failure: [${err.requestOptions.method.toUpperCase()}] '
        '${err.requestOptions.uri}';

    final output = [
      '┌ HTTP ERROR ─────────────────────────────────────────────────────',
      summary,
      if (status != null) '│ Status: $status',
      '│ Message: $message',
      if (duration != null) '│ Duration: ${duration}ms',
      if (err.response?.headers.map.isNotEmpty ?? false) ...[
        '│ Response Headers:',
        ..._formatHeaders(err.response!.headers.map).map((e) => '│   $e'),
      ],
      if (err.response?.data != null) ...[
        '│ Response Body:',
        ..._formatData(err.response!.data).split('\n').map((e) => '│   $e'),
      ],
      if (err.error != null) '│ Error: ${err.error}',
      '└──────────────────────────────────────────────────────────────────',
    ];

    _logError(output, stackTrace: err.stackTrace);

    super.onError(err, handler);
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
      return data.map((key, value) {
        final isSensitive =
            _sensitiveBodyKeys.contains(key.toString().toLowerCase());
        if (isSensitive) {
          return MapEntry(key, '***REDACTED***');
        }
        return MapEntry(key, _sanitizeBody(value));
      });
    } else if (data is List) {
      return data.map(_sanitizeBody).toList();
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
    lines.forEach(_logger.logInfo);
  }

  void _logError(List<String> lines, {StackTrace? stackTrace}) {
    if (_logger == null) return;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isLastLine = i == lines.length - 1;
      _logger.logError(
        line,
        stackTrace: isLastLine ? stackTrace : null,
      );
    }
  }
}
