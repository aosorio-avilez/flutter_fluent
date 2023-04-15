import 'package:platform_sdk/platform_sdk.dart';

class TestEnvironment extends Environment {
  TestEnvironment({this.type = EnvironmentType.dev});

  @override
  final EnvironmentType type;

  @override
  Map<String, String> get values => {};
}
