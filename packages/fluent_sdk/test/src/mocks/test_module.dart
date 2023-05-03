import 'package:fluent_sdk/fluent_sdk.dart';

import 'test_class.dart';
import 'test_class_async.dart';

class TestModule extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    final testClassAsync = await TestClassAsync.build();
    registry
      ..registerSingleton<TestClass>((it) => TestClass())
      ..registerSingleton<TestClassAsync>((it) => testClassAsync);
  }
}
