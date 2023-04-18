import 'package:ez_localization/ez_localization.dart';
import 'package:fluent_localization/fluent_localization.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(
    () => Fluent.build([
      LocalizationModule(),
    ]),
  );

  test('verify getLocalizationDelegates', () async {
    final api = getApi<LocalizationApi>();

    final delegates = api.getLocalizationDelegates();

    expect(delegates.length, 4);
    expect(delegates[0], isA<EzLocalizationDelegate>());
    expect(delegates[1], isA<LocalizationsDelegate<MaterialLocalizations>>());
    expect(delegates[2], isA<LocalizationsDelegate<CupertinoLocalizations>>());
    expect(delegates[3], isA<LocalizationsDelegate<WidgetsLocalizations>>());
  });

  test('verify getSupportedLocales', () async {
    final api = getApi<LocalizationApi>();

    final locales = api.getSupportedLocales();

    expect(locales.length, 2);
    expect(locales[0], const Locale('es'));
    expect(locales[1], const Locale('en'));
  });

  testWidgets('verify translate', (tester) async {
    final delegates = getApi<LocalizationApi>().getLocalizationDelegates();
    final locales = getApi<LocalizationApi>().getSupportedLocales();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: delegates,
        supportedLocales: locales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final helloText = context.tl('test');
              return Text(helloText);
            },
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('test'), findsOneWidget);
  });
}
