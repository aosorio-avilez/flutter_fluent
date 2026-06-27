import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/interceptors/networking_retry_interceptor.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockNetworkingConfig extends Mock implements NetworkingConfig {}

void main() {
  test('verify networking module builds correctly', () async {
    final config = MockNetworkingConfig();

    when(() => config.baseUrl).thenReturn('https://api.test');
    when(() => config.interceptors).thenReturn([]);
    when(() => config.enableLog).thenReturn(true);
    when(() => config.enableCurlLog).thenReturn(false);
    when(() => config.sensitiveHeaders).thenReturn({});
    when(() => config.sensitiveBodyKeys).thenReturn({});
    when(() => config.sensitiveQueryParams).thenReturn({});
    when(() => config.retryConfig).thenReturn(null);

    await Fluent.build([NetworkingModule(config: config)]);
    addTearDown(Fluent.reset);

    expect(Fluent.get<Dio>(), isA<Dio>());
    expect(Fluent.get<NetworkingApi>(), isA<NetworkingApiImpl>());
  });

  test('verify networking module registers curl interceptor', () async {
    const config = NetworkingConfig(
      baseUrl: 'https://api.test',
      enableCurlLog: true,
    );

    await Fluent.build([const NetworkingModule(config: config)]);
    addTearDown(Fluent.reset);

    final dio = Fluent.get<Dio>();
    final curlInterceptor = dio.interceptors
        .where((i) => i.runtimeType.toString() == 'NetworkingCurlInterceptor')
        .firstOrNull;

    expect(curlInterceptor, isNotNull);
  });

  test('verify networking module registers retry interceptor', () async {
    const retryConfig = RetryConfig(maxRetries: 5);
    const config = NetworkingConfig(
      baseUrl: 'https://api.test',
      retryConfig: retryConfig,
    );

    await Fluent.build([const NetworkingModule(config: config)]);
    addTearDown(Fluent.reset);

    final dio = Fluent.get<Dio>();
    final retryInterceptor = dio.interceptors
        .whereType<NetworkingRetryInterceptor>()
        .firstOrNull;

    expect(retryInterceptor, isNotNull);
    expect(retryInterceptor!.globalRetryConfig, retryConfig);
  });

  test('NetworkingModule can be instantiated as const', () {
    const config = NetworkingConfig(
      baseUrl: 'https://example.com',
      enableLog: true,
    );
    const module = NetworkingModule(config: config);
    expect(module, isA<NetworkingModule>());
  });
}
