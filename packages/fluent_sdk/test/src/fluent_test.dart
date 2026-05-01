import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

import 'mocks/test_class.dart';
import 'mocks/test_module.dart';

void main() {
  setUp(GetIt.instance.reset);

  group('Fluent Tests', () {
    test('mock should register mock instance', () {
      Fluent.mock<String>('mock');

      expect(Fluent.get<String>(), 'mock');
    });

    test('build should register modules', () async {
      await Fluent.build([TestModule()]);

      expect(Fluent.get<TestClass>(), isA<TestClass>());
    });

    test('reset should clear modules and registry', () async {
      await Fluent.build([TestModule()]);
      await Fluent.reset();

      expect(() => Fluent.get<TestClass>(), throwsStateError);
    });

    test('mock should allow re-registration', () {
      Fluent.mock<int>(1);
      Fluent.mock<int>(2);

      expect(Fluent.get<int>(), 2);
    });
  });
}
