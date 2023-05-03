import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestModule extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    registry.registerRoute(const FluentRoute('home', '/', page: Scaffold()));
  }
}

class TestModule2 extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    registry
      ..registerRoute(const FluentRoute('home', '/', page: Scaffold()))
      ..registerRoute(const FluentRoute('login', '/login', page: Scaffold()));
  }
}

void main() {
  setUp(() => addTearDown(Fluent.reset));

  test('registerRoute should register route in list of routes', () async {
    await Fluent.build([TestModule()]);

    expect(Fluent.get<List<FluentRoute>>(), isA<List<FluentRoute>>());
  });

  test(
      '''registerRoute when previous registered route should add route to current list of routes''',
      () async {
    await Fluent.build([TestModule2()]);

    expect(Fluent.get<List<FluentRoute>>().length, 2);
  });
}
