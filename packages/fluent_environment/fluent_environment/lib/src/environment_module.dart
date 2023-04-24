import 'package:fluent_environment/src/api/environment_api_impl.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';

class EnvironmentModule extends Module {
  EnvironmentModule({
    required this.environment,
  });

  final Environment environment;

  @override
  void build(Registry registry) {
    registry
      ..registerApi<Environment>((it) => environment)
      ..registerApi<EnvironmentApi>((it) => EnvironmentApiImpl());
  }
}
