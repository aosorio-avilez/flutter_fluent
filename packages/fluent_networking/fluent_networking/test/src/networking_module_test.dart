import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:fluent_networking/src/rest_api_impl.dart';
import 'package:fluent_networking/src/rest_config.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class RestConfigMock extends Mock implements RestConfig {}

void main() {
  test('verify networking module', () async {
    mockApi<RestConfig>(RestConfigMock());

    when(() => getApi<RestConfig>().baseUrl).thenReturn('');
    when(() => getApi<RestConfig>().interceptors).thenReturn([]);

    Fluent.build([NetworkingModule()]);

    expect(getApi<Dio>(), isA<Dio>());
    expect(getApi<RestApi>(), isA<RestApiImpl>());
    expect(getApi<NetworkingApi>(), isA<NetworkingApiImpl>());
  });
}
