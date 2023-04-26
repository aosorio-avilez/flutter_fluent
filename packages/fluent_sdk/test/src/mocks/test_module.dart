import 'package:fluent_sdk/fluent_sdk.dart';

import 'test_class.dart';

class TestModule extends FluentModule {
  @override
  void build(Registry registry) {
    registry.registerSingleton<TestClass>((it) => TestClass());
  }
}
