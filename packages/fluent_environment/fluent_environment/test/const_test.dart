import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EnvironmentModule can be instantiated as const', () {
    const env = Environment.production;
    const module = EnvironmentModule(environment: env);
    expect(module, isA<EnvironmentModule>());
  });
}
