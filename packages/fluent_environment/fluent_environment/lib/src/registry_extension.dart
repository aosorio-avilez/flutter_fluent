import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

/// Extension methods for the [Registry] to register environment actions.
extension RegistryExtension on Registry {
  /// Registers a custom action to be displayed in the environment inspector.
  void registerEnvironmentAction(EnvironmentAction action) {
    if (isRegistered<EnvironmentApi>()) {
      get<EnvironmentApi>().registerAction(action);
    }
  }
}
