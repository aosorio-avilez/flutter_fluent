import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:fluient_sdk_example/feature/home/home_api.dart';
import 'package:fluient_sdk_example/feature/home/home_module.dart';
import 'package:flutter/material.dart';

void main() {
  Fluent.build([
    HomeModule(),
  ]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get home page from home module
    final homePage = Fluent.get<HomeApi>().getHomePage();

    return MaterialApp(
      home: Scaffold(
        body: homePage,
      ),
    );
  }
}
