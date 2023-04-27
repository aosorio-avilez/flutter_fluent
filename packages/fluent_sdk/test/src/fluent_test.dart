import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

import 'mocks/test_class.dart';
import 'mocks/test_class_2.dart';
import 'mocks/test_module.dart';

void main() {
  setUp(() => GetIt.instance.reset());

  test('verify build modules', () async {
    await Fluent.build([TestModule()]);

    expect(Fluent.get<TestClass>(), isA<TestClass>());
  });

  test('verify get return specific instance', () async {
    GetIt.instance.registerLazySingleton(TestClass.new);

    expect(Fluent.get<TestClass>(), isA<TestClass>());
  });

  test('verify mock register a new instance of the same type', () async {
    GetIt.instance.registerLazySingleton(TestClass.new);

    Fluent.mock<TestClass>(TestClass2());

    expect(Fluent.get<TestClass>(), isA<TestClass2>());
  });

  test('verify cannot register a new instance of the same type after mock it',
      () async {
    GetIt.instance.registerLazySingleton(TestClass.new);

    Fluent.mock<TestClass>(TestClass2());

    try {
      GetIt.instance.registerLazySingleton(TestClass.new);
    } catch (e) {
      expect(e, isA<ArgumentError>());
    }
  });
}
