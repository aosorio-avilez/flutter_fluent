import 'dart:ui';

import 'package:fluent_environment/fluent_environment.dart';
import 'package:fluent_environment/src/api/environment_api_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEnvironment extends Mock implements Environment {}

void main() {
  test('environment module should register dependencies correctly', () async {
    final mockEnv = MockEnvironment();

    await Fluent.build([EnvironmentModule(environment: mockEnv)]);
    addTearDown(Fluent.reset);

    expect(Fluent.get<Environment>(), isA<Environment>());
    expect(Fluent.get<EnvironmentApi>(), isA<EnvironmentApiImpl>());

    // Verificamos que la instancia inyectada sea la misma
    expect(Fluent.get<EnvironmentApi>().environment, equals(mockEnv));
  });

  test('EnvironmentModule can be instantiated as const', () {
    const env = TestEnvironment();
    const module = EnvironmentModule(environment: env);
    expect(module, isA<EnvironmentModule>());
  });
}

class TestEnvironment extends Environment {
  const TestEnvironment();

  @override
  String get name => throw UnimplementedError();

  @override
  Color get color => throw UnimplementedError();

  @override
  EnvironmentType get type => throw UnimplementedError();

  @override
  Map<String, String> get values => throw UnimplementedError();
}
