import 'package:fluent_sdk/fluent_sdk.dart';

class TestEnvironment extends Environment {
  TestEnvironment({this.type = EnvironmentType.dev});

  @override
  final EnvironmentType type;

  @override
  Map<String, String> get values => {};
}
