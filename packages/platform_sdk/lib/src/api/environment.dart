import 'package:platform_sdk/src/environment_type.dart';

abstract class Environment {
  EnvironmentType get type;

  Map<String, String> get values;
}
