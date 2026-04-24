import 'package:fluent_environment_api/src/environment_type.dart';
import 'package:flutter/material.dart';

/// Abstract definition of an Application Environment.
/// Clients must extend this class to provide specific configuration values.
abstract class Environment {
  const Environment();

  /// The primary color associated with this environment (e.g., Red for Dev).
  Color get color;

  /// The display name of the environment.
  String get name;

  /// The classification of the environment.
  EnvironmentType get type;

  /// A map of configuration values (API Keys, Base URLs, etc.).
  Map<String, String> get values;

  /// A set of keys that should be redacted in logs or UI.
  Set<String> get sensitiveKeys => const {};
}

/// Convenience extensions to avoid verbose type checks.
extension EnvironmentExt on Environment {
  bool get isProduction => type == EnvironmentType.prod;
  bool get isStaging => type == EnvironmentType.stg;
  bool get isDevelopment => type == EnvironmentType.dev;
}
