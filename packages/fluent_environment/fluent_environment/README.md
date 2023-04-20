## fluent_environment
Package that provides a way to register your environment and display it

## Getting Started

### Add dependencies

```yaml
fluent_environment:
    git:	
        url: https://github.com/aosorio-avilez/flutter_fluent.git
        ref: fluent_environment-v0.0.1
        path: packages/fluent_environment/fluent_environment
```

### Define environment

```dart 
class AppEnvironment extends Environment {
    AppEnvironment({this.type = EnvironmentType.prod});
    
    @override
    final EnvironmentType type;

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
        AppEnvironment(type: EnvironmentType.dev),
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
        final environmentBanner = getApi<EnvironmentApi>().buildEnvironmentBanner;
        // Return the current environment
        final environment =  getApi<EnvironmentApi>().getEnvironment();
        
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
