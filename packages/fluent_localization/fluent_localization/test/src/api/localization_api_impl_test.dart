import 'package:fluent_localization/fluent_localization.dart';
import 'package:fluent_localization/src/fluent_localization_delegate.dart';
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
    final localizationDelegate = Fluent.get<LocalizationApi>().getDelegate(
      locales,
      path: 'test/assets/languages',
    );
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: locales,
        localizationsDelegates: [localizationDelegate],
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

    final delegate = api.getDelegate([
      const Locale('es'),
      const Locale('en'),
    ]);

    expect(delegate, isA<FluentLocalizationDelegate>());
  });

  test('verify path', () async {
    final api = Fluent.get<LocalizationApi>();
    const pathLocation = 'assets/languages';
    const locale = Locale('es');
    final delegate = api.getDelegate(
      [locale],
      path: 'assets/languages',
    );

    final path = (delegate as FluentLocalizationDelegate).path;

    expect(path, pathLocation);
  });
}
