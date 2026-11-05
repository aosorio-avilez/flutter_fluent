import 'package:fluent_cms/src/hydration/pipe_transformer_registry.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter/widgets.dart';

/// Single-pass `{{...}}` expression and pipe resolver (`O(M)` complexity).
///
/// Strictly adheres to `BOLT_JOURNAL.md`:
/// - Uses a single precompiled [RegExp] with `replaceAllMapped`.
/// - Applies `O(1)` Fast-Path (`!input.contains('{{')`) returning the original
///   reference without allocation when no placeholders exist.
/// - Uses indexed `for` and `for-in` loops without closure allocations in hot
///   paths.
class SinglePassExpressionResolver {
  /// Creates a [SinglePassExpressionResolver].
  const SinglePassExpressionResolver({
    required this.pipeRegistry,
  });

  /// Single precompiled regular expression matching `{{expression}}`.
  static final RegExp _tokenRegExp = RegExp(r'\{\{([^}]+)\}\}');

  /// Registry used to evaluate `| pipe:arg` segments.
  final PipeTransformerRegistry pipeRegistry;

  /// Resolves all `{{...}}` placeholders in [input] in a single pass.
  @pragma('vm:prefer-inline')
  String resolveString(
    String input,
    HydrationScope scope, {
    BuildContext? context,
  }) {
    if (!input.contains('{{')) {
      return input;
    }

    return input.replaceAllMapped(_tokenRegExp, (match) {
      final rawExpression = match.group(1);
      if (rawExpression == null || rawExpression.isEmpty) {
        return '';
      }
      final evaluated = evaluateExpression(
        rawExpression,
        scope,
        context: context,
      );
      if (evaluated == null) {
        return '';
      }
      return evaluated.toString();
    });
  }

  /// Resolves an arbitrary [value] (`String`, `Map`, `List`, or primitive).
  ///
  /// When [value] is a [String] containing a single standalone `{{...}}`
  /// placeholder, preserves the underlying resolved type (`bool`, `num`,
  /// `List`, `Map`, `String`).
  Object? resolveValue(
    Object? value,
    HydrationScope scope, {
    BuildContext? context,
  }) {
    if (value is String) {
      if (!value.contains('{{')) {
        return value;
      }

      final trimmed = value.trim();
      if (_isSingleStandaloneToken(trimmed)) {
        final inner = trimmed.substring(2, trimmed.length - 2);
        final evaluated = evaluateExpression(
          inner,
          scope,
          context: context,
        );
        return evaluated ?? '';
      }

      return resolveString(value, scope, context: context);
    }

    if (value is Map<String, dynamic>) {
      return resolveMap(value, scope, context: context);
    }

    if (value is Map) {
      final normalized = <String, dynamic>{};
      for (final entry in value.entries) {
        if (entry.key != null) {
          normalized[entry.key.toString()] = resolveValue(
            entry.value,
            scope,
            context: context,
          );
        }
      }
      return normalized;
    }

    if (value is List) {
      return resolveList(value, scope, context: context);
    }

    return value;
  }

  /// Resolves all entries in [props] without closure allocations.
  ///
  /// Returns the original [props] reference in `O(N)` if no nested value
  /// required hydration.
  Map<String, dynamic> resolveMap(
    Map<String, dynamic> props,
    HydrationScope scope, {
    BuildContext? context,
  }) {
    if (props.isEmpty) return props;

    Map<String, dynamic>? mutated;
    for (final entry in props.entries) {
      final originalVal = entry.value;
      final resolvedVal = resolveValue(
        originalVal,
        scope,
        context: context,
      );
      if (!identical(resolvedVal, originalVal)) {
        mutated ??= Map<String, dynamic>.of(props);
        mutated[entry.key] = resolvedVal;
      }
    }
    return mutated ?? props;
  }

