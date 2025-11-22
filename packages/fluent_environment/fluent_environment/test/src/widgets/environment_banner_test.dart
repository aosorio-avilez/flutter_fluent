import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEnvironment extends Mock implements Environment {}

void main() {
  late MockEnvironment mockEnv;

  setUp(() {
    mockEnv = MockEnvironment();
  });

  testWidgets('should display banner when environment is NOT prod', (
    tester,
  ) async {
    // Arrange
    when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
    when(() => mockEnv.name).thenReturn('DEV');
    when(() => mockEnv.color).thenReturn(Colors.red);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false, // Importante: Apagado
        home: Scaffold(
          body: EnvironmentBanner(
            environment: mockEnv,
            child: const Text('Content'),
          ),
        ),
      ),
    );

    // Assert
    // 1. Verificamos que el Banner existe
    final bannerFinder = find.byType(Banner);
    expect(bannerFinder, findsOneWidget);

    // 2. Obtenemos la instancia del widget para inspeccionar sus propiedades
    final bannerWidget = tester.widget<Banner>(bannerFinder);

    // 3. Verificamos que la propiedad 'message' sea la correcta
    expect(bannerWidget.message, 'DEV');

    // Opcional: Verificamos el color también para ser exhaustivos
    expect(bannerWidget.color, Colors.red);
  });

  testWidgets('should NOT display banner when environment IS prod', (
    tester,
  ) async {
    // Arrange
    when(() => mockEnv.type).thenReturn(EnvironmentType.prod);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        // CORRECCIÓN CRÍTICA: Apagamos el banner de "DEBUG" aquí también
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: EnvironmentBanner(
            environment: mockEnv,
            child: const Text('Content'),
          ),
        ),
      ),
    );

    // Assert
    // Como apagamos el de debug y tu widget oculta el suyo en prod,
    // el resultado total debe ser 0 Banners.
    expect(find.byType(Banner), findsNothing);
    expect(find.text('Content'), findsOneWidget);
  });
}
