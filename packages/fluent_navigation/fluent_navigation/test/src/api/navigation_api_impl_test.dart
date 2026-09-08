import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    mockRoutes();
    await Fluent.build([const NavigationModule(initialLocation: '/first')]);
    addTearDown(Fluent.reset);
  });

  testWidgets('verify navigateTo', (tester) async {
    await pumpAppRouter(tester);

    await tester.tap(find.byKey(const Key('navigateButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('secondPage')), findsOneWidget);
  });

  testWidgets('verify replaceWith', (tester) async {
    await pumpAppRouter(tester);

    await tester.tap(find.byKey(const Key('replaceButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('secondPage')), findsOneWidget);
    expect(Fluent.get<NavigationApi>().canPop(), isFalse);
  });

  testWidgets('verify pushTo', (tester) async {
    await pumpAppRouter(tester);

    await tester.tap(find.byKey(const Key('pushButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('secondPage')), findsOneWidget);
  });

  test('verify router', () async {
    final router = Fluent.get<NavigationApi>().router;

    expect(router, isA<RouterConfig<Object>>());
  });

  test('verify navigatorKey', () async {
    final navigatorKey = Fluent.get<NavigationApi>().navigatorKey;

    expect(navigatorKey, isA<GlobalKey<NavigatorState>>());
    expect(navigatorKey, equals(rootNavigatorKey));
  });

  testWidgets('verify canPop returns false on initial route (root)', (
    tester,
  ) async {
    await pumpAppRouter(tester);

    final canPop = Fluent.get<NavigationApi>().canPop();

    expect(canPop, isFalse);
  });

  testWidgets('verify canPop returns true after pushing a route', (
    tester,
  ) async {
    await pumpAppRouter(tester);

    await tester.tap(find.byKey(const Key('pushButton')));
    await tester.pumpAndSettle();

    final canPop = Fluent.get<NavigationApi>().canPop();

    expect(canPop, isTrue);
  });

  testWidgets('verify pop is safe at root (does nothing if canPop is false)', (
    tester,
  ) async {
    await pumpAppRouter(tester);

    Fluent.get<NavigationApi>().pop<void>();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('firstPage')), findsOneWidget);
  });

  testWidgets('verify pop', (tester) async {
    await pumpAppRouter(tester);

    await tester.tap(find.byKey(const Key('pushButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('popButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('firstPage')), findsOneWidget);
    expect(find.text('Hello from first page'), findsOneWidget);
  });

  testWidgets('verify popUntil', (tester) async {
    await pumpAppRouter(tester);

    await tester.tap(find.byKey(const Key('pushButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pushThirdButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('thirdPage')), findsOneWidget);

    await tester.tap(find.byKey(const Key('popUntilButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('firstPage')), findsOneWidget);
  });

  test('verify routeListenable returns a Listenable', () async {
    final listenable = Fluent.get<NavigationApi>().routeListenable;

    expect(listenable, isA<Listenable>());
  });

  testWidgets(
    'verify currentPath and currentLocation on initial route and transitions',
    (tester) async {
      await pumpAppRouter(tester);

      final api = Fluent.get<NavigationApi>();

      expect(api.currentPath, equals('/first'));
      expect(api.currentLocation, equals('/first'));

      api.navigateTo('second', queryParams: {'filter': 'active'});
      await tester.pumpAndSettle();

      expect(api.currentPath, equals('/second'));
      expect(api.currentLocation, equals('/second?filter=active'));

      api.navigateTo('third');
      await tester.pumpAndSettle();

      expect(api.currentPath, equals('/third'));
      expect(api.currentLocation, equals('/third'));

      api.navigateTo('first');
      await tester.pumpAndSettle();

      expect(api.currentPath, equals('/first'));
      expect(api.currentLocation, equals('/first'));

      // Imperative pushTo
      await tester.tap(find.byKey(const Key('pushButton')));
      await tester.pumpAndSettle();

      expect(api.currentPath, equals('/second'));

      // Imperative pop
      await tester.tap(find.byKey(const Key('popButton')));
      await tester.pumpAndSettle();

      expect(api.currentPath, equals('/first'));
    },
  );

  testWidgets('verify routeListenable notifies on route change', (
    tester,
  ) async {
    await pumpAppRouter(tester);

    final api = Fluent.get<NavigationApi>();
    var notifications = 0;
    void listener() => notifications++;

    api.routeListenable.addListener(listener);
    addTearDown(() => api.routeListenable.removeListener(listener));

    expect(notifications, equals(0));

    await tester.tap(find.byKey(const Key('pushButton')));
    await tester.pumpAndSettle();

    expect(notifications, greaterThan(0));

    final countBeforePop = notifications;
    await tester.tap(find.byKey(const Key('popButton')));
    await tester.pumpAndSettle();

    expect(notifications, greaterThan(countBeforePop));
  });
}

Future<void> pumpAppRouter(WidgetTester tester) async {
  final router = Fluent.get<NavigationApi>().router;

  await tester.pumpWidget(
    MaterialApp.router(
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
      ),
      routerConfig: router,
    ),
  );
}

void mockRoutes() {
  Fluent.mock<FluentRoutes>([
    GoRoute(
      name: 'first',
      path: '/first',
      builder: (context, state) {
        return Scaffold(
          key: const Key('firstPage'),
          body: Column(
            children: [
              ElevatedButton(
                key: const Key('navigateButton'),
                onPressed: () {
                  Fluent.get<NavigationApi>().navigateTo('second');
                },
                child: const Text('Navigate to second page'),
              ),
              ElevatedButton(
                key: const Key('pushButton'),
                onPressed: () async {
                  final result = await Fluent.get<NavigationApi>().pushTo<bool>(
                    'second',
                  );

                  if (result ?? false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hello from first page'),
                      ),
                    );
                  }
                },
                child: const Text('Push to second page'),
              ),
              ElevatedButton(
                key: const Key('replaceButton'),
                onPressed: () async {
                  await Fluent.get<NavigationApi>().replaceWith('second');
                },
                child: const Text('Replace with second page'),
              ),
            ],
          ),
        );
      },
    ),
    GoRoute(
      name: 'second',
      path: '/second',
      builder: (context, state) {
        return Scaffold(
          key: const Key('secondPage'),
          body: Column(
            children: [
              ElevatedButton(
                key: const Key('popButton'),
                onPressed: () {
                  Fluent.get<NavigationApi>().pop(true);
                },
                child: const Text('Go back to previous route'),
              ),
              ElevatedButton(
                key: const Key('pushThirdButton'),
                onPressed: () async {
                  await Fluent.get<NavigationApi>().pushTo<void>('third');
                },
                child: const Text('Go to third route'),
              ),
            ],
          ),
        );
      },
    ),
    GoRoute(
      name: 'third',
      path: '/third',
      builder: (context, state) {
        return Scaffold(
          key: const Key('thirdPage'),
          body: ElevatedButton(
            key: const Key('popUntilButton'),
            onPressed: () {
              Fluent.get<NavigationApi>().popUntil('first');
            },
            child: const Text('Pop until first route'),
          ),
        );
      },
    ),
  ]);
}
