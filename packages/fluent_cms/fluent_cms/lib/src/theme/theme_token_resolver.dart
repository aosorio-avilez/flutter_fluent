import 'package:flutter/material.dart';

class _AdaptiveColorPair {
  const _AdaptiveColorPair({
    required this.light,
    required this.dark,
  });

  final Color light;
  final Color dark;

  Color forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// Resolves semantic design tokens (`$surfacePrimary`, `$spacingMd`,
/// `$titleLarge`), adaptive `{light, dark}` maps, and HEX strings against the
/// active [ThemeData].
class ThemeTokenResolver {
  /// Creates a [ThemeTokenResolver] pre-populated with standard semantic
  /// design tokens.
  ThemeTokenResolver({
    Map<String, Color>? lightColors,
    Map<String, Color>? darkColors,
    Map<String, EdgeInsets>? spacingTokens,
    Map<String, double>? numericTokens,
    Map<String, TextStyle>? textStyleTokens,
  }) {
    _seedDefaultTokens();

    if (lightColors != null) {
      for (final entry in lightColors.entries) {
        final key = _normalizeTokenName(entry.key);
        final darkColor = darkColors?[entry.key] ?? entry.value;
        _colorTokens[key] = _AdaptiveColorPair(
          light: entry.value,
          dark: darkColor,
        );
      }
    }
    if (spacingTokens != null) {
      for (final entry in spacingTokens.entries) {
        _spacingTokens[_normalizeTokenName(entry.key)] = entry.value;
      }
    }
    if (numericTokens != null) {
      for (final entry in numericTokens.entries) {
        _numericTokens[_normalizeTokenName(entry.key)] = entry.value;
      }
    }
    if (textStyleTokens != null) {
      for (final entry in textStyleTokens.entries) {
        _textStyleTokens[_normalizeTokenName(entry.key)] = entry.value;
      }
    }
  }

  final Map<String, _AdaptiveColorPair> _colorTokens =
      <String, _AdaptiveColorPair>{};
  final Map<String, EdgeInsets> _spacingTokens = <String, EdgeInsets>{};
  final Map<String, double> _numericTokens = <String, double>{};
  final Map<String, TextStyle> _textStyleTokens = <String, TextStyle>{};

  void _seedDefaultTokens() {
    // Built-in adaptive color tokens
    _colorTokens[r'$surfacePrimary'] = const _AdaptiveColorPair(
      light: Color(0xFFFFFFFF),
      dark: Color(0xFF121212),
    );
    _colorTokens[r'$surfaceSecondary'] = const _AdaptiveColorPair(
      light: Color(0xFFF5F7FA),
      dark: Color(0xFF1E222A),
    );
    _colorTokens[r'$cardSurface'] = const _AdaptiveColorPair(
      light: Color(0xFFFFFFFF),
      dark: Color(0xFF1E222A),
    );
    _colorTokens[r'$textPrimary'] = const _AdaptiveColorPair(
      light: Color(0xFF101828),
      dark: Color(0xFFF9FAFB),
    );
    _colorTokens[r'$textSecondary'] = const _AdaptiveColorPair(
      light: Color(0xFF475467),
      dark: Color(0xFF98A2B3),
    );
    _colorTokens[r'$accentPrimary'] = const _AdaptiveColorPair(
      light: Color(0xFF1570EF),
      dark: Color(0xFF53B1FD),
    );
    _colorTokens[r'$success'] = const _AdaptiveColorPair(
      light: Color(0xFF039855),
      dark: Color(0xFF32D583),
    );
    _colorTokens[r'$warning'] = const _AdaptiveColorPair(
      light: Color(0xFFDC6803),
      dark: Color(0xFFFDB022),
    );
    _colorTokens[r'$error'] = const _AdaptiveColorPair(
      light: Color(0xFFD92D20),
      dark: Color(0xFFF97066),
    );

    // Built-in spacing tokens
    _spacingTokens[r'$spacingNone'] = EdgeInsets.zero;
    _spacingTokens[r'$spacingXxs'] = const EdgeInsets.all(2);
    _spacingTokens[r'$spacingXs'] = const EdgeInsets.all(4);
    _spacingTokens[r'$spacingSm'] = const EdgeInsets.all(8);
    _spacingTokens[r'$spacingMd'] = const EdgeInsets.all(16);
    _spacingTokens[r'$spacingLg'] = const EdgeInsets.all(24);
    _spacingTokens[r'$spacingXl'] = const EdgeInsets.all(32);
    _spacingTokens[r'$spacingXxl'] = const EdgeInsets.all(48);

    // Built-in numeric / radius tokens
    _numericTokens[r'$spacingNone'] = 0;
    _numericTokens[r'$spacingXxs'] = 2;
    _numericTokens[r'$spacingXs'] = 4;
    _numericTokens[r'$spacingSm'] = 8;
    _numericTokens[r'$spacingMd'] = 16;
    _numericTokens[r'$spacingLg'] = 24;
    _numericTokens[r'$spacingXl'] = 32;
    _numericTokens[r'$spacingXxl'] = 48;
    _numericTokens[r'$radiusXs'] = 4;
    _numericTokens[r'$radiusSm'] = 8;
    _numericTokens[r'$radiusMd'] = 12;
    _numericTokens[r'$radiusLg'] = 16;
    _numericTokens[r'$radiusXl'] = 24;
    _numericTokens[r'$radiusFull'] = 999;
  }

