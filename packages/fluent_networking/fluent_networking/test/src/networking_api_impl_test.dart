import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:fluent_networking/src/rest_api_mock.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('verify restApi', () async {
    mockApi<RestApi>(RestApiMock());

    final api = NetworkingApiImpl();

    expect(api.restApi, isA<RestApi>());
  });
}
