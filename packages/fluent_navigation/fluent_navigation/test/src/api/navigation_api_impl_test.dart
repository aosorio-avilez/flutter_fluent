import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    mockRoutes();
    await Fluent.build([NavigationModule(initialLocation: '/first')]);
    addTearDown(Fluent.reset);
  });

  testWidgets('verify navigateTo', (tester) async {
    await pumpAppRouter(tester);

    await tester.tap(find.byKey(const Key('navigateButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('secondPage')), findsOneWidget);
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

  testWidgets('verify pop', (tester) async {
    await pumpAppRouter(tester);

    await tester.tap(find.byKey(const Key('pushButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('popButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('firstPage')), findsOneWidget);
    expect(find.text('Hello from first page'), findsOneWidget);
  });
}

Future<void> pumpAppRouter(WidgetTester tester) async {
  final router = Fluent.get<NavigationApi>().router;

  await tester.pumpWidget(
    MaterialApp.router(
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
                  final result =
                      await Fluent.get<NavigationApi>().pushTo<bool>('second');

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
          body: ElevatedButton(
            key: const Key('popButton'),
            onPressed: () {
              Fluent.get<NavigationApi>().pop(true);
            },
            child: const Text('Go back to previous route'),
          ),
        );
      },
    ),
  ]);
}
