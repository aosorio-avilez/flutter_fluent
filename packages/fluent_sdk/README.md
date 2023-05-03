# fluent_sdk
Package that provide a way to modularize features through a service locator.

## Getting Started

### Add dependencies

```yaml
fluent_sdk: ^0.2.0
```

### Create a interface/implementation to access the feature functionalities

```dart
// Interface
abstract class HomeApi {
  Widget getHomePage();
}

// Implementation
class HomeApiImpl extends HomeApi {
  @override
  Widget getHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fluent SDK Demo"),
      ),
      body: const Center(
        child: Text("Hello from Fluent SDK"),
      ),
    );
  }
}
```

### Create module

```dart
class HomeModule extends Module {

  @override
  Future<void> build(Registry registry) async {
    // Register home api to access globally to it
    registry.registerSingleton<HomeApi>((it) => HomeApiImpl());
  }
}
```

### Build module

```dart
void main() async {
  await Fluent.build([
    HomeModule(),
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
    // Access to home api and get home page
    final homePage = Fluent.get<HomeApi>().getHomePage();

    return MaterialApp(
      home: Scaffold(
        body: homePage,
      ),
    );
  }
}

```

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_sdk_example.png" width="400" />