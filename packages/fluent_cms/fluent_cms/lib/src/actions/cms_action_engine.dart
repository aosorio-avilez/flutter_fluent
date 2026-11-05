import 'dart:async';

import 'package:fluent_cms/src/cms_config.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter/foundation.dart';

/// Callback executed when `actionType: 'scroll_to'` is triggered.
typedef CmsScrollToModuleCallback =
    Future<bool> Function(
      String targetModuleId,
      Map<String, dynamic>? payload,
    );

/// Callback executed when `actionType: 'modal_zone'` is triggered.
typedef CmsModalZoneCallback =
    Future<bool> Function(
      String targetZoneId,
      Map<String, dynamic>? payload,
    );

/// Executes declarative [ActionNode] intents with concurrency control,
/// optimistic state mutation/rollback, and strict lifecycle timer cleanup.
class CmsActionEngine {
  /// Creates a [CmsActionEngine].
  CmsActionEngine({
    required this.pageId,
    required this.pageStore,
    this.config = const CmsConfig(),
    this.hydrationEngine = const NoOpHydrationEngine(),
    this.logger,
    this.onNavigate,
    this.onExternalUrl,
    this.onScrollToModule,
    this.onShowModalZone,
    Map<String, CmsCommandHandler>? commandHandlers,
    List<CmsActionObserver>? observers,
  }) : _commandHandlers = <String, CmsCommandHandler>{
         ...config.initialCommandHandlers,
         ...?commandHandlers,
       },
       _observers = <CmsActionObserver>[...?observers];

  /// Identifier of the active page.
  final String pageId;

  /// Reactive store for the active page.
  final CmsPageStore pageStore;

  /// Global CMS configuration.
  final CmsConfig config;

  /// Hydration engine used to resolve dynamic placeholders in payloads/targets.
  final HydrationEngine hydrationEngine;

  /// Optional logger for reporting blocked URLs or action errors.
  final LoggerApi? logger;

  /// Optional navigation callback (overrides [CmsConfig.onNavigate]).
  final CmsNavigationHandler? onNavigate;

  /// Optional external URL callback (overrides [CmsConfig.onExternalUrl]).
  final CmsExternalUrlHandler? onExternalUrl;

  /// Optional scroll-to-module callback provided by `CmsPageController`.
  final CmsScrollToModuleCallback? onScrollToModule;

  /// Optional modal-zone callback provided by `CmsPageView`.
  final CmsModalZoneCallback? onShowModalZone;

  final Map<String, CmsCommandHandler> _commandHandlers;
  final List<CmsActionObserver> _observers;

  final Set<String> _busyActionKeys = <String>{};
  final Map<String, int> _runningCountByModule = <String, int>{};
  final Map<String, ValueNotifier<bool>> _moduleRunningNotifiers =
      <String, ValueNotifier<bool>>{};
  final Map<String, Timer> _debounceTimers = <String, Timer>{};
  final Map<String, Completer<bool>> _debounceCompleters =
      <String, Completer<bool>>{};
  final Set<String> _throttledKeys = <String>{};
  final Map<String, Timer> _throttleTimers = <String, Timer>{};

  bool _isDisposed = false;

  /// Whether this action engine has been disposed.
  bool get isDisposed => _isDisposed;

  /// Registers a custom command [handler] for [commandName].
  void registerCommandHandler(String commandName, CmsCommandHandler handler) {
    if (_isDisposed) return;
    _commandHandlers[commandName] = handler;
  }

  /// Adds an action/analytics [observer].
  void addObserver(CmsActionObserver observer) {
    if (_isDisposed) return;
    _observers.add(observer);
  }

  /// Removes a previously added [observer].
  void removeObserver(CmsActionObserver observer) {
    if (_isDisposed) return;
    _observers.remove(observer);
  }

  /// Whether any action is currently running for [moduleId].
  bool isModuleActionRunning(String moduleId) {
    if (_isDisposed) return false;
    return (_runningCountByModule[moduleId] ?? 0) > 0;
  }

  /// Returns a [ValueListenable] tracking whether an action is running for
  /// [moduleId].
  ValueListenable<bool> moduleRunningListenable(String moduleId) {
    final existing = _moduleRunningNotifiers[moduleId];
    if (existing != null) return existing;
    final created = ValueNotifier<bool>(isModuleActionRunning(moduleId));
    if (!_isDisposed) {
      _moduleRunningNotifiers[moduleId] = created;
    }
    return created;
  }

