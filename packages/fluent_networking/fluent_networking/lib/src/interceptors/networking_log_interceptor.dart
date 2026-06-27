import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

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
    Set<String>? sensitiveQueryParams,
  }) : _logger = logger,
       _sensitiveHeaders = {
         ..._defaultSensitiveHeaders,
         if (sensitiveHeaders != null)
           ...sensitiveHeaders.map((e) => e.toLowerCase()),
       },
       _sensitiveBodyKeys = {
         ..._defaultSensitiveBodyKeys,
         if (sensitiveBodyKeys != null)
           ...sensitiveBodyKeys.map((e) => e.toLowerCase()),
       },
       _sensitiveQueryParams = {
         ..._defaultSensitiveQueryParams,
         if (sensitiveQueryParams != null)
           ...sensitiveQueryParams.map((e) => e.toLowerCase()),
       };

  final LoggerApi? _logger;
  final Set<String> _sensitiveHeaders;
  final Set<String> _sensitiveBodyKeys;
  final Set<String> _sensitiveQueryParams;

  static const _defaultSensitiveHeaders = {
    'authorization',
    'cookie',
    'proxy-authorization',
    'set-cookie',
    'x-api-key',
    'api-key',
  };

  static const _defaultSensitiveQueryParams = {
    'api_key',
    'apikey',
    'access_token',
    'token',
    'secret',
    'password',
    'pass',
    'pwd',
  };

  static const _defaultSensitiveBodyKeys = {
    'password',
    'pass',
    'pwd',
    'token',
    'secret',
    'api_key',
    'apikey',
    'access_token',
    'refresh_token',
    'credit_card',
    'cvv',
    'cvc',
    'email',
    'phone_number',
  };

  static const _extraStartTime = 'networking_start_time';

  static const _encoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_extraStartTime] = DateTime.now().millisecondsSinceEpoch;
    _logRequest(options);
    super.onRequest(options, handler);
  }

  void _logRequest(RequestOptions options) {
    if (_logger == null) return;

    final method = options.method.toUpperCase();
    final uri = _sanitizeUri(options.uri);
    final headers = _formatHeaders(options.headers).toList();
    final data = _toSendableData(options.data);
    final sensitiveBodyKeys = _sensitiveBodyKeys;

    if (_isLargeData(data)) {
      unawaited(
        Isolate.run(() {
          return _formatRequestLog(
            method: method,
            uri: uri,
            headers: headers,
            data: data,
            sensitiveBodyKeys: sensitiveBodyKeys,
          );
        }).then(_log).catchError((_) {}),
      );
    } else {
      final lines = _formatRequestLog(
        method: method,
        uri: uri,
        headers: headers,
        data: data,
        sensitiveBodyKeys: sensitiveBodyKeys,
      );
      _log(lines);
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logResponse(response);
    super.onResponse(response, handler);
  }

  void _logResponse(Response<dynamic> response) {
    if (_logger == null) return;

    final method = response.requestOptions.method.toUpperCase();
    final uri = _sanitizeUri(response.requestOptions.uri);
    final statusCode = response.statusCode;
    final statusMessage = response.statusMessage ?? 'Unknown';
    final duration = _getDuration(response.requestOptions);
    final headers = _formatHeaders(response.headers.map).toList();
    final data = _toSendableData(response.data);
    final sensitiveBodyKeys = _sensitiveBodyKeys;

    if (_isLargeData(data)) {
      unawaited(
        Isolate.run(() {
          return _formatResponseLog(
            method: method,
            uri: uri,
            statusCode: statusCode,
            statusMessage: statusMessage,
            duration: duration,
            headers: headers,
            data: data,
            sensitiveBodyKeys: sensitiveBodyKeys,
          );
        }).then(_log).catchError((_) {}),
      );
    } else {
      final lines = _formatResponseLog(
        method: method,
        uri: uri,
        statusCode: statusCode,
        statusMessage: statusMessage,
        duration: duration,
        headers: headers,
        data: data,
        sensitiveBodyKeys: sensitiveBodyKeys,
      );
      _log(lines);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logErrorAsync(err);
    super.onError(err, handler);
  }

  void _logErrorAsync(DioException err) {
    if (_logger == null) return;

    final method = err.requestOptions.method.toUpperCase();
    final uri = _sanitizeUri(err.requestOptions.uri);
    final statusCode = err.response?.statusCode;
    final message = err.message;
    final duration = _getDuration(err.requestOptions);
    final responseHeaders = err.response != null
        ? _formatHeaders(err.response!.headers.map).toList()
        : const <String>[];
    final responseData = _toSendableData(err.response?.data);
    final error = err.error?.toString();
    final sensitiveBodyKeys = _sensitiveBodyKeys;
    final stackTrace = err.stackTrace;

    if (_isLargeData(responseData)) {
      unawaited(
        Isolate.run(() {
              return _formatErrorLog(
                method: method,
                uri: uri,
                statusCode: statusCode,
                message: message,
                duration: duration,
                responseHeaders: responseHeaders,
                responseData: responseData,
                error: error,
                sensitiveBodyKeys: sensitiveBodyKeys,
              );
            })
            .then((lines) {
              _logError(lines, stackTrace: stackTrace);
            })
            .catchError((_) {}),
      );
    } else {
      final lines = _formatErrorLog(
        method: method,
        uri: uri,
        statusCode: statusCode,
        message: message,
        duration: duration,
        responseHeaders: responseHeaders,
        responseData: responseData,
        error: error,
        sensitiveBodyKeys: sensitiveBodyKeys,
      );
      _logError(lines, stackTrace: stackTrace);
    }
  }

  static List<String> _formatRequestLog({
    required String method,
    required String uri,
    required List<String> headers,
    required dynamic data,
    required Set<String> sensitiveBodyKeys,
  }) {
    final lines = <String>[
      '┌ HTTP REQUEST ───────────────────────────────────────────────────',
      '│ Method: $method',
      '│ URI: $uri',
    ];
    if (headers.isNotEmpty) {
      lines.add('│ Headers:');
      for (final header in headers) {
        lines.add('│   $header');
      }
    }
    if (data != null) {
      lines.add('│ Body:');
      final formatted = _formatDataStatic(data, sensitiveBodyKeys);
      for (final line in LineSplitter.split(formatted)) {
        lines.add('│   $line');
      }
    }
    lines.add(
      '└──────────────────────────────────────────────────────────────────',
    );
    return lines;
  }

  static List<String> _formatResponseLog({
    required String method,
    required String uri,
    required int? statusCode,
    required String statusMessage,
    required int? duration,
    required List<String> headers,
    required dynamic data,
    required Set<String> sensitiveBodyKeys,
  }) {
    final lines = <String>[
      '┌ HTTP RESPONSE ──────────────────────────────────────────────────',
      '│ Success: [$method] $uri',
      '│ Status: $statusCode $statusMessage',
    ];
    if (duration != null) {
      lines.add('│ Duration: ${duration}ms');
    }
    if (headers.isNotEmpty) {
      lines.add('│ Headers:');
      for (final header in headers) {
        lines.add('│   $header');
      }
    }
    if (data != null) {
      lines.add('│ Body:');
      final formatted = _formatDataStatic(data, sensitiveBodyKeys);
      for (final line in LineSplitter.split(formatted)) {
        lines.add('│   $line');
      }
    }
    lines.add(
      '└──────────────────────────────────────────────────────────────────',
    );
    return lines;
  }

  static List<String> _formatErrorLog({
    required String method,
    required String uri,
    required int? statusCode,
    required String? message,
    required int? duration,
    required List<String> responseHeaders,
    required dynamic responseData,
    required String? error,
    required Set<String> sensitiveBodyKeys,
  }) {
    final lines = <String>[
      '┌ HTTP ERROR ─────────────────────────────────────────────────────',
      '│ Failure: [$method] $uri',
    ];
    if (statusCode != null) {
      lines.add('│ Status: $statusCode');
    }
    lines.add('│ Message: $message');
    if (duration != null) {
      lines.add('│ Duration: ${duration}ms');
    }
    if (responseHeaders.isNotEmpty) {
      lines.add('│ Response Headers:');
      for (final header in responseHeaders) {
        lines.add('│   $header');
      }
    }
    if (responseData != null) {
      lines.add('│ Response Body:');
      final formatted = _formatDataStatic(responseData, sensitiveBodyKeys);
      for (final line in LineSplitter.split(formatted)) {
        lines.add('│   $line');
      }
    }
    if (error != null) {
      lines.add('│ Error: $error');
    }
    lines.add(
      '└──────────────────────────────────────────────────────────────────',
    );
    return lines;
  }

  Iterable<String> _formatHeaders(Map<String, dynamic> headers) sync* {
    for (final entry in headers.entries) {
      final key = entry.key;
      final isSensitive = _sensitiveHeaders.contains(key.toLowerCase());
      final value = isSensitive ? '***REDACTED***' : entry.value.toString();
      yield '$key: $value';
    }
  }

  static String _formatDataStatic(dynamic data, Set<String> sensitiveBodyKeys) {
    try {
      if (data is String) {
        final decoded = json.decode(data);
        final sanitized = _sanitizeBodyStatic(
          decoded,
          sensitiveBodyKeys,
        );
        return _encoder.convert(sanitized);
      }
      final sanitized = _sanitizeBodyStatic(data, sensitiveBodyKeys);
      return _encoder.convert(sanitized);
    } on Object catch (_) {
      // Return raw data if it fails to format as JSON
    }
    return data.toString();
  }

  String _sanitizeUri(Uri uri) {
    if (!uri.hasQuery) return uri.toString();

    Map<String, dynamic>? queryParameters;
    final queryParametersAll = uri.queryParametersAll;

    for (final key in queryParametersAll.keys) {
      final isSensitive = _sensitiveQueryParams.contains(key.toLowerCase());

      if (isSensitive) {
        queryParameters ??= Map<String, List<String>>.of(
          queryParametersAll,
        );
        queryParameters[key] = ['***REDACTED***'];
      }
    }

    return queryParameters != null
        ? uri.replace(queryParameters: queryParameters).toString()
        : uri.toString();
  }

  static dynamic _sanitizeBodyStatic(
    dynamic data,
    Set<String> sensitiveBodyKeys,
  ) {
    if (sensitiveBodyKeys.isEmpty) return data;

    if (data is Map) {
      Map<dynamic, dynamic>? result;

      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;

        // Optimized sensitive key check: check exact string first
        final keyStr = key.toString();
        final isSensitive =
            sensitiveBodyKeys.contains(keyStr) ||
            sensitiveBodyKeys.contains(keyStr.toLowerCase());

        if (isSensitive) {
          result ??= Map<dynamic, dynamic>.of(data);
          result[key] = '***REDACTED***';
        } else if (value is Map || value is List) {
          // Only recurse for nested structures
          final sanitizedValue = _sanitizeBodyStatic(value, sensitiveBodyKeys);
          if (!identical(sanitizedValue, value)) {
            result ??= Map<dynamic, dynamic>.of(data);
            result[key] = sanitizedValue;
          }
        }
      }
      return result ?? data;
    } else if (data is List) {
      List<dynamic>? result;
      for (var i = 0; i < data.length; i++) {
        final value = data[i];
        if (value is Map || value is List) {
          final sanitizedValue = _sanitizeBodyStatic(value, sensitiveBodyKeys);
          if (!identical(sanitizedValue, value)) {
            result ??= List<dynamic>.of(data);
            result[i] = sanitizedValue;
          }
        }
      }
      return result ?? data;
    }
    return data;
  }

  static Object? _toSendableData(dynamic data) {
    if (data == null) return null;
    if (data is String || data is num || data is bool) return data;
    if (data is FormData) {
      final fields = <String, dynamic>{};
      for (final entry in data.fields) {
        fields[entry.key] = entry.value;
      }
      for (final entry in data.files) {
        fields[entry.key] = '[FILE: ${entry.value.filename}]';
      }
      return fields;
    }
    if (data is Map || data is List) {
      return data;
    }
    return data.toString();
  }

  static bool _isLargeData(dynamic data) {
    if (data == null) return false;
    if (data is String) {
      return data.length > 10000;
    }
    if (data is Map) {
      return data.length > 50;
    }
    if (data is List) {
      return data.length > 50;
    }
    return false;
  }

  int? _getDuration(RequestOptions options) {
    final startTime = options.extra[_extraStartTime] as int?;
    if (startTime == null) return null;
    return DateTime.now().millisecondsSinceEpoch - startTime;
  }

  void _log(Iterable<String> lines) {
    if (_logger == null) return;
    // We intentionally use a for-in loop here rather than `.forEach` to bypass
    // the extra closure allocation overhead in performance-critical hot paths.
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
