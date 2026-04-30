import 'package:fluent_localization/fluent_localization.dart';
import 'package:fluent_localization_example/localization_keys.g.dart';
import 'package:flutter/material.dart';

void main() async {
  await Fluent.build([LocalizationModule()]);
  runApp(MainApp(localizationApi: Fluent.get()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.localizationApi});

  final LocalizationApi localizationApi;

  @override
  Widget build(BuildContext context) {
    // Define your supported locales
    final locales = [const Locale("en"), const Locale("es")];
    // Get localization delegates
    final localizationDelegates = localizationApi.getDelegates(locales);

    return MaterialApp(
      localizationsDelegates: localizationDelegates,
      supportedLocales: locales,
      home: Scaffold(
        appBar: AppBar(
          title: Builder(builder: (context) => Text(context.loc.homeTitle)),
        ),
        body: Builder(
          builder: (context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainManager.center,
                children: [
                  Text(context.loc.welcome),
                  const SizedBox(height: 16),
                  Text(context.loc.hello(name: 'Developer')),
                  const SizedBox(height: 16),
                  Text(
                    context.loc.homeDescription,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MainManager {
  static const center = MainAxisAlignment.center;
}
