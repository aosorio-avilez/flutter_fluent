import 'package:fluent_cms_api/src/hydration/hydration_engine.dart';
import 'package:flutter/widgets.dart';

/// Zero-overhead [HydrationEngine] implementation for Tier 1 (Zero-Hydration).
///
/// Returns original references in `O(1)` without allocations.
@immutable
class NoOpHydrationEngine implements HydrationEngine {
  /// Creates a `const` [NoOpHydrationEngine].
  const NoOpHydrationEngine();

  @override
  @pragma('vm:prefer-inline')
  String resolveString(
    String input,
    HydrationScope scope, {
    BuildContext? context,
  }) => input;

  @override
  @pragma('vm:prefer-inline')
  Object? resolveValue(
    Object? value,
    HydrationScope scope, {
    BuildContext? context,
  }) => value;

  @override
  @pragma('vm:prefer-inline')
  Map<String, dynamic> resolveProps(
    Map<String, dynamic> props,
    HydrationScope scope, {
    BuildContext? context,
  }) => props;

  @override
  @pragma('vm:prefer-inline')
  bool evaluateCondition(String? expression, HydrationScope scope) => true;
}
