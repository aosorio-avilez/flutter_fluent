import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_navigation/src/api/internal_navigation_api.dart';
import 'package:platform_navigation/src/navigation_module.dart';
import 'package:platform_navigation_api/platform_navigation_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

void main() {
  test('verify navigation module', () async {
    Platform.build([NavigationModule()]);
    mockApi<List<Route>>(<Route>[]);

    final api = getApi<NavigationApi>();
    final internalApi = getApi<InternalNavigationApi>();
    final router = getApi<GoRouter>();

    expect(api, isA<NavigationApi>());
    expect(internalApi, isA<InternalNavigationApi>());
    expect(router, isA<GoRouter>());
  });

  testWidgets('verify navigate between routes', (tester) async {
    Platform.build([NavigationModule()]);
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
    Platform.build([NavigationModule()]);
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
