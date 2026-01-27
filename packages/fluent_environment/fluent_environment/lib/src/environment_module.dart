import 'package:fluent_environment/src/api/environment_api_impl.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

/// Registers the environment dependencies.
class EnvironmentModule extends FluentModule {
  const EnvironmentModule({
    required this.environment,
  });

  final Environment environment;

  @override
  void onCreate(Registry registry) {
    registry
      ..registerLazySingleton<Environment>((_) => environment)
      ..registerLazySingleton<EnvironmentApi>(
        (it) => EnvironmentApiImpl(it<Environment>()),
      );
  }
}
