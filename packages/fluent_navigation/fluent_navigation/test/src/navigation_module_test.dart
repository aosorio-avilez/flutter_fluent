import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => addTearDown(Fluent.reset));

  test('verify navigation module', () async {
    await Fluent.build([const NavigationModule()]);
    Fluent.mock<FluentRoutes>([]);

    final api = Fluent.get<NavigationApi>();
    final internalApi = Fluent.get<InternalNavigationApi>();
    final router = api.router;

    expect(api, isA<NavigationApi>());
    expect(internalApi, isA<InternalNavigationApi>());
    expect(router, isA<RouterConfig<Object>>());
  });

  testWidgets('verify navigate between routes', (tester) async {
    await Fluent.build([const NavigationModule()]);
    Fluent.mock<FluentRoutes>([
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

    final router = Fluent.get<NavigationApi>().router;

    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(
          splashFactory: NoSplash.splashFactory,
        ),
        routerConfig: router,
      ),
    );

    Fluent.get<NavigationApi>().navigateTo('test');

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('test')), findsOneWidget);
  });

  testWidgets('verify navigate between routes with builder', (tester) async {
    await Fluent.build([const NavigationModule()]);
    Fluent.mock<FluentRoutes>([
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

    final router = Fluent.get<NavigationApi>().router;

    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(
          splashFactory: NoSplash.splashFactory,
        ),
        routerConfig: router,
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
      ),
    ]);
    Fluent.mock<FluentRoutes>([
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

    final router = Fluent.get<NavigationApi>().router;

    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(
          splashFactory: NoSplash.splashFactory,
        ),
        routerConfig: router,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('test')), findsOneWidget);
  });

  testWidgets('verify refreshListenable', (tester) async {
    final listenable = ValueNotifier<bool>(false);
    await Fluent.build([
      NavigationModule(
        refreshListenable: listenable,
        redirect: (location) {
          if (listenable.value) {
            return '/test';
          }
          return null;
        },
      ),
    ]);
    Fluent.mock<FluentRoutes>([
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

    final router = Fluent.get<NavigationApi>().router;

    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(
          splashFactory: NoSplash.splashFactory,
        ),
        routerConfig: router,
      ),
    );

    expect(find.byKey(const Key('home')), findsOneWidget);

    listenable.value = true;
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('test')), findsOneWidget);
  });

  test('NavigationModule can be instantiated as const', () {
    const module = NavigationModule(
      initialLocation: '/home',
      optionURLReflectsImperativeAPIs: false,
    );
    expect(module, isA<NavigationModule>());
  });
}
