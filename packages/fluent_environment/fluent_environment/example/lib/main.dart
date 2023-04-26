import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';

import 'app_environment.dart';

void main() {
  Fluent.build([
    EnvironmentModule(
      environment: AppEnvironment(),
    ),
  ]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Return environment banner to display the current environment
    final environmentBanner =
        Fluent.get<EnvironmentApi>().buildEnvironmentBanner;
    // Return the current environment
    final environment = Fluent.get<EnvironmentApi>().getEnvironment();

    return MaterialApp(
      title: 'Fluent Environment Example',
      builder: (context, child) => environmentBanner(child: child!),
      home: Scaffold(
        body: Center(
          child: Text("Environment: ${environment.name}"),
        ),
      ),
    );
  }
}
