import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegistry extends Mock implements Registry {}

void main() {
  test('NetworkingModule registers dependencies lazily', () {
    final registry = MockRegistry();
    final module = NetworkingModule(config: const NetworkingConfig(baseUrl: 'https://example.com'));

    module.onCreate(registry);

    verify(() => registry.registerLazySingleton<Dio>(any())).called(1);
    verify(() => registry.registerLazySingleton<NetworkingApi>(any())).called(1);

    // It should NOT call registerSingleton
    verifyNever(() => registry.registerSingleton<Dio>(any()));
    verifyNever(() => registry.registerSingleton<NetworkingApi>(any()));
  });
}
