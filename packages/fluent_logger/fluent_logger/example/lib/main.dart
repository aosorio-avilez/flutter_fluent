import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fluent_logger/flutter_fluent_logger.dart';

final config = LoggerConfig(enableLog: kDebugMode, globalLogName: 'App');

void main() async {
  await Fluent.build([LoggerModule(config: config)]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Print debug message in console
    Fluent.get<LoggerApi>().logDebug("Hello from Fluent Logger");

    return const MaterialApp(
      title: 'Fluent Logger Demo',
      home: Scaffold(body: Center(child: Text("Hello World!"))),
    );
  }
}
