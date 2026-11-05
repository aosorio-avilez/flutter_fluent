import 'package:equatable/equatable.dart';
import 'package:fluent_cms_api/src/models/responsive_layout_config.dart';
import 'package:fluent_cms_api/src/state/cms_page_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Callback used to resolve a semantic design token (e.g. `'$surfacePrimary'`).
typedef ThemeTokenLookup =
    Object? Function(
      BuildContext? context,
      String token,
    );

/// Type-safe, null-safe property reader for hydrated module properties.
@immutable
class CmsProps extends Equatable {
  /// Creates a [CmsProps] wrapper around [raw].
  const CmsProps(
    this.raw, {
    this.tokenLookup,
  });

  /// Empty [CmsProps] instance.
  static const CmsProps empty = CmsProps(<String, dynamic>{});

  /// Underlying hydrated properties map.
  final Map<String, dynamic> raw;

  /// Optional semantic token lookup function.
  final ThemeTokenLookup? tokenLookup;

  /// Returns the raw value for [key].
  Object? operator [](String key) => raw[key];

  /// Safely reads a [String] property for [key], returning [defaultValue] when
  /// absent or null.
  String getString(String key, {String defaultValue = ''}) {
    final val = raw[key];
    if (val == null) return defaultValue;
    if (val is String) return val;
    return val.toString();
  }

  /// Safely reads an [int] property for [key], returning [defaultValue] when
  /// absent or unparseable.
  int getInt(String key, {int defaultValue = 0}) {
    final val = raw[key];
    if (val == null) return defaultValue;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  /// Safely reads a [double] property for [key], returning [defaultValue] when
  /// absent or unparseable.
  double getDouble(String key, {double defaultValue = 0.0}) {
    final val = raw[key];
    if (val == null) return defaultValue;
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  /// Safely reads a [bool] property for [key], returning [defaultValue] when
  /// absent or unparseable.
  bool getBool(String key, {bool defaultValue = false}) {
    final val = raw[key];
    if (val == null) return defaultValue;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final lower = val.toLowerCase().trim();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return defaultValue;
  }

  /// Resolves a [Color] for [key] supporting:
  /// 1. Semantic tokens (`'$surfacePrimary'`),
  /// 2. Adaptive brightness maps (`{'light': '#FFFFFF', 'dark': '#121212'}`),
  /// 3. Direct HEX strings (`'#FF5733'` or `'#80FF5733'`).
  Color? getColor(
    BuildContext context,
    String key, {
    Color? defaultValue,
  }) {
    final val = raw[key];
    if (val == null) return defaultValue;
    return _resolveColorValue(context, val) ?? defaultValue;
  }

  Color? _resolveColorValue(BuildContext context, Object? value) {
    if (value is Color) return value;
    if (value is int) return Color(value);

    if (value is Map) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final selected = isDark
          ? (value['dark'] ?? value['light'])
          : (value['light'] ?? value['dark']);
      if (selected != null) {
        return _resolveColorValue(context, selected);
      }
      return null;
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      if (trimmed.startsWith(r'$')) {
        final lookup = tokenLookup;
        if (lookup != null) {
          final resolved = lookup(context, trimmed);
          if (resolved != null && resolved != trimmed) {
            return _resolveColorValue(context, resolved);
          }
        }
        return _resolveBuiltInColorToken(context, trimmed);
      }
      return parseHexColor(trimmed);
    }

    return null;
  }

  static Color? _resolveBuiltInColorToken(BuildContext context, String token) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (token) {
      case r'$primary':
        return colorScheme.primary;
      case r'$secondary':
        return colorScheme.secondary;
      case r'$surface':
      case r'$surfacePrimary':
        return colorScheme.surface;
      case r'$surfaceSecondary':
        return colorScheme.surfaceContainerHighest;
      case r'$error':
        return colorScheme.error;
      default:
        return null;
    }
  }

  /// Parses a `#RRGGBB` or `#AARRGGBB` hexadecimal color string.
  static Color? parseHexColor(String hexString) {
    var cleaned = hexString.trim();
    if (cleaned.startsWith('#')) {
      cleaned = cleaned.substring(1);
    } else if (cleaned.startsWith('0x') || cleaned.startsWith('0X')) {
      cleaned = cleaned.substring(2);
    }
    if (cleaned.length == 6) {
      cleaned = 'FF$cleaned';
    }
    if (cleaned.length != 8) {
      return null;
    }
    final intVal = int.tryParse(cleaned, radix: 16);
    if (intVal == null) return null;
    return Color(intVal);
  }

  /// Resolves [EdgeInsets] for [key] supporting semantic tokens
  /// (`'$spacingMd'`), numeric values, or maps.
  EdgeInsets? getEdgeInsets(
    String key, {
    EdgeInsets? defaultValue,
    BuildContext? context,
  }) {
    final val = raw[key];
    if (val == null) return defaultValue;
    return resolveEdgeInsetsValue(
          val,
          context: context,
          tokenLookup: tokenLookup,
        ) ??
        defaultValue;
  }

