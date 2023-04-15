import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:fluent_sdk/src/app_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'mocks/test_class.dart';
import 'mocks/test_environment.dart';
import 'mocks/test_route.dart';
import 'mocks/test_route_2.dart';

void main() {
  final registry = AppRegistry();

  tearDown(() => GetIt.instance.reset());

  test('registerApi should register api', () async {
    registry.registerApi<TestClass>((_) => TestClass());

    expect(GetIt.instance<TestClass>(), isA<TestClass>());
  });

  test('registerApi should register lazy api', () async {
    registry.registerApi<TestClass>((_) => TestClass(), lazy: true);

    expect(GetIt.instance<TestClass>(), isA<TestClass>());
  });

  test('registerEnvironment  should register environment', () async {
    registry.registerEnvironment(TestEnvironment());

    expect(GetIt.instance<Environment>(), isA<TestEnvironment>());
  });

  test('registerRoute should register route in list of routes', () async {
    registry.registerRoute(const TestRoute());

    expect(GetIt.instance<List<Route>>(), isA<List<Route>>());
  });

  test(
      '''registerRoute when previous registered route should add route to current list of routes''',
      () async {
    GetIt.instance.allowReassignment = true;
    registry
      ..registerRoute(const TestRoute())
      ..registerRoute(const TestRoute2());

    expect(GetIt.instance<List<Route>>().length, 2);
  });
}
