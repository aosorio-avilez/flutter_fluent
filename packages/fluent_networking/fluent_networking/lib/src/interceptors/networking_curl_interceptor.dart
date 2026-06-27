import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';

/// A networking interceptor that prints requests as copy-pasteable
/// cURL commands.
///
/// It sanitizes sensitive headers, query parameters, and body keys
/// using the [LoggerApi] for output.
class NetworkingCurlInterceptor extends Interceptor {
  /// Creates a [NetworkingCurlInterceptor].
  NetworkingCurlInterceptor({
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

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      _logCurl(options);
    } on Object catch (e, s) {
      try {
        _logger?.logError(
          '❌ NetworkingCurlInterceptor: Failed to log curl: $e',
          stackTrace: s,
        );
      } on Object {
        // Silently ignore if logging itself fails
      }
    }
    super.onRequest(options, handler);
  }

  void _logCurl(RequestOptions options) {
    if (_logger == null) return;

    final method = options.method.toUpperCase();
    final uri = _sanitizeUri(options.uri);
    final headers = options.headers;
    final data = options.data;

    final curl = StringBuffer('curl -X $method "$uri" \\\n');

    // Add headers
    headers.forEach((key, value) {
      final isSensitive = _sensitiveHeaders.contains(key.toLowerCase());
      final val = isSensitive ? '***REDACTED***' : value.toString();
      curl.write('  -H "$key: $val" \\\n');
    });

    // Add body
    if (data != null) {
      if (data is FormData) {
        for (final entry in data.fields) {
          final isSensitive = _sensitiveBodyKeys.contains(
            entry.key.toLowerCase(),
          );
          final val = isSensitive ? '***REDACTED***' : entry.value;
          curl.write('  -F "${entry.key}=$val" \\\n');
        }
        for (final entry in data.files) {
          curl.write(
            '  -F "${entry.key}=@${entry.value.filename ?? 'file'}" \\\n',
          );
        }
      } else if (data is Map || data is List) {
        final sanitized = _sanitizeBodyStatic(data, _sensitiveBodyKeys);
        final jsonStr = json.encode(sanitized);
        final escapedJson = jsonStr.replaceAll("'", r"'\''");
        curl.write("  -d '$escapedJson' \\\n");
      } else if (data is String) {
        try {
          final decoded = json.decode(data);
          final sanitized = _sanitizeBodyStatic(decoded, _sensitiveBodyKeys);
          final jsonStr = json.encode(sanitized);
          final escapedJson = jsonStr.replaceAll("'", r"'\''");
          curl.write("  -d '$escapedJson' \\\n");
        } on Object catch (_) {
          final escaped = data.replaceAll("'", r"'\''");
          curl.write("  -d '$escaped' \\\n");
        }
      } else {
        final escaped = data.toString().replaceAll("'", r"'\''");
        curl.write("  -d '$escaped' \\\n");
      }
    }

    // Remove the trailing backslash and newline if it exists
    var curlStr = curl.toString().trim();
    if (curlStr.endsWith(r'\')) {
      curlStr = curlStr.substring(0, curlStr.length - 1).trim();
    }

    _logger.logInfo(
      '''
┌ HTTP cURL COMMAND ──────────────────────────────────────────────
$curlStr
└──────────────────────────────────────────────────────────────────''',
    );
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

        final keyStr = key.toString();
        final isSensitive =
            sensitiveBodyKeys.contains(keyStr) ||
            sensitiveBodyKeys.contains(keyStr.toLowerCase());

        if (isSensitive) {
          result ??= Map<dynamic, dynamic>.of(data);
          result[key] = '***REDACTED***';
        } else if (value is Map || value is List) {
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
}
