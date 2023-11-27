import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

class EnvironmentApiImpl extends EnvironmentApi {
  @override
  Environment get environment => Fluent.get<Environment>();
}
