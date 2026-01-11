import 'dart:async';

import 'package:fluent_sdk/src/api/fluent_module.dart';
import 'package:fluent_sdk/src/api/registry.dart';
import 'package:fluent_sdk/src/fluent_registry.dart';
import 'package:get_it/get_it.dart';

/// The core facade of the Fluent ecosystem.
/// Acts as a centralized Service Locator and Module Orchestrator.
class Fluent {
  // Ocultamos el constructor para evitar instancias
  Fluent._();

  static final List<FluentModule> _modules = [];

  static final Registry _registry = FluentRegistry();

  /// Builds a list of modules sequentially.
  ///
  /// Unlike [Future.wait], this ensures that modules are registered in the
  /// exact order they are provided. This is crucial for dependencies
  /// (e.g., NetworkingModule must load before AuthModule).
  static Future<void> build(List<FluentModule> modules) async {
    _modules.addAll(modules);
    for (final module in modules) {
      await module.onCreate(_registry);
    }
    for (final module in modules) {
      await module.onStart();
    }
  }

  /// Retrieves an instance of a registered object [T].
  ///
  /// Throws a [StateError] if the instance is not registered.
  @pragma('vm:prefer-inline')
  static T get<T extends Object>() {
    return GetIt.instance<T>();
  }

  /// Registers a mock implementation for testing purposes.
  ///
  /// Uses a [try/finally] block to guarantee safety: even if registration fails,
  /// [allowReassignment] will be disabled,
  /// preserving the integrity of the container.
  @pragma('vm:prefer-inline')
  static void mock<T extends Object>(T mock) {
    try {
      _registry
        ..allowReassignment(allow: true)
        ..registerSingleton<T>((_) => mock);
    } finally {
      // Always lock the container back, no matter what happens above.
      _registry.allowReassignment(allow: false);
    }
  }

  /// Resets the dependency container.
  ///
  /// Useful for [tearDown] in unit tests.
  static Future<void> reset() async {
    for (final module in _modules.reversed) {
      await module.onStop();
    }
    _modules.clear();
    return GetIt.instance.reset();
  }
}
