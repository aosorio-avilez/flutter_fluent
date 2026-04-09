import 'package:fluent_localization/fluent_localization.dart';
import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggerApi extends Mock implements LoggerApi {}

void main() {
  setUpAll(() {
    FluentLocalization.parser = (content) async => parseJson(content);
  });

  late MockLoggerApi mockLoggerApi;

  setUp(() async {
    mockLoggerApi = MockLoggerApi();
    await Fluent.build([LocalizationModule()]);
    Fluent.mock<LoggerApi>(mockLoggerApi);
    addTearDown(Fluent.reset);
  });

  testWidgets('verify translate works via Context Extension', (tester) async {
    // Configuración simulada
    final locales = [const Locale('en')];
    final delegates = Fluent.get<LocalizationApi>().getDelegates(
      locales,
      path: 'test/assets/languages',
    );

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: locales,
        localizationsDelegates: delegates,
        locale: const Locale('en'),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final testContent = context.tr(
                'test.hello',
                args: {'name': 'Developer'},
              );
              return Text(testContent);
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hello Developer!'), findsOneWidget);
  });

  test('verify getDelegates returns correct configuration', () async {
    final api = Fluent.get<LocalizationApi>();

    final delegates = api.getDelegates([
      const Locale('es'),
      const Locale('en'),
    ]);

    expect(delegates.first, isA<FluentLocalizationDelegate>());
    // Verificamos que incluya los delegados nativos de Flutter también
    expect(delegates.length, greaterThan(1));
  });

  test('verify path configuration passed to delegate', () async {
    final api = Fluent.get<LocalizationApi>();
    const customPath = 'custom/assets/languages';

    final delegates = api.getDelegates(
      [const Locale('es')],
      path: customPath,
    );

    final delegate = delegates.first as FluentLocalizationDelegate;
    expect(delegate.path, customPath);
  });

  testWidgets('verify logWarning is called when localization is missing', (
    tester,
  ) async {
    final api = Fluent.get<LocalizationApi>();
    const key = 'test.hello';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Text(api.translate(context, key));
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    verify(
      () => mockLoggerApi.logWarning(
        any<String>(that: contains('FluentLocalization not found in context')),
      ),
    ).called(1);
    expect(find.text(key), findsOneWidget);
  });
}
