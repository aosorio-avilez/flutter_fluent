import 'package:fluent_navigation_example/example_module.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';
import 'package:fluent_navigation/fluent_navigation.dart';

void main() {
  Fluent.build([
    NavigationModule(),
    ExampleModule(),
  ]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = getApi<NavigationApi>().getConfig();

    return MaterialApp.router(
      title: "Fluent Navigation Demo",
      routerConfig: config,
    );
  }
}
