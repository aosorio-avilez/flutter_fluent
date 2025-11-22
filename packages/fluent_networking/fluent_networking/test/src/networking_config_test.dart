import 'package:fluent_networking/src/networking_config.dart';
import 'package:test/test.dart';

void main() {
  test('verify default networking config instance', () async {
    final config = NetworkingConfig();

    expect(config.baseUrl, isEmpty);
    expect(config.interceptors, isEmpty);
  });

  test('verify networking config instance', () async {
    final config = NetworkingConfig(
      baseUrl: 'https://google.com',
      interceptors: [],
      enableLog: true,
    );

    expect(config.baseUrl, 'https://google.com');
    expect(config.interceptors, isEmpty);
    expect(config.enableLog, true);
  });
}
