import 'package:fluent_cms/src/hydration/condition_evaluator.dart';
import 'package:fluent_cms/src/hydration/pipe_transformer_registry.dart';
import 'package:fluent_cms/src/hydration/single_pass_expression_resolver.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter/widgets.dart';

/// Opt-in mixed hydration engine (Tier 2 & Tier 3) combining
/// [SinglePassExpressionResolver], [PipeTransformerRegistry], and
/// [ConditionEvaluator].
class MixedHydrationEngine implements HydrationEngine {
  /// Creates a [MixedHydrationEngine].
  MixedHydrationEngine({
    PipeTransformerRegistry? pipeRegistry,
  }) : pipeRegistry = pipeRegistry ?? PipeTransformerRegistry(),
       resolver = SinglePassExpressionResolver(
         pipeRegistry: pipeRegistry ?? PipeTransformerRegistry(),
       );

  /// Registry of pipe transformers (`currency`, `number`, `date`, etc.).
  final PipeTransformerRegistry pipeRegistry;

  /// Single-pass `{{...}}` expression resolver.
  final SinglePassExpressionResolver resolver;

  static final RegExp _stateKeyRegExp = RegExp(
    r'state\.([a-zA-Z0-9_]+)',
  );

  @override
  String resolveString(
    String input,
    HydrationScope scope, {
    BuildContext? context,
  }) {
    return resolver.resolveString(input, scope, context: context);
  }

  @override
  Object? resolveValue(
    Object? value,
    HydrationScope scope, {
    BuildContext? context,
  }) {
    return resolver.resolveValue(value, scope, context: context);
  }

  @override
  Map<String, dynamic> resolveProps(
    Map<String, dynamic> props,
    HydrationScope scope, {
    BuildContext? context,
  }) {
    return resolver.resolveMap(props, scope, context: context);
  }

  @override
  bool evaluateCondition(String? expression, HydrationScope scope) {
    return ConditionEvaluator.evaluate(expression, scope);
  }

  /// Extracts all `state.<key>` top-level keys referenced in [props] or
  /// [visibleWhen] so a module widget can subscribe only to the reactive
  /// keys it depends on.
  Set<String> extractStateKeys(
    Map<String, dynamic> props, {
    String? visibleWhen,
  }) {
    final keys = <String>{};
    if (visibleWhen != null && visibleWhen.isNotEmpty) {
      _extractStateKeysFromString(visibleWhen, keys);
    }
    _scanObjectForStateKeys(props, keys);
    return keys;
  }

  void _extractStateKeysFromString(String input, Set<String> target) {
    if (!input.contains('state.')) return;
    final matches = _stateKeyRegExp.allMatches(input);
    for (final match in matches) {
      final key = match.group(1);
      if (key != null && key.isNotEmpty) {
        target.add(key);
      }
    }
  }

  void _scanObjectForStateKeys(Object? value, Set<String> target) {
    if (value is String) {
      if (!value.contains('{{')) return;
      _extractStateKeysFromString(value, target);
      return;
    }

    if (value is Map) {
      for (final entry in value.entries) {
        _scanObjectForStateKeys(entry.value, target);
      }
      return;
    }

    if (value is List) {
      final len = value.length;
      for (var i = 0; i < len; i++) {
        _scanObjectForStateKeys(value[i], target);
      }
    }
  }
}
