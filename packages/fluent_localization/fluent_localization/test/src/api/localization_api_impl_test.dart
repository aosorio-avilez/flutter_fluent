import 'package:fluent_localization/fluent_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(
    () async {
      await Fluent.build([
        LocalizationModule(),
      ]);
      addTearDown(Fluent.reset);
    },
  );

  testWidgets('verify translate', (tester) async {
    final locales = [const Locale('en')];
    final delegates = Fluent.get<LocalizationApi>().getDelegates(
      locales,
      path: 'test/assets/languages',
    );

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: locales,
        localizationsDelegates: delegates,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final testContent =
                  context.tl('test.hello', args: {'name': 'Developer'});
              return Text(testContent);
            },
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Hello Developer!'), findsOneWidget);
  });

  test('verify getLocalizationDelegates', () async {
    final api = Fluent.get<LocalizationApi>();

    final delegates = api.getDelegates([
      const Locale('es'),
      const Locale('en'),
    ]);

    expect(delegates.first, isA<FluentLocalizationDelegate>());
  });

  test('verify path', () async {
    final api = Fluent.get<LocalizationApi>();
    const pathLocation = 'assets/languages';
    const locale = Locale('es');
    final delegates = api.getDelegates(
      [locale],
      path: 'assets/languages',
    );

    final path = (delegates.first as FluentLocalizationDelegate).path;

    expect(path, pathLocation);
  });
}
