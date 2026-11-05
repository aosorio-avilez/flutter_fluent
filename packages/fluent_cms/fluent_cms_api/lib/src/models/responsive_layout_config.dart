import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Screen size breakpoints supported by the omnichannel layout engine.
enum CmsBreakpoint {
  /// Mobile screens (`< 600px` by default).
  mobile,

  /// Tablet screens (`600px` to `1024px` by default).
  tablet,

  /// Desktop / Web screens (`> 1024px` by default).
  desktop;

  /// Resolves a [CmsBreakpoint] from a viewport [width].
  static CmsBreakpoint fromWidth(
    double width, {
    double mobileMaxWidth = 600,
    double tabletMaxWidth = 1024,
  }) {
    if (width < mobileMaxWidth) {
      return CmsBreakpoint.mobile;
    }
    if (width <= tabletMaxWidth) {
      return CmsBreakpoint.tablet;
    }
    return CmsBreakpoint.desktop;
  }
}

/// Defines a column span and its assigned zones in a 12-column grid layout.
@immutable
class ColumnSpanConfig extends Equatable {
  /// Creates a [ColumnSpanConfig].
  const ColumnSpanConfig({
    required this.span,
    required this.zones,
  });

  /// Deserializes a [ColumnSpanConfig] from a JSON map.
  factory ColumnSpanConfig.fromJson(Map<String, dynamic> json) {
    final rawSpan = (json['span'] as num?)?.toInt() ?? 12;
    final clampedSpan = rawSpan < 1 ? 1 : (rawSpan > 12 ? 12 : rawSpan);

    final parsedZones = <String>[];
    final rawZones = json['zones'];
    if (rawZones is List) {
      for (var i = 0; i < rawZones.length; i++) {
        final item = rawZones[i];
        if (item is String) {
          parsedZones.add(item);
        }
      }
    }

    return ColumnSpanConfig(
      span: clampedSpan,
      zones: parsedZones,
    );
  }

  /// Column span between 1 and 12.
  final int span;

  /// Ordered list of zone keys rendered inside this column.
  final List<String> zones;

  /// Serializes this [ColumnSpanConfig] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'span': span,
      'zones': zones,
    };
  }

  /// Returns a copy of this [ColumnSpanConfig] with the given fields replaced.
  ColumnSpanConfig copyWith({
    int? span,
    List<String>? zones,
  }) {
    return ColumnSpanConfig(
      span: span ?? this.span,
      zones: zones ?? this.zones,
    );
  }

  @override
  List<Object?> get props => [span, zones];
}

/// Defines how `ContentZones` are arranged for a specific breakpoint.
@immutable
class BreakpointLayout extends Equatable {
  /// Creates a [BreakpointLayout].
  const BreakpointLayout({
    this.type = 'single_column',
    this.zonesOrder,
    this.columns,
  });

  /// Deserializes a [BreakpointLayout] from a JSON map.
  factory BreakpointLayout.fromJson(Map<String, dynamic> json) {
    List<String>? parsedZonesOrder;
    final rawZonesOrder = json['zonesOrder'];
    if (rawZonesOrder is List) {
      parsedZonesOrder = <String>[];
      for (var i = 0; i < rawZonesOrder.length; i++) {
        final item = rawZonesOrder[i];
        if (item is String) {
          parsedZonesOrder.add(item);
        }
      }
    }

    List<ColumnSpanConfig>? parsedColumns;
    final rawColumns = json['columns'];
    if (rawColumns is List) {
      parsedColumns = <ColumnSpanConfig>[];
      for (var i = 0; i < rawColumns.length; i++) {
        final item = rawColumns[i];
        if (item is Map<String, dynamic>) {
          parsedColumns.add(ColumnSpanConfig.fromJson(item));
        } else if (item is Map) {
          final map = <String, dynamic>{};
          for (final entry in item.entries) {
            if (entry.key != null) {
              map[entry.key.toString()] = entry.value;
            }
          }
          parsedColumns.add(ColumnSpanConfig.fromJson(map));
        }
      }
    }

    return BreakpointLayout(
      type: json['type'] as String? ?? 'single_column',
      zonesOrder: parsedZonesOrder,
      columns: parsedColumns,
    );
  }