  /// Resolves all elements in [items] without closure allocations.
  List<Object?> resolveList(
    List<Object?> items,
    HydrationScope scope, {
    BuildContext? context,
  }) {
    if (items.isEmpty) return items;

    List<Object?>? mutated;
    final len = items.length;
    for (var i = 0; i < len; i++) {
      final originalVal = items[i];
      final resolvedVal = resolveValue(
        originalVal,
        scope,
        context: context,
      );
      if (!identical(resolvedVal, originalVal)) {
        mutated ??= List<Object?>.of(items);
        mutated[i] = resolvedVal;
      }
    }
    return mutated ?? items;
  }

  /// Evaluates the inner expression of a `{{path | pipe1:arg | pipe2}}` token.
  Object? evaluateExpression(
    String rawExpression,
    HydrationScope scope, {
    BuildContext? context,
  }) {
    final trimmed = rawExpression.trim();
    if (trimmed.isEmpty) return null;

    final firstPipeIndex = trimmed.indexOf('|');
    if (firstPipeIndex == -1) {
      return resolvePath(trimmed, scope);
    }

    final pathPart = trimmed.substring(0, firstPipeIndex).trim();
    var currentValue = resolvePath(pathPart, scope);

    final segments = trimmed.substring(firstPipeIndex + 1).split('|');
    final len = segments.length;
    for (var i = 0; i < len; i++) {
      currentValue = pipeRegistry.applyPipeSegment(
        segments[i],
        currentValue,
        context: context,
      );
    }
    return currentValue;
  }

  /// Resolves a dot-separated scope path (`data.*`, `client.*`, `state.*`,
  /// `async.*`, `env.features.*`, `item.*`, `index`) against [scope].
  Object? resolvePath(String rawPath, HydrationScope scope) {
    final path = rawPath.trim();
    if (path.isEmpty) return null;

    if (path == 'index') {
      return scope.itemIndex;
    }
    if (path == 'item') {
      return scope.itemData;
    }

    if (path.startsWith('data.')) {
      return _navigateNested(scope.dataContext, path.substring(5));
    }
    if (path.startsWith('client.')) {
      return _navigateNested(scope.clientContext, path.substring(7));
    }
    if (path.startsWith('state.')) {
      return _navigateNested(scope.stateValues, path.substring(6));
    }
    if (path.startsWith('async.')) {
      return _navigateNested(scope.asyncData, path.substring(6));
    }
    if (path.startsWith('item.')) {
      return _navigateNested(scope.itemData, path.substring(5));
    }
    if (path.startsWith('env.features.')) {
      final flagKey = path.substring(13).trim();
      if (flagKey.isEmpty) return false;
      return scope.featureFlagLookup?.call(flagKey) ?? false;
    }

    // Fallback: look up directly in dataContext then stateValues.
    final fromData = _navigateNested(scope.dataContext, path);
    if (fromData != null) return fromData;
    return _navigateNested(scope.stateValues, path);
  }

  bool _isSingleStandaloneToken(String trimmed) {
    if (trimmed.length < 5) return false;
    if (!trimmed.startsWith('{{') || !trimmed.endsWith('}}')) return false;
    final closeIndex = trimmed.indexOf('}}');
    return closeIndex == trimmed.length - 2;
  }

  Object? _navigateNested(Object? root, String subPath) {
    if (root == null || subPath.isEmpty) return null;
    if (root is Map<String, dynamic> && root.containsKey(subPath)) {
      return root[subPath];
    }

    final segments = subPath.split('.');
    Object? current = root;
    final len = segments.length;
    for (var i = 0; i < len; i++) {
      final segment = segments[i];
      if (segment.isEmpty) continue;
      if (current is Map<String, dynamic>) {
        current = current[segment];
      } else if (current is Map) {
        current = current[segment];
      } else if (current is List) {
        final index = int.tryParse(segment);
        if (index != null && index >= 0 && index < current.length) {
          current = current[index];
        } else {
          return null;
        }
      } else {
        return null;
      }
      if (current == null) return null;
    }
    return current;
  }
}
