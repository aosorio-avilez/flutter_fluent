import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

typedef FluentEnvironmentActions = List<EnvironmentAction>;

extension RegistryExtension on Registry {
  /// Function that allows you to register
  /// An action that will be available
  /// in the environment inspector
  void registerEnvironmentAction(EnvironmentAction action) {
    if (!isRegistered<FluentEnvironmentActions>()) {
      registerSingleton<FluentEnvironmentActions>(
        (it) => <EnvironmentAction>[],
      );
    }
    get<FluentEnvironmentActions>().add(action);
  }
}
