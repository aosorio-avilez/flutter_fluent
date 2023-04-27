import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class RestConfigMock extends Mock implements NetworkingConfig {}

void main() {
  test('verify networking module', () async {
    final config = RestConfigMock();
    when(() => config.baseUrl).thenReturn('');
    when(() => config.interceptors).thenReturn([]);

    await Fluent.build([NetworkingModule(config: config)]);

    expect(Fluent.get<Dio>(), isA<Dio>());
    expect(Fluent.get<NetworkingApi>(), isA<NetworkingApiImpl>());
  });
}
