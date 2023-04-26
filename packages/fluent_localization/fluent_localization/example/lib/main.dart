import 'package:fluent_localization/fluent_localization.dart';
import 'package:flutter/material.dart';

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
    final localizationDelegates =
        localizationApi.getLocalizationDelegates(locales);

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
