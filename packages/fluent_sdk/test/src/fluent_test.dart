import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:get_it/get_it.dart'; // Necesario para verificaciones de bajo nivel
import 'package:test/test.dart';

import 'mocks/test_class.dart';
import 'mocks/test_class_2.dart';
import 'mocks/test_module.dart';

class ModuleA extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    registry.registerSingleton<String>((_) => 'ModuleA Ready');
  }
}

class ModuleB extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    if (!registry.isRegistered<String>()) {
      throw Exception('Race Condition Detected: ModuleA not ready!');
    }
    registry.registerSingleton<int>((_) => 1);
  }
}

void main() {
  tearDown(Fluent.reset);

  group('Fluent Orchestrator Tests', () {
    test('verify build modules registers dependencies', () async {
      await Fluent.build([TestModule()]);
      expect(Fluent.get<TestClass>(), isA<TestClass>());
    });

    test('verify build executes modules sequentially (A -> B)', () async {
      await Fluent.build([
        ModuleA(),
        ModuleB(),
      ]);

      expect(Fluent.get<String>(), 'ModuleA Ready');
      expect(Fluent.get<int>(), 1);
    });

    test('verify get returns specific instance registered via GetIt', () async {
      GetIt.instance.registerLazySingleton(TestClass.new);
      expect(Fluent.get<TestClass>(), isA<TestClass>());
    });

    test('verify mock overrides existing registration safely', () {
      // Arrange
      GetIt.instance.registerLazySingleton<TestClass>(TestClass.new);

      // Act
      Fluent.mock<TestClass>(TestClass2());

      // Assert
      expect(Fluent.get<TestClass>(), isA<TestClass2>());
    });

    test('verify mock locks container after registration (Safety Check)', () {
      GetIt.instance.registerLazySingleton<TestClass>(TestClass.new);

      Fluent.mock<TestClass>(TestClass2());

      expect(
        () => GetIt.instance.registerLazySingleton(TestClass.new),
        throwsA(isA<ArgumentError>()),
        reason:
            'Container should be locked (allowReassignment=false) after mock',
      );
    });

    test('verify reset clears all instances', () async {
      Fluent.mock<TestClass>(TestClass2());
      expect(Fluent.get<TestClass>(), isA<TestClass>());

      await Fluent.reset();

      expect(() => Fluent.get<TestClass>(), throwsA(isA<StateError>()));
    });
  });
}
