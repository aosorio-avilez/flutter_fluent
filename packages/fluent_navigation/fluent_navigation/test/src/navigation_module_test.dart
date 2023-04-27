import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:fluent_navigation/src/fluent_route.dart';
import 'package:fluent_navigation/src/navigation_module.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUp(() => addTearDown(Fluent.reset));

  test('verify navigation module', () async {
    await Fluent.build([NavigationModule()]);
    Fluent.mock<List<FluentRoute>>(<FluentRoute>[]);

    final api = Fluent.get<NavigationApi>();
    final internalApi = Fluent.get<InternalNavigationApi>();
    final router = Fluent.get<GoRouter>();

    expect(api, isA<NavigationApi>());
    expect(internalApi, isA<InternalNavigationApi>());
    expect(router, isA<GoRouter>());
  });

  testWidgets('verify navigate between routes', (tester) async {
    await Fluent.build([NavigationModule()]);
    Fluent.mock<List<FluentRoute>>(<FluentRoute>[
      const FluentRoute(
        'home',
        '/',
        initial: true,
        page: Scaffold(
          key: Key('home'),
        ),
      ),
      const FluentRoute(
        'test',
        '/test',
        page: Scaffold(
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

    await tester.pump();

    expect(find.byKey(const Key('test')), findsOneWidget);
  });

  testWidgets('verify navigate between routes with builder', (tester) async {
    await Fluent.build([NavigationModule()]);
    Fluent.mock<List<FluentRoute>>(<FluentRoute>[
      const FluentRoute(
        'home',
        '/',
        initial: true,
        page: Scaffold(
          key: Key('home'),
        ),
      ),
      FluentRoute(
        'test',
        '/test',
        builder: (p0, p1) {
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

    await tester.pump();

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
    Fluent.mock<List<FluentRoute>>(<FluentRoute>[
      const FluentRoute(
        'home',
        '/',
        initial: true,
        page: Scaffold(
          key: Key('home'),
        ),
      ),
      FluentRoute(
        'test',
        '/test',
        builder: (p0, p1) {
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

    await tester.pump();

    expect(find.byKey(const Key('test')), findsOneWidget);
  });
}
