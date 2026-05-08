import 'package:fluent_environment/src/api/environment_api_impl.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

/// Registers the environment dependencies.
class EnvironmentModule extends FluentModule {
  const EnvironmentModule({
    required this.environment,
    this.availableEnvironments = const [],
  });

  final Environment environment;
  final List<Environment> availableEnvironments;

  @override
  void onCreate(Registry registry) {
    registry
      ..registerLazySingleton<EnvironmentApi>(
        (it) => EnvironmentApiImpl(
          environment,
          availableEnvironments.isEmpty
              ? [environment]
              : availableEnvironments,
        ),
      )
      ..registerFactory<Environment>((it) => it<EnvironmentApi>().environment);
  }
}