  /// Resolves an arbitrary [value] into [EdgeInsets].
  static EdgeInsets? resolveEdgeInsetsValue(
    Object? value, {
    BuildContext? context,
    ThemeTokenLookup? tokenLookup,
  }) {
    if (value is EdgeInsets) return value;
    if (value is num) return EdgeInsets.all(value.toDouble());

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.startsWith(r'$')) {
        if (tokenLookup != null) {
          final resolved = tokenLookup(context, trimmed);
          if (resolved != null && resolved != trimmed) {
            return resolveEdgeInsetsValue(
              resolved,
              context: context,
              tokenLookup: tokenLookup,
            );
          }
        }
        return _resolveBuiltInSpacingToken(trimmed);
      }
      final parsed = double.tryParse(trimmed);
      if (parsed != null) return EdgeInsets.all(parsed);
      return null;
    }

    if (value is Map) {
      final all = (value['all'] as num?)?.toDouble();
      if (all != null) return EdgeInsets.all(all);

      final horizontal = (value['horizontal'] as num?)?.toDouble() ?? 0.0;
      final vertical = (value['vertical'] as num?)?.toDouble() ?? 0.0;
      final left = (value['left'] as num?)?.toDouble() ?? horizontal;
      final right = (value['right'] as num?)?.toDouble() ?? horizontal;
      final top = (value['top'] as num?)?.toDouble() ?? vertical;
      final bottom = (value['bottom'] as num?)?.toDouble() ?? vertical;
      return EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );
    }

    return null;
  }

  static EdgeInsets? _resolveBuiltInSpacingToken(String token) {
    switch (token) {
      case r'$spacingXs':
        return const EdgeInsets.all(4);
      case r'$spacingSm':
        return const EdgeInsets.all(8);
      case r'$spacingMd':
        return const EdgeInsets.all(16);
      case r'$spacingLg':
        return const EdgeInsets.all(24);
      case r'$spacingXl':
        return const EdgeInsets.all(32);
      default:
        return null;
    }
  }

  /// Safely reads a typed [List<T>] for [key] using a standard loop without
  /// closure allocations.
  List<T> getList<T>(String key, {List<T> defaultValue = const []}) {
    final val = raw[key];
    if (val is! List) return defaultValue;
    if (val is List<T>) return val;

    final result = <T>[];
    for (var i = 0; i < val.length; i++) {
      final element = val[i];
      if (element is T) {
        result.add(element);
      }
    }
    return result;
  }

  /// Safely reads a [Map<String, dynamic>] for [key] using a standard loop.
  Map<String, dynamic> getMap(
    String key, {
    Map<String, dynamic> defaultValue = const <String, dynamic>{},
  }) {
    final val = raw[key];
    if (val is Map<String, dynamic>) return val;
    if (val is Map) {
      final result = <String, dynamic>{};
      for (final entry in val.entries) {
        if (entry.key != null) {
          result[entry.key.toString()] = entry.value;
        }
      }
      return result;
    }
    return defaultValue;
  }

  @override
  List<Object?> get props => [raw, tokenLookup];
}

/// Execution context delivered to `SduiModule.build`.
abstract class CmsModuleContext {
  /// Creates a [CmsModuleContext].
  const CmsModuleContext();

  /// Unique instance identifier of the module.
  String get moduleId;

  /// Registered module type key.
  String get moduleType;

  /// Identifier of the containing `ContentZone`.
  String get zoneId;

  /// Active screen breakpoint.
  CmsBreakpoint get breakpoint;

  /// Typed, hydrated properties wrapper.
  CmsProps get props;

  /// Reactive page store for two-way bindings and validation.
  CmsPageStore get pageStore;

  /// Whether an asynchronous action triggered by this module is running.
  bool get isActionRunning;

  /// Listenable emitting changes to [isActionRunning].
  ValueListenable<bool> get actionRunningListenable;

  /// Triggers a declarative action configured on this module (e.g. `'onTap'`).
  Future<void> triggerAction(
    String trigger, {
    Map<String, dynamic>? extraPayload,
  });

  /// Convenience delegator to [CmsProps.getString].
  String getString(String key, {String defaultValue = ''}) =>
      props.getString(key, defaultValue: defaultValue);

  /// Convenience delegator to [CmsProps.getInt].
  int getInt(String key, {int defaultValue = 0}) =>
      props.getInt(key, defaultValue: defaultValue);

  /// Convenience delegator to [CmsProps.getDouble].
  double getDouble(String key, {double defaultValue = 0.0}) =>
      props.getDouble(key, defaultValue: defaultValue);

  /// Convenience delegator to [CmsProps.getBool].
  bool getBool(String key, {bool defaultValue = false}) =>
      props.getBool(key, defaultValue: defaultValue);

  /// Convenience delegator to [CmsProps.getColor].
  Color? getColor(
    BuildContext context,
    String key, {
    Color? defaultValue,
  }) => props.getColor(context, key, defaultValue: defaultValue);

  /// Convenience delegator to [CmsProps.getEdgeInsets].
  EdgeInsets? getEdgeInsets(
    String key, {
    EdgeInsets? defaultValue,
    BuildContext? context,
  }) => props.getEdgeInsets(
    key,
    defaultValue: defaultValue,
    context: context,
  );

  /// Convenience delegator to [CmsProps.getList].
  List<T> getList<T>(String key, {List<T> defaultValue = const []}) =>
      props.getList<T>(key, defaultValue: defaultValue);

  /// Convenience delegator to [CmsProps.getMap].
  Map<String, dynamic> getMap(
    String key, {
    Map<String, dynamic> defaultValue = const <String, dynamic>{},
  }) => props.getMap(key, defaultValue: defaultValue);
}
