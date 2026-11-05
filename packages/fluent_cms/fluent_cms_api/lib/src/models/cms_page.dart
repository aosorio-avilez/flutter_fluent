import 'package:equatable/equatable.dart';
import 'package:fluent_cms_api/src/models/async_source.dart';
import 'package:fluent_cms_api/src/models/content_zone.dart';
import 'package:fluent_cms_api/src/models/responsive_layout_config.dart';
import 'package:flutter/foundation.dart';

/// Root document returned by the CMS service or loaded locally.
@immutable
class CmsPage extends Equatable {
  /// Creates a [CmsPage].
  const CmsPage({
    required this.pageId,
    required this.layout,
    required this.zones,
    this.schemaVersion = '1.0.0',
    this.cacheTtlSeconds,
    this.refreshable = false,
    this.preserveStateOnRefresh = true,
    this.dataContext,
    this.asyncSources,
  });

  /// Deserializes a [CmsPage] from a JSON map.
  factory CmsPage.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedDataContext;
    final rawDataContext = json['dataContext'];
    if (rawDataContext is Map) {
      parsedDataContext = <String, dynamic>{};
      for (final entry in rawDataContext.entries) {
        if (entry.key != null) {
          parsedDataContext[entry.key.toString()] = entry.value;
        }
      }
    }

    Map<String, AsyncSource>? parsedAsyncSources;
    final rawAsyncSources = json['asyncSources'];
    if (rawAsyncSources is Map) {
      parsedAsyncSources = <String, AsyncSource>{};
      for (final entry in rawAsyncSources.entries) {
        final key = entry.key?.toString();
        final value = entry.value;
        if (key != null && value is Map<String, dynamic>) {
          parsedAsyncSources[key] = AsyncSource.fromJson(value);
        }
      }
    }

    final rawLayout = json['layout'];
    final parsedLayout = rawLayout is Map<String, dynamic>
        ? ResponsiveLayoutConfig.fromJson(rawLayout)
        : const ResponsiveLayoutConfig(mobile: BreakpointLayout());

    final parsedZones = <String, ContentZone>{};
    final rawZones = json['zones'];
    if (rawZones is Map) {
      for (final entry in rawZones.entries) {
        final key = entry.key?.toString();
        final value = entry.value;
        if (key != null && value is Map<String, dynamic>) {
          parsedZones[key] = ContentZone.fromJson(value);
        }
      }
    }

    return CmsPage(
      schemaVersion: json['schemaVersion'] as String? ?? '1.0.0',
      pageId: json['pageId'] as String? ?? '',
      cacheTtlSeconds: (json['cacheTtlSeconds'] as num?)?.toInt(),
      refreshable: json['refreshable'] as bool? ?? false,
      preserveStateOnRefresh: json['preserveStateOnRefresh'] as bool? ?? true,
      dataContext: parsedDataContext,
      asyncSources: parsedAsyncSources,
      layout: parsedLayout,
      zones: parsedZones,
    );
  }

  /// Semantic version of the schema for forward-compatibility validation.
  final String schemaVersion;

  /// Unique identifier of the page (used as primary cache and telemetry key).
  final String pageId;

  /// Optional time-to-live in cache in seconds.
  final int? cacheTtlSeconds;

  /// Enables native Pull-to-Refresh gesture in the page scroll view.
  final bool refreshable;

  /// Preserves user-entered values in `CmsPageStore` during Pull-to-Refresh.
  final bool preserveStateOnRefresh;

  /// Pre-hydrated dictionary provided by the BFF (`{{data.*}}`).
  final Map<String, dynamic>? dataContext;

  /// Deferred data sources fetched on demand (`{{async.<key>.*}}`).
  final Map<String, AsyncSource>? asyncSources;

  /// Rules for distributing and ordering [zones] per breakpoint.
  final ResponsiveLayoutConfig layout;

  /// Dictionary of semantic content zones composing the page.
  final Map<String, ContentZone> zones;

  /// Serializes this [CmsPage] to a JSON map.
  Map<String, dynamic> toJson() {
    Map<String, dynamic>? serializedAsyncSources;
    final currentAsyncSources = asyncSources;
    if (currentAsyncSources != null) {
      serializedAsyncSources = <String, dynamic>{};
      for (final entry in currentAsyncSources.entries) {
        serializedAsyncSources[entry.key] = entry.value.toJson();
      }
    }

    final serializedZones = <String, dynamic>{};
    for (final entry in zones.entries) {
      serializedZones[entry.key] = entry.value.toJson();
    }

    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'pageId': pageId,
      if (cacheTtlSeconds != null) 'cacheTtlSeconds': cacheTtlSeconds,
      'refreshable': refreshable,
      'preserveStateOnRefresh': preserveStateOnRefresh,
      if (dataContext != null) 'dataContext': dataContext,
      'asyncSources': ?serializedAsyncSources,
      'layout': layout.toJson(),
      'zones': serializedZones,
    };
  }

  /// Returns a copy of this [CmsPage] with the given fields replaced.
  CmsPage copyWith({
    String? schemaVersion,
    String? pageId,
    int? cacheTtlSeconds,
    bool? refreshable,
    bool? preserveStateOnRefresh,
    Map<String, dynamic>? dataContext,
    Map<String, AsyncSource>? asyncSources,
    ResponsiveLayoutConfig? layout,
    Map<String, ContentZone>? zones,
  }) {
    return CmsPage(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      pageId: pageId ?? this.pageId,
      cacheTtlSeconds: cacheTtlSeconds ?? this.cacheTtlSeconds,
      refreshable: refreshable ?? this.refreshable,
      preserveStateOnRefresh:
          preserveStateOnRefresh ?? this.preserveStateOnRefresh,
      dataContext: dataContext ?? this.dataContext,
      asyncSources: asyncSources ?? this.asyncSources,
      layout: layout ?? this.layout,
      zones: zones ?? this.zones,
    );
  }

  @override
  List<Object?> get props => [
    schemaVersion,
    pageId,
    cacheTtlSeconds,
    refreshable,
    preserveStateOnRefresh,
    dataContext,
    asyncSources,
    layout,
    zones,
  ];
}
