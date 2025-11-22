## fluent_networking
Package that provides a simple way to make http requests

## Getting Started

### Add dependencies

```yaml
fluent_networking: ^0.2.0
```

### Create networking config

```dart
class ApiConfig extends NetworkingConfig {
  @override
  String get baseUrl => "https://pokeapi.co/api/v2";
}
```

### Build module

```dart
void main() async {
  await Fluent.build([
    NetworkingModule(config: ApiConfig()),
  ]);

  runApp(const MainApp());
}
```

### Use it
```dart
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
```

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_networking_example.png" width="400" />