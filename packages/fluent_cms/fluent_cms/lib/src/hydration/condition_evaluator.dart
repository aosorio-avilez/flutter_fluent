import 'package:fluent_cms_api/fluent_cms_api.dart';

/// Zero-closure evaluator for `visibleWhen` boolean expressions and scope
/// path lookups (`data.*`, `client.*`, `state.*`, `async.*`, `item.*`,
/// `index`, and `env.features.*`).
class ConditionEvaluator {
  /// Creates a `const` [ConditionEvaluator].
  const ConditionEvaluator();

  /// Resolves a dot-separated [path] (e.g. `'data.user.firstName'`,
  /// `'state.searchQuery'`, `'env.features.loyalty_v2'`) against [scope].
  static Object? resolvePath(String path, HydrationScope scope) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed == 'index') {
      return scope.itemIndex;
    }

    final firstDot = trimmed.indexOf('.');
    if (firstDot == -1) {
      return scope.stateValues[trimmed] ?? scope.dataContext[trimmed];
    }

    final prefix = trimmed.substring(0, firstDot);
    final remainder = trimmed.substring(firstDot + 1);

    switch (prefix) {
      case 'data':
        return readNestedPath(scope.dataContext, remainder);
      case 'client':
        return readNestedPath(scope.clientContext, remainder);
      case 'state':
        return readNestedPath(scope.stateValues, remainder);
      case 'async':
        final secondDot = remainder.indexOf('.');
        if (secondDot == -1) {
          return scope.asyncData[remainder];
        }
        final sourceKey = remainder.substring(0, secondDot);
        final subPath = remainder.substring(secondDot + 1);
        final sourceMap = scope.asyncData[sourceKey];
        if (sourceMap == null) return null;
        return readNestedPath(sourceMap, subPath);
      case 'item':
        final itemMap = scope.itemData;
        if (itemMap == null) return null;
        return readNestedPath(itemMap, remainder);
      case 'env':
        if (remainder.startsWith('features.')) {
          final flagKey = remainder.substring('features.'.length).trim();
          if (flagKey.isEmpty) return false;
          return scope.featureFlagLookup?.call(flagKey) ?? false;
        }
        return null;
      default:
        return readNestedPath(scope.dataContext, trimmed);
    }
  }

  /// Traverses [root] along a dot-separated [path] using a standard loop
  /// without allocating closures.
  static Object? readNestedPath(Map<String, dynamic> root, String path) {
    if (path.isEmpty) return root;
    Object? current = root;
    var start = 0;
    final length = path.length;

    while (start <= length) {
      final dotIndex = path.indexOf('.', start);
      final segment = dotIndex == -1
          ? path.substring(start)
          : path.substring(start, dotIndex);

      if (current is Map) {
        current = current[segment];
      } else if (current is List) {
        final idx = int.tryParse(segment);
        if (idx != null && idx >= 0 && idx < current.length) {
          current = current[idx];
        } else {
          return null;
        }
      } else {
        return null;
      }

      if (current == null || dotIndex == -1) {
        break;
      }
      start = dotIndex + 1;
    }

    return current;
  }

  /// Evaluates a `visibleWhen` boolean [expression] against [scope].
  /// Returns `true` when [expression] is `null` or empty.
  static bool evaluate(String? expression, HydrationScope scope) {
    if (expression == null) return true;
    final trimmed = expression.trim();
    if (trimmed.isEmpty) return true;

    // Split OR (`||`) clauses using index scanning (zero closure allocation).
    var orStart = 0;
    while (orStart <= trimmed.length) {
      final orIdx = trimmed.indexOf('||', orStart);
      final orClause = orIdx == -1
          ? trimmed.substring(orStart)
          : trimmed.substring(orStart, orIdx);

      if (_evaluateAndChain(orClause, scope)) {
        return true;
      }

      if (orIdx == -1) break;
      orStart = orIdx + 2;
    }
    return false;
  }

  static bool _evaluateAndChain(String clause, HydrationScope scope) {
    var andStart = 0;
    while (andStart <= clause.length) {
      final andIdx = clause.indexOf('&&', andStart);
      final atom = andIdx == -1
          ? clause.substring(andStart)
          : clause.substring(andStart, andIdx);

      if (!_evaluateAtom(atom.trim(), scope)) {
        return false;
      }

      if (andIdx == -1) break;
      andStart = andIdx + 2;
    }
    return true;
  }

  static bool _evaluateAtom(String atom, HydrationScope scope) {
    if (atom.isEmpty) return true;

    if (atom.startsWith('!')) {
      return !_evaluateAtom(atom.substring(1).trim(), scope);
    }

    const operators = <String>['==', '!=', '>=', '<=', '>', '<'];
    for (var i = 0; i < operators.length; i++) {
      final op = operators[i];
      final opIdx = atom.indexOf(op);
      if (opIdx != -1) {
        final leftRaw = atom.substring(0, opIdx).trim();
        final rightRaw = atom.substring(opIdx + op.length).trim();
        final leftVal = _resolveOperand(leftRaw, scope);
        final rightVal = _resolveOperand(rightRaw, scope);
        return _compareValues(leftVal, rightVal, op);
      }
    }

    final resolved = _resolveOperand(atom, scope);
    return _toBool(resolved);
  }

  static Object? _resolveOperand(String raw, HydrationScope scope) {
    var token = raw.trim();
    if (token.isEmpty) return null;

    if (token.startsWith('{{') && token.endsWith('}}') && token.length >= 4) {
      token = token.substring(2, token.length - 2).trim();
      return resolvePath(token, scope);
    }

    if ((token.startsWith("'") && token.endsWith("'")) ||
        (token.startsWith('"') && token.endsWith('"'))) {
      if (token.length >= 2) {
        return token.substring(1, token.length - 1);
      }
    }

    if (token == 'true') return true;
    if (token == 'false') return false;
    if (token == 'null') return null;

    final numVal = num.tryParse(token);
    if (numVal != null) return numVal;

    if (token.contains('.') ||
        token == 'index' ||
        scope.stateValues.containsKey(token) ||
        scope.dataContext.containsKey(token)) {
      return resolvePath(token, scope);
    }

    return token;
  }

  static bool _compareValues(Object? left, Object? right, String op) {
    if (op == '==' || op == '!=') {
      final isEqual = _areLooselyEqual(left, right);
      return op == '==' ? isEqual : !isEqual;
    }

    final leftNum = _toNum(left);
    final rightNum = _toNum(right);
    if (leftNum == null || rightNum == null) return false;

    switch (op) {
      case '>=':
        return leftNum >= rightNum;
      case '<=':
        return leftNum <= rightNum;
      case '>':
        return leftNum > rightNum;
      case '<':
        return leftNum < rightNum;
      default:
        return false;
    }
  }

  static bool _areLooselyEqual(Object? a, Object? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a is num && b is num) return a.toDouble() == b.toDouble();
    return a.toString() == b.toString();
  }

  static num? _toNum(Object? value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.trim());
    return null;
  }

  static bool _toBool(Object? value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower.isEmpty ||
          lower == 'false' ||
          lower == '0' ||
          lower == 'null') {
        return false;
      }
      return true;
    }
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }
}
