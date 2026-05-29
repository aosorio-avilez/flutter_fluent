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
    ),
  ]);

  // Register some custom actions
  Fluent.get<EnvironmentApi>()
    ..registerAction(
      EnvironmentAction(
        label: 'Clear Cache',
        icon: Icons.delete_sweep,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cache cleared!')),
          );
        },
      ),
    )
    ..registerAction(
      EnvironmentAction(
        label: 'Reset Onboarding',
        icon: Icons.restart_alt,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Onboarding reset!')),
          );
        },
      ),
    );

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
                final api = Fluent.get<EnvironmentApi>();
                final isSearchV2 = api.isFeatureEnabled('search_v2');
                final isPaymentV2 = api.isFeatureEnabled('payment_v2');

                return Column(
                  children: [
                    Text("Current Environment: ${environment.name}"),
                    const SizedBox(height: 16),
                    Text(
                      "Search V2 Feature: ${isSearchV2 ? 'ENABLED' : 'DISABLED'}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSearchV2 ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Payment V2 Feature: ${isPaymentV2 ? 'ENABLED' : 'DISABLED'}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPaymentV2 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                );
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
