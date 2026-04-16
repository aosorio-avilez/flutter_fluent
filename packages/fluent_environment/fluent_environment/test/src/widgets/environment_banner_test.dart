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
    final bannerFinder = find.byType(Banner);
    expect(bannerFinder, findsOneWidget);

    final bannerWidget = tester.widget<Banner>(bannerFinder);
    expect(bannerWidget.message, 'DEV');
    expect(bannerWidget.color, Colors.red);
    expect(bannerWidget.location, BannerLocation.bottomEnd);

    // Check Semantics
    final semanticsFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'Environment: DEV',
    );
    expect(semanticsFinder, findsOneWidget);
  });

  testWidgets('should respect custom banner location', (tester) async {
    // Arrange
    when(() => mockEnv.type).thenReturn(EnvironmentType.stg);
    when(() => mockEnv.name).thenReturn('STG');
    when(() => mockEnv.color).thenReturn(Colors.orange);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: EnvironmentBanner(
            environment: mockEnv,
            location: BannerLocation.topStart,
            child: const Text('Content'),
          ),
        ),
      ),
    );

    // Assert
    final bannerFinder = find.byType(Banner);
    expect(bannerFinder, findsOneWidget);

    final bannerWidget = tester.widget<Banner>(bannerFinder);
    expect(bannerWidget.location, BannerLocation.topStart);
  });

  testWidgets('should NOT display banner when environment IS prod', (
    tester,
  ) async {
    // Arrange
    when(() => mockEnv.type).thenReturn(EnvironmentType.prod);

    // Act
    await tester.pumpWidget(
      MaterialApp(
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
    expect(find.byType(Banner), findsNothing);
    expect(find.text('Content'), findsOneWidget);
  });

  testWidgets('should use default text style when none is provided', (
    tester,
  ) async {
    // Arrange
    when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
    when(() => mockEnv.name).thenReturn('DEV');
    when(() => mockEnv.color).thenReturn(Colors.red);

    // Act
    await tester.pumpWidget(
      MaterialApp(
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
    final bannerWidget = tester.widget<Banner>(find.byType(Banner));
    expect(bannerWidget.textStyle.fontSize, 10.2);
    expect(bannerWidget.textStyle.fontWeight, FontWeight.w900);
    expect(bannerWidget.textStyle.height, 1);
  });

  testWidgets('should NOT leak directionality to child', (tester) async {
    // Arrange
    when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
    when(() => mockEnv.name).thenReturn('DEV');
    when(() => mockEnv.color).thenReturn(Colors.red);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: EnvironmentBanner(
              environment: mockEnv,
              child: Builder(
                builder: (context) {
                  return Text(Directionality.of(context).name);
                },
              ),
            ),
          ),
        ),
      ),
    );

    // Assert
    // If the bug exists, it will find 'ltr' because EnvironmentBanner
    // wraps the child in Directionality(textDirection: TextDirection.ltr).
    // We expect it to be 'rtl'.
    expect(find.text('rtl'), findsOneWidget);
  });

  testWidgets('should use custom text style when provided', (tester) async {
    // Arrange
    when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
    when(() => mockEnv.name).thenReturn('DEV');
    when(() => mockEnv.color).thenReturn(Colors.red);

    const customStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.blue,
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: EnvironmentBanner(
            environment: mockEnv,
            textStyle: customStyle,
            child: const Text('Content'),
          ),
        ),
      ),
    );

    // Assert
    final bannerWidget = tester.widget<Banner>(find.byType(Banner));
    expect(bannerWidget.textStyle.fontSize, 20);
    expect(bannerWidget.textStyle.fontWeight, FontWeight.bold);
    expect(bannerWidget.textStyle.color, Colors.blue);
  });
}
