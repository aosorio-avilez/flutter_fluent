import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEnvironment extends Mock implements Environment {}

class MockEnvironmentApi extends Mock implements EnvironmentApi {}

void main() {
  late MockEnvironment mockEnv;
  late MockEnvironmentApi mockApi;

  setUpAll(() {
    registerFallbackValue(MockEnvironment());
  });

  setUp(() {
    mockEnv = MockEnvironment();
    mockApi = MockEnvironmentApi();
    when(() => mockEnv.sensitiveKeys).thenReturn({});
    when(() => mockEnv.features).thenReturn({});
    when(() => mockEnv.name).thenReturn('Development');
    when(() => mockEnv.type).thenReturn(EnvironmentType.dev);
    when(() => mockEnv.color).thenReturn(Colors.blue);
    when(() => mockEnv.values).thenReturn({});
    when(() => mockApi.environmentNotifier).thenReturn(ValueNotifier(mockEnv));
    when(() => mockApi.availableEnvironments).thenReturn([mockEnv]);
    when(() => mockApi.customActions).thenReturn([]);
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
          body: EnvironmentInspector(environmentApi: mockApi),
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

    // Check Close button
    expect(find.widgetWithIcon(IconButton, Icons.close), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);

    // Check color indicator semantics
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Environment color indicator',
      ),
      findsOneWidget,
    );
  });

  testWidgets('should show environment switcher when multiple environments', (
    tester,
  ) async {
    final mockEnv2 = MockEnvironment();
    when(() => mockEnv2.name).thenReturn('Staging');
    when(() => mockEnv2.type).thenReturn(EnvironmentType.stg);
    when(() => mockEnv2.color).thenReturn(Colors.orange);
    when(() => mockEnv2.values).thenReturn({});
    when(() => mockEnv2.features).thenReturn({});
    when(() => mockEnv2.sensitiveKeys).thenReturn({});

    when(() => mockApi.availableEnvironments).thenReturn([mockEnv, mockEnv2]);
    when(() => mockApi.updateEnvironment(any())).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnvironmentInspector(environmentApi: mockApi),
        ),
      ),
    );

    expect(find.text('Available Environments'), findsOneWidget);
    expect(find.text('Staging'), findsOneWidget);

    await tester.tap(find.text('Staging'));
    await tester.pump();

    verify(() => mockApi.updateEnvironment(mockEnv2)).called(1);
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
          body: EnvironmentInspector(environmentApi: mockApi),
        ),
      ),
    );

    // Assert
    expect(find.text('Staging'), findsOneWidget);
    expect(find.text('STG'), findsOneWidget);
    expect(find.text('No configuration values defined.'), findsOneWidget);
  });

  testWidgets('should copy value to clipboard when copy button is pressed', (
    tester,
  ) async {
    // Arrange
    when(() => mockEnv.values).thenReturn({'key': 'value'});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnvironmentInspector(environmentApi: mockApi),
        ),
      ),
    );

    // Act
    expect(find.byIcon(Icons.copy_all), findsOneWidget);
    await tester.tap(find.byIcon(Icons.copy_all));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Assert
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Copied "key" to clipboard'), findsOneWidget);
  });

  testWidgets('should redact sensitive keys and hide copy button', (
    tester,
  ) async {
    // Arrange
    when(() => mockEnv.values).thenReturn({
      'public_key': 'public_123',
      'secret_key': 'secret_456',
    });
    when(() => mockEnv.sensitiveKeys).thenReturn({'secret_key'});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnvironmentInspector(environmentApi: mockApi),
        ),
      ),
    );

    // Assert
    expect(find.text('public_key'), findsOneWidget);
    expect(find.text('public_123'), findsOneWidget);
    expect(find.text('secret_key'), findsOneWidget);
    expect(find.text('secret_456'), findsNothing);
    expect(find.text('***REDACTED***'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Sensitive configuration value',
      ),
      findsOneWidget,
    );

    // Assert exactly one copy button exists (associated with public_key)
    expect(find.byIcon(Icons.copy_all), findsOneWidget);

    // Verify that the copy button matches the non-sensitive key
    final copyIconButton = find.ancestor(
      of: find.byIcon(Icons.copy_all),
      matching: find.byType(IconButton),
    );
    final tooltip = tester.widget<IconButton>(copyIconButton).tooltip;
    expect(tooltip, contains('public_key'));
    expect(tooltip, isNot(contains('secret_key')));
  });

  testWidgets('should display and toggle feature flags', (tester) async {
    // Arrange
    when(() => mockEnv.features).thenReturn({
      'feature1': true,
      'feature2': false,
    });
    when(() => mockApi.isFeatureEnabled('feature1')).thenReturn(true);
    when(() => mockApi.isFeatureEnabled('feature2')).thenReturn(false);
    when(
      () => mockApi.setFeatureFlag(
        any(),
        value: any(named: 'value'),
      ),
    ).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnvironmentInspector(environmentApi: mockApi),
        ),
      ),
    );

    // Assert
    expect(find.text('Features'), findsOneWidget);
    expect(find.text('feature1'), findsOneWidget);
    expect(find.text('feature2'), findsOneWidget);

    final switch1 = tester.widget<Switch>(
      find.descendant(
        of: find.widgetWithText(SwitchListTile, 'feature1'),
        matching: find.byType(Switch),
      ),
    );
    expect(switch1.value, isTrue);

    final switch2 = tester.widget<Switch>(
      find.descendant(
        of: find.widgetWithText(SwitchListTile, 'feature2'),
        matching: find.byType(Switch),
      ),
    );
    expect(switch2.value, isFalse);

    // Act
    await tester.tap(find.text('feature1'));
    await tester.pump();

    // Assert
    verify(() => mockApi.setFeatureFlag('feature1', value: false)).called(1);
  });

  testWidgets('should render custom actions and handle tap', (tester) async {
    // Arrange
    var tapCount = 0;
    final action = EnvironmentAction(
      label: 'Test Action',
      icon: Icons.bug_report,
      onTap: (_) {
        tapCount++;
      },
    );

    when(() => mockApi.customActions).thenReturn([action]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnvironmentInspector(environmentApi: mockApi),
        ),
      ),
    );

    // Assert grid renders
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Test Action'), findsOneWidget);
    expect(find.byIcon(Icons.bug_report), findsOneWidget);

    // Act
    await tester.tap(find.text('Test Action'));
    await tester.pump();

    // Assert tap handled
    expect(tapCount, 1);
  });
}
