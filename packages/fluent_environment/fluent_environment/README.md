## fluent_environment
Package that provides a way to register your environment and display it

## Getting Started

### Add dependencies

```yaml
fluent_environment: ^0.0.3
```

### Define environment

```dart 
class AppEnvironment extends Environment {
    
    @override
    final String name = "Development";

    @override
    final Color color = Colors.blue;

    @override
    Map<String, String> get values => {
        'url': const String.fromEnvironment('URL'),
    };
}
```

### Build module

```dart
Fluent.build([
    EnvironmentModule(
        environment: AppEnvironment(),
    ),
]);
```

### Use it
```dart
class App extends StatelessWidget {
    const App({super.key});

    @override
    Widget build(BuildContext context) {
        // Return environment banner to display the current environment
        final environmentBanner = FLuent.get<EnvironmentApi>().buildEnvironmentBanner;
        // Return the current environment
        final environment =  FLuent.get<EnvironmentApi>().getEnvironment();
        
        return MaterialApp(
            title: 'Fluent Environment Demo',
            builder: (context, child) => environmentBanner(child: child!),
            home: Scaffold(
                body: Center(
                    child: Text("Environment: ${environment.type.description}"),
                ),
            ),
        );
    }
}
```

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_environment_example.png" width="400" />
