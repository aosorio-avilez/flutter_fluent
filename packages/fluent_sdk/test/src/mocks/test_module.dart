import 'package:fluent_sdk/fluent_sdk.dart';

import 'test_class.dart';

class TestModule extends Module {
  TestModule({super.testMode = false});

  @override
  void build(Registry registry, {bool testMode = false}) {
    registry.registerApi<TestClass>((it) => TestClass());
  }
}
