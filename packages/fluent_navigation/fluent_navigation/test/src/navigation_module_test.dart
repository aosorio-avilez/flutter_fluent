import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:fluent_navigation/src/navigation_module.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('verify navigation module', () async {
    Fluent.build([NavigationModule()]);
    mockApi<List<Route>>(<Route>[]);

    final api = getApi<NavigationApi>();
    final internalApi = getApi<InternalNavigationApi>();
    final router = getApi<GoRouter>();

    expect(api, isA<NavigationApi>());
    expect(internalApi, isA<InternalNavigationApi>());
    expect(router, isA<GoRouter>());
  });

  testWidgets('verify navigate between routes', (tester) async {
    Fluent.build([NavigationModule()]);
    mockApi<List<Route>>(<Route>[
      const Route(
        'home',
        '/',
        initial: true,
        page: material.Scaffold(
          key: material.Key('home'),
        ),
      ),
      const Route(
        'test',
        '/test',
        page: material.Scaffold(
          key: material.Key('test'),
        ),
      ),
    ]);

    final config = getApi<NavigationApi>().getConfig();

    await tester.pumpWidget(
      material.MaterialApp.router(
        routerConfig: config,
      ),
    );

    getApi<NavigationApi>().navigateTo('test');

    await tester.pump();

    expect(find.byKey(const material.Key('test')), findsOneWidget);
  });

  testWidgets('verify navigate between routes with builder', (tester) async {
    Fluent.build([NavigationModule()]);
    mockApi<List<Route>>(<Route>[
      const Route(
        'home',
        '/',
        initial: true,
        page: material.Scaffold(
          key: material.Key('home'),
        ),
      ),
      Route(
        'test',
        '/test',
        builder: (p0, p1) {
          return const material.Scaffold(
            key: material.Key('test'),
          );
        },
      ),
    ]);

    final config = getApi<NavigationApi>().getConfig();

    await tester.pumpWidget(
      material.MaterialApp.router(
        routerConfig: config,
      ),
    );

    getApi<NavigationApi>().navigateTo('test');

    await tester.pump();

    expect(find.byKey(const material.Key('test')), findsOneWidget);
  });
}
