import 'package:fluent_environment_api/src/environment.dart';
import 'package:fluent_environment_api/src/environment_action.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Interface defined to use the fluent environment functionalities
abstract class EnvironmentApi {
  /// Get the current registered Environment
  ///
  /// A [AssertionError] maybe thrown if there is no any registered environment
  Environment get environment;

  /// The list of available environments.
  List<Environment> get availableEnvironments;

  /// A notifier that emits the current environment whenever it changes.
  ValueListenable<Environment> get environmentNotifier;

  /// Updates the current environment.
  void updateEnvironment(Environment environment);

  /// Registers a service to be reset whenever the environment changes.
  ///
  /// This is useful for services that depend on environment values (like Dio)
  /// and need to be reconstructed to pick up the new values.
  void registerResetService<T extends Object>();

  /// Shows the environment inspector.
  Future<void> showInspector(
    BuildContext context, {
    String? configValuesLabel,
    String? noValuesLabel,
    GlobalKey<NavigatorState>? navigatorKey,
  });

  /// Checks if a feature is enabled.
  bool isFeatureEnabled(String key);

  /// Sets a feature flag value at runtime.
  void setFeatureFlag(String key, {required bool value});

  /// Registers a custom action to be displayed in the environment inspector.
  void registerAction(EnvironmentAction action);

  /// The list of registered custom actions.
  List<EnvironmentAction> get actions;
}
