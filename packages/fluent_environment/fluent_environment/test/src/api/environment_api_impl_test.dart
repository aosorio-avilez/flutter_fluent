import 'package:fluent_environment/src/api/environment_api_impl.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Definimos un Mock local para no depender de otros archivos de prueba
class MockEnvironment extends Mock implements Environment {}

void main() {
  test('verify environment getter returns the injected instance', () {
    // Arrange
    final mockEnv = MockEnvironment();

    // Act: Inyectamos el mock directamente (Constructor Injection)
    final api = EnvironmentApiImpl(mockEnv);

    // Assert: Verificamos que la API devuelva exactamente lo que le inyectamos
    expect(api.environment, equals(mockEnv));
  });
}
