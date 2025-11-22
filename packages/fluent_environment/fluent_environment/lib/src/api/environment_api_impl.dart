import 'package:fluent_environment_api/fluent_environment_api.dart';

class EnvironmentApiImpl extends EnvironmentApi {
  EnvironmentApiImpl(this._environment);

  final Environment _environment;

  @override
  Environment get environment => _environment;
}
