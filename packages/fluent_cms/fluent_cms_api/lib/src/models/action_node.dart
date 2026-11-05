import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Describes an immediate optimistic state mutation in `CmsPageStore`.
@immutable
class OptimisticMutation extends Equatable {
  /// Creates an [OptimisticMutation].
  const OptimisticMutation({
    required this.key,
    required this.value,
    this.rollbackOnError = true,
  });

  /// Deserializes an [OptimisticMutation] from a JSON map.
  factory OptimisticMutation.fromJson(Map<String, dynamic> json) {
    return OptimisticMutation(
      key: json['key'] as String? ?? '',
      value: json['value'],
      rollbackOnError: json['rollbackOnError'] as bool? ?? true,
    );
  }

  /// Reactive store key to mutate immediately.
  final String key;

  /// Optimistic value to assign before the action completes.
  final Object? value;

  /// Whether to revert to the previous value if the action fails.
  final bool rollbackOnError;

  /// Serializes this [OptimisticMutation] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'value': value,
      'rollbackOnError': rollbackOnError,
    };
  }

  /// Returns a copy of this [OptimisticMutation] with the given fields
  /// replaced.
  OptimisticMutation copyWith({
    String? key,
    Object? value,
    bool? rollbackOnError,
  }) {
    return OptimisticMutation(
      key: key ?? this.key,
      value: value ?? this.value,
      rollbackOnError: rollbackOnError ?? this.rollbackOnError,
    );
  }

  @override
  List<Object?> get props => [key, value, rollbackOnError];
}

/// Declarative intent executed by the `CmsActionEngine`.
@immutable
class ActionNode extends Equatable {
  /// Creates an [ActionNode].
  const ActionNode({
    required this.actionType,
    this.target,
    this.concurrency = 'dropIfBusy',
    this.debounceMs = 300,
    this.payload,
    this.optimisticState,
    this.analytics,
    this.onSuccess,
    this.onError,
  });

  /// Deserializes an [ActionNode] from a JSON map.
  factory ActionNode.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedPayload;
    final rawPayload = json['payload'];
    if (rawPayload is Map) {
      parsedPayload = <String, dynamic>{};
      for (final entry in rawPayload.entries) {
        if (entry.key != null) {
          parsedPayload[entry.key.toString()] = entry.value;
        }
      }
    }

    OptimisticMutation? parsedOptimistic;
    final rawOptimistic = json['optimisticState'];
    if (rawOptimistic is Map<String, dynamic>) {
      parsedOptimistic = OptimisticMutation.fromJson(rawOptimistic);
    }

    Map<String, dynamic>? parsedAnalytics;
    final rawAnalytics = json['analytics'];
    if (rawAnalytics is Map) {
      parsedAnalytics = <String, dynamic>{};
      for (final entry in rawAnalytics.entries) {
        if (entry.key != null) {
          parsedAnalytics[entry.key.toString()] = entry.value;
        }
      }
    }

    ActionNode? parsedOnSuccess;
    final rawOnSuccess = json['onSuccess'];
    if (rawOnSuccess is Map<String, dynamic>) {
      parsedOnSuccess = ActionNode.fromJson(rawOnSuccess);
    }

    ActionNode? parsedOnError;
    final rawOnError = json['onError'];
    if (rawOnError is Map<String, dynamic>) {
      parsedOnError = ActionNode.fromJson(rawOnError);
    }

    return ActionNode(
      actionType: json['actionType'] as String? ?? 'custom_command',
      target: json['target'] as String?,
      concurrency: json['concurrency'] as String? ?? 'dropIfBusy',
      debounceMs: (json['debounceMs'] as num?)?.toInt() ?? 300,
      payload: parsedPayload,
      optimisticState: parsedOptimistic,
      analytics: parsedAnalytics,
      onSuccess: parsedOnSuccess,
      onError: parsedOnError,
    );
  }

  /// Type of action (`navigation`, `external_url`, `state_mutation`,
  /// `modal_zone`, `scroll_to`, `analytics_only`, `custom_command`).
  final String actionType;

  /// Target route, URL, state key, module ID, or command name.
  final String? target;

  /// Execution policy (`dropIfBusy`, `debounce`, `throttle`, `allowParallel`).
  final String concurrency;

  /// Time window in milliseconds when [concurrency] is `debounce` or
  /// `throttle`.
  final int debounceMs;

  /// Optional arguments sent to the action handler (supports `{{...}}`).
  final Map<String, dynamic>? payload;

  /// Optional optimistic state mutation applied before resolving the action.
  final OptimisticMutation? optimisticState;

  /// Optional metadata emitted to global `CmsActionObserver` listeners.
  final Map<String, dynamic>? analytics;

  /// Chained action executed when the primary action succeeds.
  final ActionNode? onSuccess;

  /// Chained action executed when the primary action fails.
  final ActionNode? onError;

  /// Serializes this [ActionNode] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'actionType': actionType,
      if (target != null) 'target': target,
      'concurrency': concurrency,
      'debounceMs': debounceMs,
      if (payload != null) 'payload': payload,
      if (optimisticState != null) 'optimisticState': optimisticState!.toJson(),
      if (analytics != null) 'analytics': analytics,
      if (onSuccess != null) 'onSuccess': onSuccess!.toJson(),
      if (onError != null) 'onError': onError!.toJson(),
    };
  }

  /// Returns a copy of this [ActionNode] with the given fields replaced.
  ActionNode copyWith({
    String? actionType,
    String? target,
    String? concurrency,
    int? debounceMs,
    Map<String, dynamic>? payload,
    OptimisticMutation? optimisticState,
    Map<String, dynamic>? analytics,
    ActionNode? onSuccess,
    ActionNode? onError,
  }) {
    return ActionNode(
      actionType: actionType ?? this.actionType,
      target: target ?? this.target,
      concurrency: concurrency ?? this.concurrency,
      debounceMs: debounceMs ?? this.debounceMs,
      payload: payload ?? this.payload,
      optimisticState: optimisticState ?? this.optimisticState,
      analytics: analytics ?? this.analytics,
      onSuccess: onSuccess ?? this.onSuccess,
      onError: onError ?? this.onError,
    );
  }

  @override
  List<Object?> get props => [
    actionType,
    target,
    concurrency,
    debounceMs,
    payload,
    optimisticState,
    analytics,
    onSuccess,
    onError,
  ];
}
