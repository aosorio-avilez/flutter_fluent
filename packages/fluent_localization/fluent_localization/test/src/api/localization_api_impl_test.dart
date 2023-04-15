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

  testWidgets('verify translate', (tester) async {
    final locales = [
      const Locale('es'),
      const Locale('en'),
    ];
    final delegates =
        getApi<LocalizationApi>().getLocalizationDelegates(locales);

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
