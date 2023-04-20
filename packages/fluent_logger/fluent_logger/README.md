## fluent_logger
Package that allows printing messages in console

## Getting Started

### Add dependencies

```yaml
fluent_logger:
    git:
      url: https://github.com/aosorio-avilez/flutter_fluent.git
      ref: fluent_logger-v0.0.1
      path: packages/fluent_logger/fluent_logger
```

### Build module

```dart
Fluent.build([
    LoggerModule(),
]);
```

### Use it
```dart
class App extends StatelessWidget {
    const App({super.key});

    @override
    Widget build(BuildContext context) {
        // Print debug message in console
        getApi<LoggerApi>().logDebug("Hello from Fluent Logger");
        
        return MaterialApp(
            title: 'Fluent Logger Demo',
            home: Scaffold(
                body: Center(
                    child: Text("Hello World!"),
                ),
            ),
        );
    }
}
```

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_logger_example.png" width="400" />