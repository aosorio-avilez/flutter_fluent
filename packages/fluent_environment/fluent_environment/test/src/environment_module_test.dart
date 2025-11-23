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
}
