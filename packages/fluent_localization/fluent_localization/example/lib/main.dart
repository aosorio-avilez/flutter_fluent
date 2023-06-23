import 'package:fluent_localization/fluent_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  await Fluent.build([
    LocalizationModule(),
  ]);
  runApp(MainApp(
    localizationApi: Fluent.get(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.localizationApi,
  });

  final LocalizationApi localizationApi;

  @override
  Widget build(BuildContext context) {
    // Define your supported locales
    final locales = [
      const Locale("es"),
      const Locale("en"),
    ];
    // Get localization delegates
    final localizationDelegate = localizationApi.getDelegate(locales);

    return MaterialApp(
      localizationsDelegates: [
        localizationDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: locales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            final hello = context.tl('hello', args: {"name": "Developer"});
            return Center(
              child: Text(hello),
            );
          },
        ),
      ),
    );
  }
}
