import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Callback that evaluates whether an environment feature flag is enabled.
typedef FeatureFlagLookup = bool Function(String flagKey);

/// Immutable scope holding all data dictionaries available during hydration.
@immutable
class HydrationScope extends Equatable {
  /// Creates a [HydrationScope].
  const HydrationScope({
    this.dataContext = const <String, dynamic>{},
    this.clientContext = const <String, dynamic>{},
    this.stateValues = const <String, dynamic>{},
    this.asyncData = const <String, Map<String, dynamic>>{},
    this.itemData,
    this.itemIndex,
    this.featureFlagLookup,
  });

  /// Empty scope constant for zero-allocation defaults.
  static const HydrationScope empty = HydrationScope();

  /// Pre-hydrated BFF context (`{{data.*}}`).
  final Map<String, dynamic> dataContext;

  /// Client-injected local context (`{{client.*}}`).
  final Map<String, dynamic> clientContext;

  /// Reactive page store snapshot (`{{state.*}}`).
  final Map<String, dynamic> stateValues;

  /// Resolved async data sources keyed by source ID (`{{async.<id>.*}}`).
  final Map<String, Map<String, dynamic>> asyncData;

  /// Current item map inside a `cms_repeater` template (`{{item.*}}`).
  final Map<String, dynamic>? itemData;

  /// Current 0-based index inside a `cms_repeater` template (`{{index}}`).
  final int? itemIndex;

  /// Optional callback to resolve `{{env.features.<flagKey>}}`.
  final FeatureFlagLookup? featureFlagLookup;

  /// Returns a copy of this [HydrationScope] with updated fields.
  HydrationScope copyWith({
    Map<String, dynamic>? dataContext,
    Map<String, dynamic>? clientContext,
    Map<String, dynamic>? stateValues,
    Map<String, Map<String, dynamic>>? asyncData,
    Map<String, dynamic>? itemData,
    int? itemIndex,
    FeatureFlagLookup? featureFlagLookup,
  }) {
    return HydrationScope(
      dataContext: dataContext ?? this.dataContext,
      clientContext: clientContext ?? this.clientContext,
      stateValues: stateValues ?? this.stateValues,
      asyncData: asyncData ?? this.asyncData,
      itemData: itemData ?? this.itemData,
      itemIndex: itemIndex ?? this.itemIndex,
      featureFlagLookup: featureFlagLookup ?? this.featureFlagLookup,
    );
  }

  @override
  List<Object?> get props => [
    dataContext,
    clientContext,
    stateValues,
    asyncData,
    itemData,
    itemIndex,
    featureFlagLookup,
  ];
}

/// Contract for resolving `{{...}}` placeholders, pipes, and `visibleWhen`
/// conditions.
abstract class HydrationEngine {
  /// Resolves a string containing optional `{{...}}` placeholders.
  String resolveString(
    String input,
    HydrationScope scope, {
    BuildContext? context,
  });

  /// Resolves an arbitrary property value (String, Map, List, or primitive).
  Object? resolveValue(
    Object? value,
    HydrationScope scope, {
    BuildContext? context,
  });

  /// Resolves all entries in a module `props` map.
  Map<String, dynamic> resolveProps(
    Map<String, dynamic> props,
    HydrationScope scope, {
    BuildContext? context,
  });

  /// Evaluates a boolean `visibleWhen` expression against [scope].
  bool evaluateCondition(String? expression, HydrationScope scope);
}
