import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking_example/app_config.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Fluent.build([NetworkingModule(config: ApiConfig())]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final networkingApi = Fluent.get<NetworkingApi>();

    final future = networkingApi.get<Map<String, dynamic>>("/pokemon");

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Fluent Networking Demo"),
          elevation: 2,
        ),
        body: FutureBuilder<ResponseResult<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("No data received"));
            }

            final result = snapshot.data!;

            return switch (result) {
              Success(data: final pokemonData) => _PokemonList(
                data: pokemonData,
              ),
              Failure(error: final httpError) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Error ${httpError.code ?? 'Unknown'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(httpError.message),
                    ],
                  ),
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}

class _PokemonList extends StatelessWidget {
  final Map<String, dynamic> data;

  const _PokemonList({required this.data});

  @override
  Widget build(BuildContext context) {
    final results = data["results"] as List<dynamic>? ?? [];

    if (results.isEmpty) {
      return const Center(child: Text("No Pokemons found"));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final pokemon = results[index] as Map<String, dynamic>;
        final name = pokemon["name"]?.toString() ?? "Unknown";
        final url = pokemon["url"]?.toString() ?? "";

        return ListTile(
          leading: CircleAvatar(child: Text(name[0].toUpperCase())),
          title: Text(
            name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(url),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}
