import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';

/// A networking interceptor that caches requests and responses.
class NetworkingCacheInterceptor extends Interceptor {
  /// The key used to store the cache configuration in [RequestOptions.extra].
  static const extraCacheConfig = 'networking_cache_config';

  /// The maximum number of entries to keep in the cache.
  static const _maxEntries = 100;

  /// In-memory cache using a LinkedHashMap to maintain insertion order for LRU.
  final Map<String, _CacheEntry> _cache = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final cacheConfig = options.extra[extraCacheConfig] as CacheConfig?;

    if (cacheConfig == null) {
      return super.onRequest(options, handler);
    }

    if (cacheConfig.forceRefresh) {
      return super.onRequest(options, handler);
    }

    final key = cacheConfig.key ?? _buildKey(options);
    final entry = _cache[key];

    if (entry != null) {
      if (entry.isValid) {
        // Move to end to mark as recently used
        _cache.remove(key);
        _cache[key] = entry;

        return handler.resolve(
          Response(
            requestOptions: options,
            data: entry.data,
            statusCode: entry.statusCode,
            statusMessage: 'OK (Cached)',
          ),
        );
      } else {
        _cache.remove(key);
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final cacheConfig =
        response.requestOptions.extra[extraCacheConfig] as CacheConfig?;
    final statusCode = response.statusCode ?? 0;
    final isSuccess = statusCode >= 200 && statusCode < 300;

    if (cacheConfig != null && isSuccess) {
      final key = cacheConfig.key ?? _buildKey(response.requestOptions);

      // Evict oldest entry if limit reached
      if (_cache.length >= _maxEntries && !_cache.containsKey(key)) {
        _cache.remove(_cache.keys.first);
      }

      _cache[key] = _CacheEntry(
        data: response.data,
        statusCode: statusCode,
        expiry: DateTime.now().add(cacheConfig.duration),
      );
    }

    super.onResponse(response, handler);
  }

  String _buildKey(RequestOptions options) {
    final data = options.data;
    String? dataString;

    try {
      if (data is Map || data is List) {
        dataString = jsonEncode(data);
      } else {
        dataString = data?.toString();
      }
    } on Object catch (_) {
      dataString = data.toString();
    }

    return '${options.method}:${options.uri}:$dataString';
  }
}

class _CacheEntry {
  _CacheEntry({
    required this.data,
    required this.statusCode,
    required this.expiry,
  });

  final dynamic data;
  final int statusCode;
  final DateTime expiry;

  bool get isValid => DateTime.now().isBefore(expiry);
}
