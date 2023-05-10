import 'package:ez_localization/ez_localization.dart';
import 'package:fluent_localization/fluent_localization.dart';
import 'package:flutter/cupertino.dart';
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
    final localizationDelegates =
        Fluent.get<LocalizationApi>().getLocalizationDelegates(
      locales,
      pathFunction: (locale) =>
          'test/assets/languages/${locale.languageCode}.json',
    );
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: locales,
        localizationsDelegates: localizationDelegates,
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

    final delegates = api.getLocalizationDelegates([
      const Locale('es'),
      const Locale('en'),
    ]);

    expect(delegates.length, 4);
    expect(delegates[0], isA<EzLocalizationDelegate>());
    expect(delegates[1], isA<LocalizationsDelegate<MaterialLocalizations>>());
    expect(delegates[2], isA<LocalizationsDelegate<CupertinoLocalizations>>());
    expect(delegates[3], isA<LocalizationsDelegate<WidgetsLocalizations>>());
  });

  test('verify getPathFunction', () async {
    final api = Fluent.get<LocalizationApi>();
    const pathLocation = 'assets/languages/es.json';
    const locale = Locale('es');
    final delegates = api.getLocalizationDelegates(
      [locale],
      pathFunction: (locale) => 'assets/languages/${locale.languageCode}.json',
    );

    final path =
        (delegates[0] as EzLocalizationDelegate).getPathFunction(locale);

    expect(path, pathLocation);
  });
}