  /// Executes [action] triggered by [moduleId] and [trigger] under its
  /// configured concurrency policy (`dropIfBusy`, `debounce`, `throttle`,
  /// `allowParallel`).
  Future<bool> execute({
    required String moduleId,
    required String trigger,
    required ActionNode action,
    HydrationScope scope = HydrationScope.empty,
    Map<String, dynamic>? extraPayload,
  }) async {
    if (_isDisposed) return false;

    final actionKey = '$moduleId::$trigger';
    final policy = action.concurrency;

    if (policy == 'dropIfBusy') {
      if (_busyActionKeys.contains(actionKey)) {
        return false;
      }
      return _runGuarded(
        actionKey: actionKey,
        moduleId: moduleId,
        trigger: trigger,
        action: action,
        scope: scope,
        extraPayload: extraPayload,
      );
    }

    if (policy == 'debounce') {
      _debounceTimers[actionKey]?.cancel();
      final prevCompleter = _debounceCompleters.remove(actionKey);
      if (prevCompleter != null && !prevCompleter.isCompleted) {
        prevCompleter.complete(false);
      }

      final completer = Completer<bool>();
      _debounceCompleters[actionKey] = completer;

      final delay = Duration(milliseconds: action.debounceMs);
      _debounceTimers[actionKey] = Timer(delay, () async {
        _debounceTimers.remove(actionKey);
        _debounceCompleters.remove(actionKey);
        if (_isDisposed) {
          if (!completer.isCompleted) completer.complete(false);
          return;
        }
        final refreshedScope = scope.copyWith(
          stateValues: pageStore.toMap(),
        );
        final result = await _runGuarded(
          actionKey: actionKey,
          moduleId: moduleId,
          trigger: trigger,
          action: action,
          scope: refreshedScope,
          extraPayload: extraPayload,
        );
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      });

      return completer.future;
    }

    if (policy == 'throttle') {
      if (_throttledKeys.contains(actionKey)) {
        return false;
      }
      _throttledKeys.add(actionKey);
      final cooldown = Duration(milliseconds: action.debounceMs);
      _throttleTimers[actionKey]?.cancel();
      _throttleTimers[actionKey] = Timer(cooldown, () {
        _throttleTimers.remove(actionKey);
        if (_isDisposed) return;
        _throttledKeys.remove(actionKey);
      });

      return _runGuarded(
        actionKey: actionKey,
        moduleId: moduleId,
        trigger: trigger,
        action: action,
        scope: scope,
        extraPayload: extraPayload,
      );
    }

    // Default / 'allowParallel'
    return _runGuarded(
      actionKey: actionKey,
      moduleId: moduleId,
      trigger: trigger,
      action: action,
      scope: scope,
      extraPayload: extraPayload,
    );
  }

  Future<bool> _runGuarded({
    required String actionKey,
    required String moduleId,
    required String trigger,
    required ActionNode action,
    required HydrationScope scope,
    required Map<String, dynamic>? extraPayload,
  }) async {
    if (_isDisposed) return false;

    _busyActionKeys.add(actionKey);
    _incrementRunning(moduleId);

    final optimistic = action.optimisticState;
    Object? previousOptimisticValue;
    if (optimistic != null && optimistic.key.isNotEmpty) {
      previousOptimisticValue = pageStore.getValue<Object?>(optimistic.key);
      final resolvedOptVal = hydrationEngine.resolveValue(
        optimistic.value,
        scope,
      );
      pageStore.setValue(optimistic.key, resolvedOptVal);
    }

    final resolvedPayload = _resolvePayload(
      action.payload,
      extraPayload,
      scope,
    );
    final resolvedAnalytics = action.analytics != null
        ? hydrationEngine.resolveProps(action.analytics!, scope)
        : null;
    final resolvedTarget = action.target != null
        ? hydrationEngine.resolveString(action.target!, scope)
        : null;

    _notifyObservers(
      CmsActionEvent(
        pageId: pageId,
        moduleId: moduleId,
        trigger: trigger,
        action: action,
        resolvedPayload: resolvedPayload,
        resolvedAnalytics: resolvedAnalytics,
      ),
    );

    var succeeded = false;
    try {
      succeeded = await _dispatchAction(
        actionType: action.actionType,
        target: resolvedTarget,
        payload: resolvedPayload,
      );
    } on Object catch (error, stackTrace) {
      logger?.logError(
        '[fluent_cms] Action "${action.actionType}" failed on module '
        '"$moduleId": $error',
        stackTrace: stackTrace,
      );
      succeeded = false;
    }

    if (_isDisposed) {
      return false;
    }

    if (!succeeded &&
        optimistic != null &&
        optimistic.key.isNotEmpty &&
        optimistic.rollbackOnError) {
      pageStore.setValue(optimistic.key, previousOptimisticValue);
    }

    _busyActionKeys.remove(actionKey);
    _decrementRunning(moduleId);

    if (succeeded && action.onSuccess != null) {
      final nextScope = scope.copyWith(stateValues: pageStore.toMap());
      await execute(
        moduleId: moduleId,
        trigger: '$trigger.onSuccess',
        action: action.onSuccess!,
        scope: nextScope,
      );
    } else if (!succeeded && action.onError != null) {
      final nextScope = scope.copyWith(stateValues: pageStore.toMap());
      await execute(
        moduleId: moduleId,
        trigger: '$trigger.onError',
        action: action.onError!,
        scope: nextScope,
      );
    }

    return succeeded;
  }

