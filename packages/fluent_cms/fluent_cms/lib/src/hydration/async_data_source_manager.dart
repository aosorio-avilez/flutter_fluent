import 'dart:async';
import 'dart:convert';

import 'package:fluent_cms/src/cms_config.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:flutter/foundation.dart';

/// Optional custom callback to fetch an [AsyncSource] when [NetworkingApi] is
/// not used or overridden.
typedef CmsAsyncDataFetcher =
    Future<Map<String, dynamic>> Function(
      AsyncSource source, {
      bool forceRefresh,
      Map<String, dynamic>? queryParameters,
    });

/// Lifecycle state of an [AsyncSource].
enum AsyncSourceStatus {
  /// Not yet requested.
  idle,

  /// Request is currently in flight.
  loading,

  /// Request succeeded (or resolved via `fallback`).
  loaded,

  /// Request failed and no `fallback` was configured.
  error,
}

/// Immutable state snapshot for a single [AsyncSource].
@immutable
class AsyncSourceSnapshot {
  /// Creates an [AsyncSourceSnapshot].
  const AsyncSourceSnapshot({
    this.status = AsyncSourceStatus.idle,
    this.data,
    this.errorMessage,
    this.usedFallback = false,
    this.updatedAt,
  });

  /// Current status of the async source.
  final AsyncSourceStatus status;

  /// Resolved payload (or `fallback` payload if [usedFallback] is `true`).
  final Map<String, dynamic>? data;

  /// Diagnostic error message when the request failed.
  final String? errorMessage;

  /// Whether [data] comes from `AsyncSource.fallback`.
  final bool usedFallback;

  /// Timestamp when [data] was last resolved.
  final DateTime? updatedAt;

  /// Whether valid data (live or fallback) is available for hydration.
  bool get hasData => data != null;
}

/// Default [AsyncDataSource] implementation backed by [NetworkingApi] or an
/// optional [CmsAsyncDataFetcher].
class NetworkingAsyncDataSource implements AsyncDataSource {
  /// Creates a [NetworkingAsyncDataSource].
  const NetworkingAsyncDataSource({
    this.config = const CmsConfig(),
    this.networkingApi,
    this.customFetcher,
    this.logger,
  });

  /// Global CMS configuration (used for `isUriAllowed` security checks).
  final CmsConfig config;

  /// Optional `fluent_networking_api` client.
  final NetworkingApi? networkingApi;

  /// Optional custom fetcher callback.
  final CmsAsyncDataFetcher? customFetcher;

  /// Optional logger.
  final LoggerApi? logger;

  @override
  Future<Map<String, dynamic>> fetch(
    AsyncSource source, {
    bool forceRefresh = false,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (!config.isUriAllowed(source.endpoint)) {
      logger?.logError(
        '[fluent_cms] Blocked disallowed asyncSource endpoint '
        '"${source.endpoint}".',
      );
      if (source.fallback != null) {
        return source.fallback!;
      }
      throw ArgumentError.value(
        source.endpoint,
        'source.endpoint',
        'Blocked by CmsConfig.isUriAllowed policy.',
      );
    }

    try {
      final fetcher = customFetcher;
      if (fetcher != null) {
        return await fetcher(
          source,
          forceRefresh: forceRefresh,
          queryParameters: queryParameters,
        );
      }

      final networking = networkingApi;
      if (networking == null) {
        throw StateError(
          'Cannot fetch asyncSource "${source.endpoint}": neither '
          'customFetcher nor NetworkingApi is available.',
        );
      }

      final method = source.method.trim().toUpperCase();
      final cacheConfig = CacheConfig(forceRefresh: forceRefresh);
      final ResponseResult<dynamic> result;
      if (method == 'POST') {
        result = await networking.post<dynamic>(
          source.endpoint,
          body: queryParameters,
          cacheConfig: cacheConfig,
        );
      } else {
        final targetUrl = _appendQueryParameters(
          source.endpoint,
          queryParameters,
        );
        result = await networking.get<dynamic>(
          targetUrl,
          cacheConfig: cacheConfig,
        );
      }

      switch (result) {
        case Success<dynamic>(:final data):
          return _normalizeMapPayload(data);
        case Failure<dynamic>(:final error):
          throw StateError(
            'AsyncSource "${source.endpoint}" failed: '
            '${error.message} (code=${error.code})',
          );
      }
    } on Object catch (error, stackTrace) {
      logger?.logWarning(
        '[fluent_cms] AsyncSource "${source.endpoint}" failed: $error',
      );
      final fallback = source.fallback;
      if (fallback != null) {
        return fallback;
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  String _appendQueryParameters(
    String endpoint,
    Map<String, dynamic>? queryParameters,
  ) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return endpoint;
    }
    final buffer = StringBuffer(endpoint);
    var isFirst = !endpoint.contains('?');
    for (final entry in queryParameters.entries) {
      final value = entry.value;
      if (value == null) continue;
      buffer
        ..write(isFirst ? '?' : '&')
        ..write(Uri.encodeQueryComponent(entry.key))
        ..write('=')
        ..write(Uri.encodeQueryComponent(value.toString()));
      isFirst = false;
    }
    return buffer.toString();
  }

  Map<String, dynamic> _normalizeMapPayload(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      final map = <String, dynamic>{};
      for (final entry in raw.entries) {
        if (entry.key != null) {
          map[entry.key.toString()] = entry.value;
        }
      }
      return map;
    }
    if (raw is String && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        final map = <String, dynamic>{};
        for (final entry in decoded.entries) {
          if (entry.key != null) {
            map[entry.key.toString()] = entry.value;
          }
        }
        return map;
      }
    }
    if (raw is List) {
      return <String, dynamic>{'items': raw};
    }
    return const <String, dynamic>{};
  }
}

