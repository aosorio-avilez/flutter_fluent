import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/environment_api_mock.dart';

class MockEnvironment extends Mock implements Environment {}

class BuildContextFake extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(BuildContextFake());
  });

  late MockEnvironment mockEnv;
  late EnvironmentApiMock mockEnvApi;

  setUp(() {
    mockEnv = MockEnvironment();
    mockEnvApi = EnvironmentApiMock();

    Fluent.mock<EnvironmentApi>(mockEnvApi);
  });

  tearDown(() async {
    await Fluent.reset();
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

  testWidgets(
    'should call showInspector on long press when enableInspector is true',
    (
      tester,
    ) async {
      // Arrange
      when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
      when(() => mockEnv.name).thenReturn('DEV');
      when(() => mockEnv.color).thenReturn(Colors.red);
      when(() => mockEnvApi.environment).thenReturn(mockEnv);
      when(() => mockEnvApi.showInspector(any())).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: EnvironmentBanner(
              enableInspector: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(Banner));

      // Assert
      verify(() => mockEnvApi.showInspector(any())).called(1);
    },
  );

  testWidgets('should apply custom text style', (tester) async {
    // Arrange
    const textStyle = TextStyle(fontSize: 20, color: Colors.blue);
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
            textStyle: textStyle,
            child: const Text('Content'),
          ),
        ),
      ),
    );

    // Assert
    final bannerWidget = tester.widget<Banner>(find.byType(Banner));
    expect(bannerWidget.textStyle, textStyle);
  });

  testWidgets('should NOT override child directionality', (tester) async {
    // Arrange
    when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
    when(() => mockEnv.name).thenReturn('DEV');
    when(() => mockEnv.color).thenReturn(Colors.red);

    TextDirection? capturedDirection;

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
                  capturedDirection = Directionality.of(context);
                  return const Text('Content');
                },
              ),
            ),
          ),
        ),
      ),
    );

    // Assert
    expect(capturedDirection, TextDirection.rtl);
  });

  testWidgets('should respect ambient directionality', (tester) async {
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
              child: const Text('Content'),
            ),
          ),
        ),
      ),
    );

    // Assert
    final bannerWidget = tester.widget<Banner>(find.byType(Banner));
    expect(bannerWidget.textDirection, TextDirection.rtl);
    expect(bannerWidget.layoutDirection, TextDirection.rtl);
  });
}
