import 'package:fluent_sdk/src/fluent_registry.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

import 'mocks/test_class.dart';
import 'mocks/test_class_2.dart';

void main() {
  final registry = FluentRegistry();

  setUp(() => GetIt.instance.reset());

  tearDown(() => GetIt.instance.reset());

  group('FluentRegistry Implementation Tests', () {
    test('registerLazySingleton should register lazy object', () {
      registry.registerLazySingleton<TestClass>((_) => TestClass());
      expect(GetIt.instance.isRegistered<TestClass>(), isTrue);
      expect(GetIt.instance<TestClass>(), isA<TestClass>());
    });

    test('registerSingleton should register immediate object', () {
      registry.registerSingleton<TestClass>((_) => TestClass());
      expect(GetIt.instance<TestClass>(), isA<TestClass>());
    });

    test('registerFactory should register factory object', () {
      registry.registerFactory<TestClass>((it) => TestClass());

      final instance1 = GetIt.instance<TestClass>();
      final instance2 = GetIt.instance<TestClass>();

      expect(identical(instance1, instance2), isFalse);
    });

    test('allowReassignment should enable overriding registrations', () {
      registry
        ..registerSingleton<TestClass>((it) => TestClass())
        ..allowReassignment(allow: true)
        ..registerSingleton<TestClass>((p0) => TestClass2());

      expect(GetIt.instance<TestClass>(), isA<TestClass2>());
    });

    test(
      'isRegistered should return true if instance is already registered',
      () {
        registry.registerSingleton<TestClass>((it) => TestClass());
        expect(registry.isRegistered<TestClass>(), isTrue);
      },
    );

    test('isRegistered should return false if instance is not registered', () {
      expect(registry.isRegistered<TestClass>(), isFalse);
    });
  });
}