  Map<String, dynamic>? _resolvePayload(
    Map<String, dynamic>? basePayload,
    Map<String, dynamic>? extraPayload,
    HydrationScope scope,
  ) {
    if (basePayload == null && extraPayload == null) return null;
    final merged = <String, dynamic>{};
    if (basePayload != null) {
      final hydrated = hydrationEngine.resolveProps(basePayload, scope);
      for (final entry in hydrated.entries) {
        merged[entry.key] = entry.value;
      }
    }
    if (extraPayload != null) {
      for (final entry in extraPayload.entries) {
        merged[entry.key] = entry.value;
      }
    }
    return merged;
  }

  void _notifyObservers(CmsActionEvent event) {
    for (var i = 0; i < _observers.length; i++) {
      _observers[i](event);
    }
  }

  Future<bool> _dispatchAction({
    required String actionType,
    required String? target,
    required Map<String, dynamic>? payload,
  }) async {
    switch (actionType) {
      case 'analytics_only':
        return true;

      case 'state_mutation':
        if (target == null || target.isEmpty) return false;
        pageStore.setValue(target, payload?['value']);
        return true;

      case 'navigation':
        if (target == null || target.isEmpty) return false;
        final navHandler = onNavigate ?? config.onNavigate;
        if (navHandler == null) {
          logger?.logWarning(
            '[fluent_cms] No navigation handler configured for route '
            '"$target".',
          );
          return false;
        }
        return navHandler(target, payload);

      case 'external_url':
        if (target == null || !config.isUriAllowed(target)) {
          logger?.logWarning(
            '[fluent_cms] Blocked unauthorized or unsafe external_url: '
            '"$target".',
          );
          return false;
        }
        final uri = Uri.parse(target.trim());
        final urlHandler = onExternalUrl ?? config.onExternalUrl;
        if (urlHandler == null) {
          return true;
        }
        return urlHandler(uri, payload);

      case 'scroll_to':
        if (target == null || target.isEmpty) return false;
        final scrollHandler = onScrollToModule;
        if (scrollHandler == null) return false;
        return scrollHandler(target, payload);

      case 'modal_zone':
        if (target == null || target.isEmpty) return false;
        final modalHandler = onShowModalZone;
        if (modalHandler == null) return false;
        return modalHandler(target, payload);

      case 'custom_command':
        if (target == null || target.isEmpty) return false;
        final command = _commandHandlers[target];
        if (command == null) {
          logger?.logWarning(
            '[fluent_cms] Unregistered custom_command "$target".',
          );
          return false;
        }
        return command(target, payload);

      default:
        logger?.logWarning(
          '[fluent_cms] Unknown actionType "$actionType".',
        );
        return false;
    }
  }

  void _incrementRunning(String moduleId) {
    final next = (_runningCountByModule[moduleId] ?? 0) + 1;
    _runningCountByModule[moduleId] = next;
    _moduleRunningNotifiers[moduleId]?.value = true;
  }

  void _decrementRunning(String moduleId) {
    final current = _runningCountByModule[moduleId] ?? 0;
    final next = current > 1 ? current - 1 : 0;
    if (next == 0) {
      _runningCountByModule.remove(moduleId);
      _moduleRunningNotifiers[moduleId]?.value = false;
    } else {
      _runningCountByModule[moduleId] = next;
    }
  }

  /// Cancels all active timers and disposes internal notifiers.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    for (final entry in _debounceTimers.entries) {
      entry.value.cancel();
    }
    _debounceTimers.clear();

    for (final entry in _debounceCompleters.entries) {
      if (!entry.value.isCompleted) {
        entry.value.complete(false);
      }
    }
    _debounceCompleters.clear();

    for (final entry in _throttleTimers.entries) {
      entry.value.cancel();
    }
    _throttleTimers.clear();
    _throttledKeys.clear();

    for (final entry in _moduleRunningNotifiers.entries) {
      entry.value.dispose();
    }
    _moduleRunningNotifiers.clear();
    _runningCountByModule.clear();
    _busyActionKeys.clear();
  }
}
