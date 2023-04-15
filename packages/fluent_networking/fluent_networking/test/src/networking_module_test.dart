import 'package:dio/dio.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/environment_api_mock.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:fluent_networking/src/rest_api_impl.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class EnvironmentMock extends Mock implements Environment {}

void main() {
  test('verify networking module', () async {
    mockApi<EnvironmentApi>(EnvironmentApiMock());
    mockApi<Environment>(EnvironmentMock());

    when(() => getApi<EnvironmentApi>().getEnvironment())
        .thenReturn(getApi<Environment>());
    when(() => getApi<Environment>().values).thenReturn({'url': ''});

    Fluent.build([NetworkingModule()]);

    expect(getApi<Dio>(), isA<Dio>());
    expect(getApi<RestApi>(), isA<RestApiImpl>());
    expect(getApi<NetworkingApi>(), isA<NetworkingApiImpl>());
  });
}
