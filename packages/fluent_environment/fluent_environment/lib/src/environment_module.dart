import 'package:fluent_environment/src/api/environment_api_impl.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

/// Register and build all the fluent environment dependencies
class EnvironmentModule extends FluentModule {
  EnvironmentModule({
    required this.environment,
  });

  /// The current environment
  final Environment environment;

  @override
  Future<void> build(Registry registry) async {
    registry
      ..registerSingleton<Environment>((it) => environment)
      ..registerSingleton<EnvironmentApi>((it) => EnvironmentApiImpl());
  }
}
