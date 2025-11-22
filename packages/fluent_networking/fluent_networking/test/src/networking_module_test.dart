import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
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

    await Fluent.build([NetworkingModule(config: config)]);
    addTearDown(Fluent.reset);

    expect(Fluent.get<Dio>(), isA<Dio>());
    expect(Fluent.get<NetworkingApi>(), isA<NetworkingApiImpl>());
  });
}
