import 'package:dio/dio.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockNetworkingConfig extends Mock implements NetworkingConfig {}

class MockLoggerApi extends Mock implements LoggerApi {}

void main() {
  test('verify networking module builds correctly', () async {
    final config = MockNetworkingConfig();
    final loggerApi = MockLoggerApi();

    when(() => config.baseUrl).thenReturn('https://api.test');
    when(() => config.interceptors).thenReturn([]);
    when(() => config.enableLog).thenReturn(true);
    when(() => config.sensitiveHeaders).thenReturn({});
    when(() => config.sensitiveBodyKeys).thenReturn({});

    Fluent.mock<LoggerApi>(loggerApi);
    await Fluent.build([NetworkingModule(config: config)]);
    addTearDown(Fluent.reset);

    expect(Fluent.get<Dio>(), isA<Dio>());
    expect(Fluent.get<NetworkingApi>(), isA<NetworkingApiImpl>());
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
