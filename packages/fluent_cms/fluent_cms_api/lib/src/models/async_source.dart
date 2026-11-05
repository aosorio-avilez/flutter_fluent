import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Configures an independent deferred data request bound to modules.
@immutable
class AsyncSource extends Equatable {
  /// Creates an [AsyncSource].
  const AsyncSource({
    required this.endpoint,
    this.method = 'GET',
    this.headers,
    this.ttlSeconds,
    this.fallback,
  });

  /// Deserializes an [AsyncSource] from a JSON map.
  factory AsyncSource.fromJson(Map<String, dynamic> json) {
    Map<String, String>? parsedHeaders;
    final rawHeaders = json['headers'];
    if (rawHeaders is Map) {
      parsedHeaders = <String, String>{};
      for (final entry in rawHeaders.entries) {
        if (entry.key != null && entry.value != null) {
          parsedHeaders[entry.key.toString()] = entry.value.toString();
        }
      }
    }

    Map<String, dynamic>? parsedFallback;
    final rawFallback = json['fallback'];
    if (rawFallback is Map) {
      parsedFallback = <String, dynamic>{};
      for (final entry in rawFallback.entries) {
        if (entry.key != null) {
          parsedFallback[entry.key.toString()] = entry.value;
        }
      }
    }

    return AsyncSource(
      endpoint: json['endpoint'] as String? ?? '',
      method: (json['method'] as String? ?? 'GET').toUpperCase(),
      headers: parsedHeaders,
      ttlSeconds: (json['ttlSeconds'] as num?)?.toInt(),
      fallback: parsedFallback,
    );
  }

  /// Absolute URL or relative path consumed by `NetworkingApi` or
  /// `AsyncDataSource`.
  final String endpoint;

  /// HTTP verb (`GET`, `POST`, etc.). Defaults to `'GET'`.
  final String method;

  /// Optional additional HTTP headers.
  final Map<String, String>? headers;

  /// Optional cache time-to-live in seconds.
  final int? ttlSeconds;

  /// Optional default data injected into `{{async.<key>}}` if the request
  /// fails.
  final Map<String, dynamic>? fallback;

  /// Serializes this [AsyncSource] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'endpoint': endpoint,
      'method': method,
      if (headers != null) 'headers': headers,
      if (ttlSeconds != null) 'ttlSeconds': ttlSeconds,
      if (fallback != null) 'fallback': fallback,
    };
  }

  /// Returns a copy of this [AsyncSource] with the given fields replaced.
  AsyncSource copyWith({
    String? endpoint,
    String? method,
    Map<String, String>? headers,
    int? ttlSeconds,
    Map<String, dynamic>? fallback,
  }) {
    return AsyncSource(
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      ttlSeconds: ttlSeconds ?? this.ttlSeconds,
      fallback: fallback ?? this.fallback,
    );
  }

  @override
  List<Object?> get props => [
    endpoint,
    method,
    headers,
    ttlSeconds,
    fallback,
  ];
}
