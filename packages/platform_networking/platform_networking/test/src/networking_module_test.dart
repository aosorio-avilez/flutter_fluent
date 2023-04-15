import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:platform_environment_api/platform_environment_api.dart';
import 'package:platform_networking/platform_networking.dart';
import 'package:platform_networking/src/environment_api_mock.dart';
import 'package:platform_networking/src/networking_api_impl.dart';
import 'package:platform_networking/src/rest_api_impl.dart';
import 'package:platform_networking_api/platform_networking_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class EnvironmentMock extends Mock implements Environment {}

void main() {
  test('verify networking module', () async {
    mockApi<EnvironmentApi>(EnvironmentApiMock());
    mockApi<Environment>(EnvironmentMock());

    when(() => getApi<EnvironmentApi>().getEnvironment())
        .thenReturn(getApi<Environment>());
    when(() => getApi<Environment>().values).thenReturn({'url': ''});

    Platform.build([NetworkingModule()]);

    expect(getApi<Dio>(), isA<Dio>());
    expect(getApi<RestApi>(), isA<RestApiImpl>());
    expect(getApi<NetworkingApi>(), isA<NetworkingApiImpl>());
  });
}
