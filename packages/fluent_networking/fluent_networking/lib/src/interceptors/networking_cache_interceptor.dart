import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';

/// A networking interceptor that caches requests and responses.
class NetworkingCacheInterceptor extends Interceptor {
  /// The key used to store the cache configuration in [RequestOptions.extra].
  static const extraCacheConfig = 'networking_cache_config';

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
        return handler.resolve(
          Response(
            requestOptions: options,
            data: entry.data,
            statusCode: 200,
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

    if (cacheConfig != null && response.statusCode == 200) {
      final key = cacheConfig.key ?? _buildKey(response.requestOptions);
      _cache[key] = _CacheEntry(
        data: response.data,
        expiry: DateTime.now().add(cacheConfig.duration),
      );
    }

    super.onResponse(response, handler);
  }

  String _buildKey(RequestOptions options) {
    return '${options.method}:${options.uri}:${options.data}';
  }
}

class _CacheEntry {
  _CacheEntry({required this.data, required this.expiry});

  final dynamic data;
  final DateTime expiry;

  bool get isValid => DateTime.now().isBefore(expiry);
}
