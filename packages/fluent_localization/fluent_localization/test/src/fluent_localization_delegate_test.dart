import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:fluent_localization/src/fluent_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(WidgetsFlutterBinding.ensureInitialized);

  testWidgets('verify fluent localization delegate', (tester) async {
    const defaultLocale = Locale('en');
    const anotherLocale = Locale('en', 'US');
    const delegate = FluentLocalizationDelegate(
      locale: defaultLocale,
      supportedLocales: [defaultLocale, anotherLocale],
      path: 'test/assets/languages',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [delegate],
        locale: delegate.locale,
        supportedLocales: delegate.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Text(
                FluentLocalization.of(context)!.get(
                  'test.hello',
                  args: {'name': 'Dev'},
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Hello Dev!'), findsOneWidget);
  });

  test(
      '''verify fluent localization delegate return map of strings when locale does not exists''',
      () async {
    const defaultLocale = Locale('en');

    const delegate = FluentLocalizationDelegate(
      locale: defaultLocale,
    );

    final result = await delegate.load(defaultLocale);

    expect(result, isA<FluentLocalization>());
  });

  test(
      '''verify fluent localization throws format exception when file is malformed''',
      () async {
    const defaultLocale = Locale('es');

    const delegate = FluentLocalizationDelegate(
      locale: defaultLocale,
      path: 'test/assets/languages',
    );

    expect(delegate.load(defaultLocale), throwsA(isA<FormatException>()));
  });
}
