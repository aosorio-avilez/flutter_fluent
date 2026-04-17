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

  testWidgets('should display environment details', (tester) async {
    // Arrange
    when(() => mockEnv.name).thenReturn('Development');
    when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
    when(() => mockEnv.color).thenReturn(Colors.blue);
    when(() => mockEnv.values).thenReturn({
      'api_url': 'https://api.dev.example.com',
      'api_key': 'dev_key_123',
    });

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnvironmentInspector(environment: mockEnv),
        ),
      ),
    );

    // Assert
    expect(find.text('Development'), findsOneWidget);
    expect(find.text('DEV'), findsOneWidget);
    expect(find.text('Configuration Values'), findsOneWidget);
    expect(find.text('api_url'), findsOneWidget);
    expect(find.text('https://api.dev.example.com'), findsOneWidget);
    expect(find.text('api_key'), findsOneWidget);
    expect(find.text('dev_key_123'), findsOneWidget);
  });

  testWidgets('should display empty message when no values', (tester) async {
    // Arrange
    when(() => mockEnv.name).thenReturn('Staging');
    when(() => mockEnv.type).thenReturn(EnvironmentType.stg);
    when(() => mockEnv.color).thenReturn(Colors.orange);
    when(() => mockEnv.values).thenReturn({});

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnvironmentInspector(environment: mockEnv),
        ),
      ),
    );

    // Assert
    expect(find.text('Staging'), findsOneWidget);
    expect(find.text('STG'), findsOneWidget);
    expect(find.text('No configuration values defined.'), findsOneWidget);
  });
}
