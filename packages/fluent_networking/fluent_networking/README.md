## fluent_networking
Package that provides a simple way to make http requests

## Getting Started

### Add dependencies

```yaml
fluent_sdk:
    git:
      url: https://github.com/aosorio-avilez/flutter_fluent.git
      ref: main
      path: packages/fluent_sdk
  fluent_networking:
    git:
      url: https://github.com/aosorio-avilez/flutter_fluent.git
      ref: main
      path: packages/fluent_networking/fluent_networking
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
Fluent.build([
    NetworkingModule(),
]);
```

### Use it
```dart
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get networking api
    final networkingApi = getApi<NetworkingApi>();
    // Make get request
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
```

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_networking_example.png" width="400" />