import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Fluent.build([NavigationModule()]);
    addTearDown(Fluent.reset);
  });

  test('verify getRegisteredRoutes return registered routes', () async {
    Fluent.mock<FluentRoutes>([
      GoRoute(
        name: 'test',
        path: '/path',
        builder: (context, state) => const Scaffold(),
      )
    ]);
    final internalApi = Fluent.get<InternalNavigationApi>();

    final registeredRoutes = internalApi.getRegisteredRoutes();

    expect(registeredRoutes.length, 1);
  });
}
