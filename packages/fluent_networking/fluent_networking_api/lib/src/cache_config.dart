import 'package:equatable/equatable.dart';

/// Configuration for caching a networking request.
class CacheConfig extends Equatable {
  /// Creates a [CacheConfig].
  const CacheConfig({
    this.duration = const Duration(minutes: 5),
    this.forceRefresh = false,
    this.key,
  });

  /// The duration for which the response should be cached.
  /// Defaults to 5 minutes.
  final Duration duration;

  /// Whether to force a refresh of the cache.
  /// If true, the request will be made even if a cached response exists.
  final bool forceRefresh;

  /// An optional custom key for the cache.
  /// If not provided, the request URI and parameters will be used.
  final String? key;

  @override
  List<Object?> get props => [duration, forceRefresh, key];
}
