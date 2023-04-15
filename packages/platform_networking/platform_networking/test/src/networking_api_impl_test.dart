import 'package:flutter_test/flutter_test.dart';
import 'package:platform_networking/src/networking_api_impl.dart';
import 'package:platform_networking/src/rest_api_mock.dart';
import 'package:platform_networking_api/platform_networking_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

void main() {
  test('verify restApi', () async {
    mockApi<RestApi>(RestApiMock());

    final api = NetworkingApiImpl();

    expect(api.restApi, isA<RestApi>());
  });
}
