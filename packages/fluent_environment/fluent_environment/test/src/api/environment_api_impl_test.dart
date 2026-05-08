import 'package:fluent_environment/src/api/environment_api_impl.dart';
import 'package:fluent_environment/src/widgets/environment_inspector.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEnvironment extends Mock implements Environment {}

void main() {
  test('verify environment getter returns the injected instance', () {
    final mockEnv = MockEnvironment();
    final api = EnvironmentApiImpl(mockEnv, [mockEnv]);

    expect(api.environment, equals(mockEnv));
  });

  test('updateEnvironment should update the current environment', () {
    final mockEnv1 = MockEnvironment();
    final mockEnv2 = MockEnvironment();
    final api = EnvironmentApiImpl(mockEnv1, [mockEnv1, mockEnv2]);

    expect(api.environment, equals(mockEnv1));

    api.updateEnvironment(mockEnv2);

    expect(api.environment, equals(mockEnv2));
  });

  test('environmentNotifier should emit new environment on update', () {
    final mockEnv1 = MockEnvironment();
    final mockEnv2 = MockEnvironment();
    final api = EnvironmentApiImpl(mockEnv1, [mockEnv1, mockEnv2]);
    var notified = false;

    api.environmentNotifier.addListener(() {
      notified = true;
    });

    api.updateEnvironment(mockEnv2);

    expect(notified, isTrue);
    expect(api.environmentNotifier.value, equals(mockEnv2));
  });

  testWidgets(
    'showInspector should display EnvironmentInspector in bottom sheet',
    (tester) async {
      final mockEnv = MockEnvironment();
      when(() => mockEnv.name).thenReturn('Test');
      when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
      when(() => mockEnv.color).thenReturn(Colors.red);
      when(() => mockEnv.values).thenReturn({});
      when(() => mockEnv.sensitiveKeys).thenReturn({});

      final api = EnvironmentApiImpl(mockEnv, [mockEnv]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => api.showInspector(context),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(EnvironmentInspector), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    },
  );

  testWidgets('showInspector should use navigatorKey if provided', (
    tester,
  ) async {
    final mockEnv = MockEnvironment();
    when(() => mockEnv.name).thenReturn('Test');
    when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
    when(() => mockEnv.color).thenReturn(Colors.red);
    when(() => mockEnv.values).thenReturn({});
    when(() => mockEnv.sensitiveKeys).thenReturn({});

    final navigatorKey = GlobalKey<NavigatorState>();
    final api = EnvironmentApiImpl(mockEnv, [mockEnv]);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: Text('Home')),
      ),
    );

    // ignore: unawaited_futures
    api.showInspector(
      navigatorKey.currentContext!,
      navigatorKey: navigatorKey,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(EnvironmentInspector), findsOneWidget);
  });
}
