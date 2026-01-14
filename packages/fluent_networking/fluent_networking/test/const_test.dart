import 'package:fluent_networking/fluent_networking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NetworkingModule can be instantiated as const', () {
    const config = NetworkingConfig(
      baseUrl: 'https://example.com',
      enableLog: true,
    );
    const module = NetworkingModule(config: config);
    expect(module, isA<NetworkingModule>());
  });
}
