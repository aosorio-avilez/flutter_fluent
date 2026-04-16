import 'package:fluent_networking/fluent_networking.dart';
import 'package:test/test.dart';

void main() {
  test('verify default networking config instance', () async {
    const config = NetworkingConfig();

    expect(config.baseUrl, isEmpty);
    expect(config.interceptors, isEmpty);
    expect(config.retryConfig, isNull);
  });

  test('verify networking config instance', () async {
    const retryConfig = RetryConfig(maxRetries: 5);
    const config = NetworkingConfig(
      baseUrl: 'https://google.com',
      enableLog: true,
      retryConfig: retryConfig,
    );

    expect(config.baseUrl, 'https://google.com');
    expect(config.interceptors, isEmpty);
    expect(config.enableLog, true);
    expect(config.retryConfig, retryConfig);
  });
}
