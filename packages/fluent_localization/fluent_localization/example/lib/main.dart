import 'package:fluent_localization/fluent_localization.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';

void main() {
  Fluent.build([
    LocalizationModule(),
  ]);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define your supported locales
    final locales = [
      const Locale("es"),
      const Locale("en"),
    ];
    // Get localization delegates
    final localizationDelegates =
        getApi<LocalizationApi>().getLocalizationDelegates(locales);

    return MaterialApp(
      localizationsDelegates: localizationDelegates,
      supportedLocales: locales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            final hello = context.tl('hello');
            return Center(
              child: Text(hello),
            );
          },
        ),
      ),
    );
  }
}
