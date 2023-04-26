import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking_example/app_config.dart';
import 'package:flutter/material.dart';

void main() {
  Fluent.build([
    NetworkingModule(config: ApiConfig()),
  ]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final networkingApi = Fluent.get<NetworkingApi>();
    final future = networkingApi.get<Map<String, dynamic>>("/pokemon");

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Fluent Networking Demo"),
        ),
        body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            return snapshot.data?.when(
                  succeeded: (data) {
                    final results = data["results"];
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Text(results[index]["name"]),
                          title: Text(results[index]["url"]),
                        );
                      },
                    );
                  },
                  failed: (data) => const Text("Failed error"),
                  error: (error) => Text(error.message ?? ""),
                ) ??
                const Center(
                  child: CircularProgressIndicator(),
                );
          },
        ),
      ),
    );
  }
}