  /// Layout distribution mode: `'single_column'` or `'grid_12_cols'`.
  final String type;

  /// Ordered list of zone keys when [type] is `'single_column'`.
  final List<String>? zonesOrder;

  /// Column definitions when [type] is `'grid_12_cols'`.
  final List<ColumnSpanConfig>? columns;

  /// Whether this breakpoint uses a 12-column grid layout.
  bool get isGrid => type == 'grid_12_cols';

  /// Serializes this [BreakpointLayout] to a JSON map.
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>>? serializedColumns;
    final currentColumns = columns;
    if (currentColumns != null) {
      serializedColumns = <Map<String, dynamic>>[];
      for (var i = 0; i < currentColumns.length; i++) {
        serializedColumns.add(currentColumns[i].toJson());
      }
    }

    return <String, dynamic>{
      'type': type,
      if (zonesOrder != null) 'zonesOrder': zonesOrder,
      'columns': ?serializedColumns,
    };
  }

  /// Returns a copy of this [BreakpointLayout] with the given fields replaced.
  BreakpointLayout copyWith({
    String? type,
    List<String>? zonesOrder,
    List<ColumnSpanConfig>? columns,
  }) {
    return BreakpointLayout(
      type: type ?? this.type,
      zonesOrder: zonesOrder ?? this.zonesOrder,
      columns: columns ?? this.columns,
    );
  }

  @override
  List<Object?> get props => [type, zonesOrder, columns];
}

/// Defines how `ContentZones` are arranged across mobile, tablet, and desktop.
@immutable
class ResponsiveLayoutConfig extends Equatable {
  /// Creates a [ResponsiveLayoutConfig].
  const ResponsiveLayoutConfig({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Deserializes a [ResponsiveLayoutConfig] from a JSON map.
  factory ResponsiveLayoutConfig.fromJson(Map<String, dynamic> json) {
    final rawMobile = json['mobile'];
    final mobileLayout = rawMobile is Map<String, dynamic>
        ? BreakpointLayout.fromJson(rawMobile)
        : const BreakpointLayout();

    BreakpointLayout? tabletLayout;
    final rawTablet = json['tablet'];
    if (rawTablet is Map<String, dynamic>) {
      tabletLayout = BreakpointLayout.fromJson(rawTablet);
    }

    BreakpointLayout? desktopLayout;
    final rawDesktop = json['desktop'];
    if (rawDesktop is Map<String, dynamic>) {
      desktopLayout = BreakpointLayout.fromJson(rawDesktop);
    }

    return ResponsiveLayoutConfig(
      mobile: mobileLayout,
      tablet: tabletLayout,
      desktop: desktopLayout,
    );
  }

  /// Mandatory configuration for mobile screens (`< 600px`) and fallback.
  final BreakpointLayout mobile;

  /// Optional configuration for tablet screens (`600px` to `1024px`).
  final BreakpointLayout? tablet;

  /// Optional configuration for desktop screens (`> 1024px`).
  final BreakpointLayout? desktop;

  /// Resolves the active [BreakpointLayout] for [breakpoint] using fallback
  /// inheritance.
  BreakpointLayout resolveForBreakpoint(CmsBreakpoint breakpoint) {
    switch (breakpoint) {
      case CmsBreakpoint.mobile:
        return mobile;
      case CmsBreakpoint.tablet:
        return tablet ?? mobile;
      case CmsBreakpoint.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Serializes this [ResponsiveLayoutConfig] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mobile': mobile.toJson(),
      if (tablet != null) 'tablet': tablet!.toJson(),
      if (desktop != null) 'desktop': desktop!.toJson(),
    };
  }

  /// Returns a copy of this [ResponsiveLayoutConfig] with the given fields
  /// replaced.
  ResponsiveLayoutConfig copyWith({
    BreakpointLayout? mobile,
    BreakpointLayout? tablet,
    BreakpointLayout? desktop,
  }) {
    return ResponsiveLayoutConfig(
      mobile: mobile ?? this.mobile,
      tablet: tablet ?? this.tablet,
      desktop: desktop ?? this.desktop,
    );
  }

  @override
  List<Object?> get props => [mobile, tablet, desktop];
}
