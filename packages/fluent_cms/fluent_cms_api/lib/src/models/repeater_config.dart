import 'package:equatable/equatable.dart';
import 'package:fluent_cms_api/src/models/module_node.dart';
import 'package:fluent_cms_api/src/models/responsive_layout_config.dart';
import 'package:flutter/foundation.dart';

/// Pagination configuration for a `cms_repeater` module.
@immutable
class PaginationConfig extends Equatable {
  /// Creates a [PaginationConfig].
  const PaginationConfig({
    required this.endpoint,
    this.pageParam = 'page',
    this.pageSize = 20,
  });

  /// Deserializes a [PaginationConfig] from a JSON map.
  factory PaginationConfig.fromJson(Map<String, dynamic> json) {
    return PaginationConfig(
      endpoint: json['endpoint'] as String? ?? '',
      pageParam: json['pageParam'] as String? ?? 'page',
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
    );
  }

  /// Endpoint queried when loading subsequent pages.
  final String endpoint;

  /// Query parameter name for the page number. Defaults to `'page'`.
  final String pageParam;

  /// Number of items requested per page. Defaults to `20`.
  final int pageSize;

  /// Serializes this [PaginationConfig] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'endpoint': endpoint,
      'pageParam': pageParam,
      'pageSize': pageSize,
    };
  }

  /// Returns a copy of this [PaginationConfig] with the given fields replaced.
  PaginationConfig copyWith({
    String? endpoint,
    String? pageParam,
    int? pageSize,
  }) {
    return PaginationConfig(
      endpoint: endpoint ?? this.endpoint,
      pageParam: pageParam ?? this.pageParam,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [endpoint, pageParam, pageSize];
}

/// Configuration for the structural `cms_repeater` module.
@immutable
class RepeaterConfig extends Equatable {
  /// Creates a [RepeaterConfig].
  const RepeaterConfig({
    required this.itemsDataPath,
    required this.itemTemplate,
    this.layoutMode = 'list',
    this.crossAxisCount = 1,
    this.pagination,
  });

  /// Deserializes a [RepeaterConfig] from a `cms_repeater` `props` map.
  factory RepeaterConfig.fromJson(Map<String, dynamic> json) {
    PaginationConfig? parsedPagination;
    final rawPagination = json['pagination'];
    if (rawPagination is Map<String, dynamic>) {
      parsedPagination = PaginationConfig.fromJson(rawPagination);
    }

    final rawTemplate = json['itemTemplate'];
    final parsedTemplate = rawTemplate is Map<String, dynamic>
        ? ModuleNode.fromJson(rawTemplate)
        : const ModuleNode(id: '', type: '');

    return RepeaterConfig(
      layoutMode: json['layoutMode'] as String? ?? 'list',
      crossAxisCount: json['crossAxisCount'] ?? 1,
      itemsDataPath: json['itemsDataPath'] as String? ?? '',
      pagination: parsedPagination,
      itemTemplate: parsedTemplate,
    );
  }

  /// Rendering mode: `'list'` (`SliverList.builder`) or `'grid'`
  /// (`SliverGrid.builder`).
  final String layoutMode;

  /// Number of grid columns as an `int` or a breakpoint map
  /// (e.g. `{'mobile': 2, 'desktop': 4}`).
  final Object? crossAxisCount;

  /// Dot-separated path to the initial items list
  /// (e.g. `'data.featuredProducts'`).
  final String itemsDataPath;

  /// Optional incremental pagination configuration.
  final PaginationConfig? pagination;

  /// Template [ModuleNode] instantiated for each item with `{{item.*}}` and
  /// `{{index}}`.
  final ModuleNode itemTemplate;

  /// Whether this repeater renders as a grid.
  bool get isGrid => layoutMode == 'grid';

  /// Resolves the cross-axis column count for [breakpoint].
  int resolveCrossAxisCount(
    CmsBreakpoint breakpoint, {
    int defaultCount = 1,
  }) {
    final raw = crossAxisCount;
    if (raw is num) {
      final count = raw.toInt();
      return count > 0 ? count : defaultCount;
    }
    if (raw is Map) {
      final exact = raw[breakpoint.name];
      if (exact is num && exact.toInt() > 0) {
        return exact.toInt();
      }
      if (breakpoint == CmsBreakpoint.desktop) {
        final tabletVal = raw[CmsBreakpoint.tablet.name];
        if (tabletVal is num && tabletVal.toInt() > 0) {
          return tabletVal.toInt();
        }
      }
      final mobileVal = raw[CmsBreakpoint.mobile.name];
      if (mobileVal is num && mobileVal.toInt() > 0) {
        return mobileVal.toInt();
      }
    }
    return defaultCount;
  }

  /// Serializes this [RepeaterConfig] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'layoutMode': layoutMode,
      'crossAxisCount': crossAxisCount,
      'itemsDataPath': itemsDataPath,
      if (pagination != null) 'pagination': pagination!.toJson(),
      'itemTemplate': itemTemplate.toJson(),
    };
  }

  /// Returns a copy of this [RepeaterConfig] with the given fields replaced.
  RepeaterConfig copyWith({
    String? layoutMode,
    Object? crossAxisCount,
    String? itemsDataPath,
    PaginationConfig? pagination,
    ModuleNode? itemTemplate,
  }) {
    return RepeaterConfig(
      layoutMode: layoutMode ?? this.layoutMode,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      itemsDataPath: itemsDataPath ?? this.itemsDataPath,
      pagination: pagination ?? this.pagination,
      itemTemplate: itemTemplate ?? this.itemTemplate,
    );
  }

  @override
  List<Object?> get props => [
    layoutMode,
    crossAxisCount,
    itemsDataPath,
    pagination,
    itemTemplate,
  ];
}
