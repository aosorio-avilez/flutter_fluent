## fluent_environment
Package that provides a way to register your environment and display it

## Getting Started

### Add dependencies

```yaml
fluent_environment: ^0.1.1
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

    @override
    EnvironemntType get type => EnvironemntType.dev;
}
```

### Build module

```dart
void main() async {
  await Fluent.build([
    EnvironmentModule(
      environment: AppEnvironment(),
    ),
  ]);

  runApp(const App());
}
```

### Use it
```dart
class App extends StatelessWidget {
    const App({super.key});

    @override
    Widget build(BuildContext context) {
        // Return the current environment
        final environment = FLuent.get<EnvironmentApi>().environment;
        
        return MaterialApp(
            title: 'Fluent Environment Demo',
            // Wrap child widget with environment banner to display the current environment
            builder: (context, child) => EnvironmentBanner(child: child!),
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
