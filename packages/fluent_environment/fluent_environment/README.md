## fluent_environment
Package that provides a way to register your environment and display it

## Getting Started

### Add dependencies

```yaml
fluent_environment: ^0.8.0
```

### Define environment

```dart 
class DevEnvironment extends Environment {
    @override
    String get name => "Dev";
    @override
    Color get color => Colors.blue;
    @override
    EnvironmentType get type => EnvironmentType.dev;
}

class ProdEnvironment extends Environment {
    @override
    String get name => "Production";
    @override
    Color get color => Colors.red;
    @override
    EnvironmentType get type => EnvironmentType.prod;
}
```

### Build module

Register your current environment and provide other available environments to enable switching.

```dart
void main() async {
  await Fluent.build([
    EnvironmentModule(
      environment: DevEnvironment(),
      availableEnvironments: [
        DevEnvironment(),
        ProdEnvironment(),
      ],
    ),
  ]);

  runApp(const MainApp());
}
```

### Service Reconstruction

You can register services that need to be reconstructed whenever the environment changes (e.g., a networking client that needs to point to a new base URL).

```dart
@override
Future<void> onCreate(Registry registry) async {
  // Register the service to be reset on environment change
  Fluent.get<EnvironmentApi>().registerResetService<NetworkingApi>();
  
  registry.registerLazySingleton<NetworkingApi>((it) {
      final config = it.get<EnvironmentApi>().environment.values['apiConfig'];
      return NetworkingApiImpl(config: config);
  });
}
```

### Use it

Wrap your app with `EnvironmentBanner`. If `enableInspector` is true, you can **long-press** the banner to open the **Environment Inspector** and switch environments at runtime.

```dart
class MainApp extends StatelessWidget {
    const MainApp({super.key, required this.navigatorKey});
    
    final GlobalKey<NavigatorState> navigatorKey;

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            navigatorKey: navigatorKey,
            builder: (context, child) => EnvironmentBanner(
                enableInspector: true,
                navigatorKey: navigatorKey,
                child: child!,
            ),
            home: const HomePage(),
        );
    }
}
```

## Environment Inspector

The inspector allows you to:
1. **Switch Environments**: Instantly change the current environment.
2. **View Config**: Inspect the current environment's configuration values.
3. **Reactive UI**: The UI and reconstructed services will update automatically.

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_environment_example.png" width="400" />
