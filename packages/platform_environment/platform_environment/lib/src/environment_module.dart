import 'package:platform_environment/src/api/environment_api_impl.dart';
import 'package:platform_environment_api/platform_environment_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class EnvironmentModule extends Module {
  EnvironmentModule(this.environment, {super.testMode = false});

  final Environment environment;

  @override
  void build(Registry registry) {
    registry
      ..registerApi<Environment>((it) => environment)
      ..registerApi<EnvironmentApi>((it) => EnvironmentApiImpl());
  }
}
