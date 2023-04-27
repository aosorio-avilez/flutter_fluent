## fluent_logger
Package that allows you to print different types of messages in console

## Getting Started

### Add dependencies

```yaml
flutter_fluent_logger: ^0.0.2+1
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
        Fluent.get<LoggerApi>().logDebug("Hello from Fluent Logger");
        
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