  /// Registers or overrides an adaptive color token (e.g. `'$brandPrimary'`).
  void registerColorToken(
    String token, {
    required Color light,
    Color? dark,
  }) {
    _colorTokens[_normalizeTokenName(token)] = _AdaptiveColorPair(
      light: light,
      dark: dark ?? light,
    );
  }

  /// Registers or overrides an [EdgeInsets] spacing token
  /// (e.g. `'$spacingMd'`).
  void registerSpacingToken(String token, EdgeInsets spacing) {
    _spacingTokens[_normalizeTokenName(token)] = spacing;
  }

  /// Registers or overrides a numeric token (e.g. `'$radiusMd'`).
  void registerNumericToken(String token, double value) {
    _numericTokens[_normalizeTokenName(token)] = value;
  }

  /// Registers or overrides a [TextStyle] token (e.g. `'$heroTitle'`).
  void registerTextStyleToken(String token, TextStyle style) {
    _textStyleTokens[_normalizeTokenName(token)] = style;
  }

  /// Universal token lookup function compatible with `ThemeTokenLookup` in
  /// `CmsProps`.
  Object? resolveToken(BuildContext? context, String token) {
    final normalized = _normalizeTokenName(token);
    final theme = context != null ? Theme.of(context) : null;
    final brightness = theme?.brightness ?? Brightness.light;

    final colorPair = _colorTokens[normalized];
    if (colorPair != null) {
      return colorPair.forBrightness(brightness);
    }

    if (theme != null) {
      final schemeColor = _resolveColorSchemeToken(
        theme.colorScheme,
        normalized,
      );
      if (schemeColor != null) {
        return schemeColor;
      }
    }

    final spacing = _spacingTokens[normalized];
    if (spacing != null) {
      return spacing;
    }

    final numeric = _numericTokens[normalized];
    if (numeric != null) {
      return numeric;
    }

    final customTextStyle = _textStyleTokens[normalized];
    if (customTextStyle != null) {
      return customTextStyle;
    }

    if (theme != null) {
      return _resolveTextThemeToken(theme.textTheme, normalized);
    }
    return null;
  }

  /// Resolves a [Color] from a `$token`, `{light, dark}` map, HEX string, or
  /// [Color] instance.
  Color? resolveColor(
    BuildContext context,
    Object? rawValue, {
    Color? defaultValue,
  }) {
    if (rawValue == null) return defaultValue;
    if (rawValue is Color) return rawValue;

    if (rawValue is Map) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final branch = isDark
          ? (rawValue['dark'] ?? rawValue['light'])
          : (rawValue['light'] ?? rawValue['dark']);
      return resolveColor(context, branch, defaultValue: defaultValue);
    }

    if (rawValue is String) {
      final trimmed = rawValue.trim();
      if (trimmed.isEmpty) return defaultValue;
      if (trimmed.startsWith(r'$')) {
        final tokenResolved = resolveToken(context, trimmed);
        if (tokenResolved is Color) return tokenResolved;
        if (tokenResolved is String && tokenResolved != trimmed) {
          return _parseHexColor(tokenResolved) ?? defaultValue;
        }
        return defaultValue;
      }
      return _parseHexColor(trimmed) ?? defaultValue;
    }

    return defaultValue;
  }

