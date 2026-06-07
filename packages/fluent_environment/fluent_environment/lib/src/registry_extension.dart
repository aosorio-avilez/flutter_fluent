import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

/// Extension methods for [Registry] to simplify environment configuration.
extension RegistryExtension on Registry {
  /// Registers a custom developer action to be displayed in the
  /// Environment Inspector.
  void registerEnvironmentAction(EnvironmentAction action) {
    Fluent.get<EnvironmentApi>().registerAction(action);
  }
}
