import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestModule extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    registry.registerRoute(
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          return const Scaffold();
        },
      ),
    );
  }
}

class TestModule2 extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    registry
      ..registerRoute(
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) {
            return const Scaffold();
          },
        ),
      )
      ..registerRoute(
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) {
            return const Scaffold();
          },
        ),
      );
  }
}

void main() {
  setUp(() => addTearDown(Fluent.reset));

  test('registerRoute should register route in list of routes', () async {
    await Fluent.build([TestModule()]);

    expect(Fluent.get<List<GoRoute>>(), isA<List<GoRoute>>());
  });

  test(
      '''registerRoute when previous registered route should add route to current list of routes''',
      () async {
    await Fluent.build([TestModule2()]);

    expect(Fluent.get<List<GoRoute>>().length, 2);
  });
}