  /// Resolves [EdgeInsets] from a `$spacing*` token, number, or directional
  /// map.
  EdgeInsets? resolveEdgeInsets(
    Object? rawValue, {
    BuildContext? context,
    EdgeInsets? defaultValue,
  }) {
    if (rawValue == null) return defaultValue;
    if (rawValue is EdgeInsets) return rawValue;
    if (rawValue is num) return EdgeInsets.all(rawValue.toDouble());

    if (rawValue is String) {
      final trimmed = rawValue.trim();
      if (trimmed.isEmpty) return defaultValue;
      final normalized = _normalizeTokenName(trimmed);
      final direct = _spacingTokens[normalized];
      if (direct != null) return direct;

      final numeric = _numericTokens[normalized];
      if (numeric != null) return EdgeInsets.all(numeric);

      if (context != null && trimmed.startsWith(r'$')) {
        final resolved = resolveToken(context, trimmed);
        if (resolved is EdgeInsets) return resolved;
        if (resolved is num) return EdgeInsets.all(resolved.toDouble());
      }

      final parsed = double.tryParse(trimmed);
      if (parsed != null) return EdgeInsets.all(parsed);
      return defaultValue;
    }

    if (rawValue is Map) {
      final all = _toDouble(rawValue['all'], context: context);
      if (all != null) return EdgeInsets.all(all);

      final horizontal = _toDouble(rawValue['horizontal'], context: context);
      final vertical = _toDouble(rawValue['vertical'], context: context);
      if (horizontal != null || vertical != null) {
        return EdgeInsets.symmetric(
          horizontal: horizontal ?? 0,
          vertical: vertical ?? 0,
        );
      }

      final left = _toDouble(rawValue['left'], context: context) ?? 0;
      final top = _toDouble(rawValue['top'], context: context) ?? 0;
      final right = _toDouble(rawValue['right'], context: context) ?? 0;
      final bottom = _toDouble(rawValue['bottom'], context: context) ?? 0;
      return EdgeInsets.fromLTRB(left, top, right, bottom);
    }

    return defaultValue;
  }

  /// Resolves a [BorderRadius] from a `$radius*` token or numeric value.
  BorderRadius? resolveBorderRadius(
    Object? rawValue, {
    BuildContext? context,
    BorderRadius? defaultValue,
  }) {
    if (rawValue == null) return defaultValue;
    if (rawValue is BorderRadius) return rawValue;
    final radius = _toDouble(rawValue, context: context);
    if (radius != null) {
      return BorderRadius.circular(radius);
    }
    return defaultValue;
  }

  /// Resolves a [TextStyle] from a `$token` (e.g. `'$titleLarge'`,
  /// `'$bodyMedium'`).
  TextStyle? resolveTextStyle(
    BuildContext context,
    Object? rawValue, {
    TextStyle? defaultValue,
  }) {
    if (rawValue == null) return defaultValue;
    if (rawValue is TextStyle) return rawValue;
    if (rawValue is String && rawValue.isNotEmpty) {
      final resolved = resolveToken(context, rawValue);
      if (resolved is TextStyle) return resolved;
    }
    return defaultValue;
  }

  Color? _resolveColorSchemeToken(ColorScheme scheme, String normalized) {
    return switch (normalized) {
      r'$primary' => scheme.primary,
      r'$onPrimary' => scheme.onPrimary,
      r'$secondary' => scheme.secondary,
      r'$onSecondary' => scheme.onSecondary,
      r'$surface' => scheme.surface,
      r'$onSurface' => scheme.onSurface,
      r'$outline' => scheme.outline,
      _ => null,
    };
  }

  TextStyle? _resolveTextThemeToken(TextTheme textTheme, String normalized) {
    return switch (normalized) {
      r'$displayLarge' => textTheme.displayLarge,
      r'$displayMedium' => textTheme.displayMedium,
      r'$displaySmall' => textTheme.displaySmall,
      r'$headlineLarge' => textTheme.headlineLarge,
      r'$headlineMedium' => textTheme.headlineMedium,
      r'$headlineSmall' => textTheme.headlineSmall,
      r'$titleLarge' => textTheme.titleLarge,
      r'$titleMedium' => textTheme.titleMedium,
      r'$titleSmall' => textTheme.titleSmall,
      r'$bodyLarge' => textTheme.bodyLarge,
      r'$bodyMedium' => textTheme.bodyMedium,
      r'$bodySmall' => textTheme.bodySmall,
      r'$labelLarge' => textTheme.labelLarge,
      r'$labelMedium' => textTheme.labelMedium,
      r'$labelSmall' => textTheme.labelSmall,
      _ => null,
    };
  }

  double? _toDouble(Object? raw, {BuildContext? context}) {
    if (raw is num) return raw.toDouble();
    if (raw is String && raw.isNotEmpty) {
      final trimmed = raw.trim();
      final normalized = _normalizeTokenName(trimmed);
      final numeric = _numericTokens[normalized];
      if (numeric != null) return numeric;
      if (context != null && trimmed.startsWith(r'$')) {
        final resolved = resolveToken(context, trimmed);
        if (resolved is num) return resolved.toDouble();
      }
      return double.tryParse(trimmed);
    }
    return null;
  }

  Color? _parseHexColor(String input) {
    var hex = input.trim();
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    } else if (hex.startsWith('0x') || hex.startsWith('0X')) {
      hex = hex.substring(2);
    } else {
      return null;
    }

    if (hex.length == 3) {
      final r = hex[0];
      final g = hex[1];
      final b = hex[2];
      hex = 'FF$r$r$g$g$b$b';
    } else if (hex.length == 6) {
      hex = 'FF$hex';
    } else if (hex.length != 8) {
      return null;
    }

    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
  }

  String _normalizeTokenName(String token) {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.startsWith(r'$') ? trimmed : '\$$trimmed';
  }
}
