import 'package:fluent_sdk/src/fluent_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'mocks/test_class.dart';
import 'mocks/test_class_2.dart';

void main() {
  final registry = FluentRegistry();

  setUp(() => GetIt.instance.reset());

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

  test('allowReassignment should allow to reassign objects', () async {
    registry
      ..registerSingleton<TestClass>((it) => TestClass())
      ..allowReassignment(allow: true)
      ..registerSingleton<TestClass>((p0) => TestClass2());

    expect(GetIt.instance<TestClass>(), isA<TestClass>());
  });

  test('isRegistered should return true if instance is already registered',
      () async {
    registry.registerSingleton<TestClass>((it) => TestClass());

    final isRegistered = registry.isRegistered<TestClass>();

    expect(isRegistered, isTrue);
  });

  test('isRegistered should return false if instance is not registered',
      () async {
    final isRegistered = registry.isRegistered<TestClass>();

    expect(isRegistered, isFalse);
  });
}
