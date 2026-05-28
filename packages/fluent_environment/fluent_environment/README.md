## fluent_environment
Package that provides a way to register your environment and display it

## Getting Started

### Add dependencies

```yaml
fluent_environment: ^0.9.0
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
    @override
    Map<String, bool> get features => {
        'new_payment_flow': true,
        'beta_features': false,
    };
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
3. **Toggle Feature Flags**: Instantly toggle any environment features at runtime.
4. **Reactive UI**: The UI, feature flag overrides, and reconstructed services will update automatically.

## Feature Flags

Define a map of feature flags for each environment to check their status and override them at runtime within the inspector.

### 1. Check Feature Status

```dart
final api = Fluent.get<EnvironmentApi>();

// Check if a feature is enabled
final isEnabled = api.isFeatureEnabled('new_payment_flow');
```

### 2. Override at Runtime

```dart
// Override the feature flag value at runtime
api.setFeatureFlag('new_payment_flow', value: false);
```

Whenever a feature flag is overridden, the `environmentNotifier` will automatically trigger notifications so that your UI reactively rebuilds with the new state.

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_environment_example.png" width="400" />
