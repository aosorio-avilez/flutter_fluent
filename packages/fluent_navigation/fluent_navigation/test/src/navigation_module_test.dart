import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:fluent_navigation/src/navigation_module.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUp(() => addTearDown(Fluent.reset));

  test('verify navigation module', () async {
    await Fluent.build([NavigationModule()]);
    Fluent.mock<List<GoRoute>>(<GoRoute>[]);

    final api = Fluent.get<NavigationApi>();
    final internalApi = Fluent.get<InternalNavigationApi>();
    final router = Fluent.get<GoRouter>();

    expect(api, isA<NavigationApi>());
    expect(internalApi, isA<InternalNavigationApi>());
    expect(router, isA<GoRouter>());
  });

  testWidgets('verify navigate between routes', (tester) async {
    await Fluent.build([NavigationModule(initialLocation: '/')]);
    Fluent.mock<List<GoRoute>>(<GoRoute>[
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const Scaffold(
          key: Key('home'),
        ),
      ),
      GoRoute(
        name: 'test',
        path: '/test',
        builder: (context, state) => const Scaffold(
          key: Key('test'),
        ),
      ),
    ]);

    final config = Fluent.get<NavigationApi>().getConfig();

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: config,
      ),
    );

    Fluent.get<NavigationApi>().navigateTo('test');

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('test')), findsOneWidget);
  });

  testWidgets('verify navigate between routes with builder', (tester) async {
    await Fluent.build([NavigationModule()]);
    Fluent.mock<List<GoRoute>>(<GoRoute>[
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const Scaffold(
          key: Key('home'),
        ),
      ),
      GoRoute(
        name: 'test',
        path: '/test',
        builder: (context, state) {
          return const Scaffold(
            key: Key('test'),
          );
        },
      ),
    ]);

    final config = Fluent.get<NavigationApi>().getConfig();

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: config,
      ),
    );

    Fluent.get<NavigationApi>().navigateTo('test');

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('test')), findsOneWidget);
  });

  testWidgets('verify redirect', (tester) async {
    await Fluent.build([
      NavigationModule(
        redirect: (location) {
          if (location == '/') {
            return '/test';
          }
          return null;
        },
      )
    ]);
    Fluent.mock<List<GoRoute>>(<GoRoute>[
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const Scaffold(
          key: Key('home'),
        ),
      ),
      GoRoute(
        name: 'test',
        path: '/test',
        builder: (context, state) {
          return const Scaffold(
            key: Key('test'),
          );
        },
      ),
    ]);

    final config = Fluent.get<NavigationApi>().getConfig();

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: config,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('test')), findsOneWidget);
  });
}