/// Coordinates per-page [AsyncSource] resolution, TTL caching, in-flight
/// deduplication, fallback injection, and reactive status notifications.
class AsyncDataSourceManager {
  /// Creates an [AsyncDataSourceManager].
  AsyncDataSourceManager({
    required this.dataSource,
    Map<String, AsyncSource>? sources,
    LoggerApi? logger,
  }) : _logger = logger {
    if (sources != null) {
      registerSources(sources);
    }
  }

  /// Underlying [AsyncDataSource] implementation.
  final AsyncDataSource dataSource;

  final LoggerApi? _logger;
  final Map<String, AsyncSource> _sources = <String, AsyncSource>{};
  final Map<String, ValueNotifier<AsyncSourceSnapshot>> _notifiers =
      <String, ValueNotifier<AsyncSourceSnapshot>>{};
  final Map<String, Future<Map<String, dynamic>?>> _inFlight =
      <String, Future<Map<String, dynamic>?>>{};
  final Map<String, Map<String, dynamic>> _resolvedData =
      <String, Map<String, dynamic>>{};

  bool _isDisposed = false;

  /// Whether this manager has been disposed.
  bool get isDisposed => _isDisposed;

  /// Registers or updates [sources] for the active page.
  void registerSources(Map<String, AsyncSource> sources) {
    if (_isDisposed) return;
    for (final entry in sources.entries) {
      _sources[entry.key] = entry.value;
      _notifiers.putIfAbsent(
        entry.key,
        () => ValueNotifier<AsyncSourceSnapshot>(const AsyncSourceSnapshot()),
      );
    }
  }

  /// Returns a [ValueListenable] tracking the [AsyncSourceSnapshot] for
  /// [sourceId] (accepts `"wallet"` or `"async.wallet"`).
  ValueListenable<AsyncSourceSnapshot> listenSource(String sourceId) {
    final normalizedId = _normalizeSourceId(sourceId);
    return _notifiers.putIfAbsent(
      normalizedId,
      () => ValueNotifier<AsyncSourceSnapshot>(const AsyncSourceSnapshot()),
    );
  }

  /// Returns the current [AsyncSourceSnapshot] for [sourceId].
  AsyncSourceSnapshot getSnapshot(String sourceId) {
    final normalizedId = _normalizeSourceId(sourceId);
    return _notifiers[normalizedId]?.value ?? const AsyncSourceSnapshot();
  }

  /// Current map of resolved async payloads
  /// (`sourceId -> Map<String, dynamic>`) suitable for
  /// `HydrationScope.asyncData`.
  Map<String, Map<String, dynamic>> get resolvedDataMap =>
      Map<String, Map<String, dynamic>>.unmodifiable(_resolvedData);

