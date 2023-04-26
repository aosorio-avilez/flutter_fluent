import 'package:fluent_sdk/src/fluent_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'mocks/test_class.dart';
import 'mocks/test_class_2.dart';

void main() {
  final registry = FluentRegistry();

  tearDown(() => GetIt.instance.reset());

  test('registerLazySingleton should register lazy object', () async {
    registry.registerLazySingleton<TestClass>((_) => TestClass());

    expect(GetIt.instance<TestClass>(), isA<TestClass>());
  });

  test('registerSingleton should register object', () async {
    registry.registerSingleton<TestClass>((_) => TestClass());

    expect(GetIt.instance<TestClass>(), isA<TestClass>());
  });

  test('registerFactory should register factory object', () async {
    registry.registerFactory<TestClass>((it) => TestClass());

    expect(GetIt.instance<TestClass>(), isA<TestClass>());
  });

  test('allowReassignment should allow to eeassign objects', () async {
    registry
      ..registerSingleton<TestClass>((it) => TestClass())
      ..allowReassignment(allow: true)
      ..registerSingleton<TestClass>((p0) => TestClass2());

    expect(GetIt.instance<TestClass>(), isA<TestClass>());
  });
}
