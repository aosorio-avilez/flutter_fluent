import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';

import 'app_environment.dart';

void main() async {
  await Fluent.build([
    EnvironmentModule(
      environment: DevEnvironment(),
      availableEnvironments: [
        DevEnvironment(),
        StagingEnvironment(),
        ProdEnvironment(),
      ],
    )
  ]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluent Environment Example',
      navigatorKey: navigatorKey,
      builder: (context, child) => EnvironmentBanner(
        enableInspector: true,
        configValuesLabel: 'Custom Config Label',
        noValuesLabel: 'Custom No Values Message',
        navigatorKey: navigatorKey,
        child: child!,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fluent Environment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder<Environment>(
              valueListenable: Fluent.get<EnvironmentApi>().environmentNotifier,
              builder: (context, environment, _) {
                return Text("Current Environment: ${environment.name}");
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "Long press the environment banner to see the inspector",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              "You can now switch environments inside the inspector!",
              style: TextStyle(color: Colors.blue),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Fluent.get<EnvironmentApi>().showInspector(
                  context,
                  configValuesLabel: 'Manual Config Label',
                  noValuesLabel: 'Manual No Values Message',
                );
              },
              child: const Text("Show Inspector Manually"),
            ),
          ],
        ),
      ),
    );
  }
}
