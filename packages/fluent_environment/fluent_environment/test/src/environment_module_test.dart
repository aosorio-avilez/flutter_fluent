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

    expect(Fluent.get<EnvironmentApi>().environment, equals(mockEnv));
  });

  test('environment module with multiple environments', () async {
    final mockEnv1 = MockEnvironment();
    final mockEnv2 = MockEnvironment();

    await Fluent.build([
      EnvironmentModule(
        environment: mockEnv1,
        availableEnvironments: [mockEnv1, mockEnv2],
      ),
    ]);
    addTearDown(Fluent.reset);

    final api = Fluent.get<EnvironmentApi>();
    expect(api.availableEnvironments, containsAll([mockEnv1, mockEnv2]));
    expect(api.environment, equals(mockEnv1));
    expect(Fluent.get<Environment>(), equals(mockEnv1));

    api.updateEnvironment(mockEnv2);

    expect(api.environment, equals(mockEnv2));
    expect(Fluent.get<Environment>(), equals(mockEnv2));
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
  String get name => 'Test';

  @override
  Color get color => const Color(0xFF000000);

  @override
  EnvironmentType get type => EnvironmentType.dev;

  @override
  Map<String, String> get values => {};
}