  /// Resolves a single [sourceId] (e.g. `"wallet"` or `"async.wallet"`),
  /// deduplicating concurrent requests and honoring `ttlSeconds`.
  Future<Map<String, dynamic>?> resolveSource(
    String sourceId, {
    bool forceRefresh = false,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (_isDisposed) return null;

    final normalizedId = _normalizeSourceId(sourceId);
    final source = _sources[normalizedId];
    final notifier = _notifiers.putIfAbsent(
      normalizedId,
      () => ValueNotifier<AsyncSourceSnapshot>(const AsyncSourceSnapshot()),
    );

    if (source == null) {
      _logger?.logWarning(
        '[fluent_cms] Requested unknown asyncSource "$normalizedId".',
      );
      if (!_isDisposed) {
        notifier.value = AsyncSourceSnapshot(
          status: AsyncSourceStatus.error,
          errorMessage: 'Unknown asyncSource "$normalizedId".',
          updatedAt: DateTime.now(),
        );
      }
      return null;
    }

    if (!forceRefresh) {
      final current = notifier.value;
      if (current.status == AsyncSourceStatus.loaded &&
          current.data != null &&
          !_isExpired(source, current.updatedAt)) {
        return current.data;
      }

      final activeFuture = _inFlight[normalizedId];
      if (activeFuture != null) {
        return activeFuture;
      }
    }

    notifier.value = AsyncSourceSnapshot(
      status: AsyncSourceStatus.loading,
      data: notifier.value.data,
      updatedAt: notifier.value.updatedAt,
    );

    final future = _executeFetch(
      normalizedId,
      source,
      notifier,
      forceRefresh: forceRefresh,
      queryParameters: queryParameters,
    );
    _inFlight[normalizedId] = future;
    try {
      return await future;
    } finally {
      unawaited(_inFlight.remove(normalizedId));
    }
  }

  Future<Map<String, dynamic>?> _executeFetch(
    String sourceId,
    AsyncSource source,
    ValueNotifier<AsyncSourceSnapshot> notifier, {
    required bool forceRefresh,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final data = await dataSource.fetch(
        source,
        forceRefresh: forceRefresh,
        queryParameters: queryParameters,
      );
      if (_isDisposed) return null;

      _resolvedData[sourceId] = data;
      notifier.value = AsyncSourceSnapshot(
        status: AsyncSourceStatus.loaded,
        data: data,
        usedFallback: identical(data, source.fallback),
        updatedAt: DateTime.now(),
      );
      return data;
    } on Object catch (error) {
      if (_isDisposed) return null;

      final fallback = source.fallback;
      if (fallback != null) {
        _resolvedData[sourceId] = fallback;
        notifier.value = AsyncSourceSnapshot(
          status: AsyncSourceStatus.loaded,
          data: fallback,
          errorMessage: error.toString(),
          usedFallback: true,
          updatedAt: DateTime.now(),
        );
        return fallback;
      }

      notifier.value = AsyncSourceSnapshot(
        status: AsyncSourceStatus.error,
        errorMessage: error.toString(),
        updatedAt: DateTime.now(),
      );
      return null;
    }
  }

  /// Resolves all registered [AsyncSource] entries concurrently.
  Future<void> prefetchAll({bool forceRefresh = false}) async {
    if (_isDisposed || _sources.isEmpty) return;

    final futures = <Future<Map<String, dynamic>?>>[];
    for (final key in _sources.keys) {
      futures.add(resolveSource(key, forceRefresh: forceRefresh));
    }
    await Future.wait<Map<String, dynamic>?>(futures);
  }

  bool _isExpired(AsyncSource source, DateTime? updatedAt) {
    final ttl = source.ttlSeconds;
    if (ttl == null || ttl <= 0) return false;
    if (updatedAt == null) return true;
    return DateTime.now().difference(updatedAt).inSeconds >= ttl;
  }

  String _normalizeSourceId(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('async.')) {
      final rest = trimmed.substring(6);
      final dotIndex = rest.indexOf('.');
      return dotIndex == -1 ? rest : rest.substring(0, dotIndex);
    }
    final dotIndex = trimmed.indexOf('.');
    return dotIndex == -1 ? trimmed : trimmed.substring(0, dotIndex);
  }

  /// Disposes all internal [ValueNotifier]s.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _inFlight.clear();
    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    _notifiers.clear();
    _resolvedData.clear();
  }
}
