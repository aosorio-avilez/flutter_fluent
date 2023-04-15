import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class RestConfigMock extends Mock implements NetworkingConfig {}

void main() {
  test('verify networking module', () async {
    final config = RestConfigMock();
    when(() => config.baseUrl).thenReturn('');
    when(() => config.interceptors).thenReturn([]);

    Fluent.build([NetworkingModule(config: config)]);

    expect(getApi<Dio>(), isA<Dio>());
    expect(getApi<NetworkingApi>(), isA<NetworkingApiImpl>());
  });
}
