import 'package:fluent_environment/src/api/environment_api_impl.dart';
import 'package:fluent_environment/src/widgets/environment_inspector.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Definimos un Mock local para no depender de otros archivos de prueba
class MockEnvironment extends Mock implements Environment {}

void main() {
  test('verify environment getter returns the injected instance', () {
    // Arrange
    final mockEnv = MockEnvironment();

    // Act: Inyectamos el mock directamente (Constructor Injection)
    final api = EnvironmentApiImpl(mockEnv);

    // Assert: Verificamos que la API devuelva exactamente lo que le inyectamos
    expect(api.environment, equals(mockEnv));
  });

  testWidgets(
    'showInspector should display EnvironmentInspector in bottom sheet',
    (tester) async {
      // Arrange
      final mockEnv = MockEnvironment();
      when(() => mockEnv.name).thenReturn('Test');
      when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
      when(() => mockEnv.color).thenReturn(Colors.red);
      when(() => mockEnv.values).thenReturn({});
      when(() => mockEnv.sensitiveKeys).thenReturn({});

      final api = EnvironmentApiImpl(mockEnv);

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

      // Act
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(find.byType(EnvironmentInspector), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    },
  );

  testWidgets('showInspector should use navigatorKey if provided', (
    tester,
  ) async {
    // Arrange
    final mockEnv = MockEnvironment();
    when(() => mockEnv.name).thenReturn('Test');
    when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
    when(() => mockEnv.color).thenReturn(Colors.red);
    when(() => mockEnv.values).thenReturn({});
    when(() => mockEnv.sensitiveKeys).thenReturn({});

    final navigatorKey = GlobalKey<NavigatorState>();
    final api = EnvironmentApiImpl(mockEnv);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: Text('Home')),
      ),
    );

    // Act
    // ignore: unawaited_futures
    api.showInspector(
      // This context is outside the navigator (root context)
      navigatorKey.currentContext!,
      navigatorKey: navigatorKey,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Assert
    expect(find.byType(EnvironmentInspector), findsOneWidget);
  });
}
