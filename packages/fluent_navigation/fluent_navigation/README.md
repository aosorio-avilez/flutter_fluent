## fluent_navigation
Package that provides a simple way to navigate within your app

## Getting Started

### Add dependencies

```yaml
fluent_sdk:
    git:
      url: https://github.com/aosorio-avilez/flutter_fluent.git
      ref: main
      path: packages/fluent_sdk
  fluent_navigation:
    git:
      url: https://github.com/aosorio-avilez/flutter_fluent.git
      ref: main
      path: packages/fluent_navigation/fluent_navigation
```

### Create pages

```dart
// Page one (initial)
class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page one")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Push to registered route two
            getApi<NavigationApi>().pushTo("two");
          },
          child: const Text("Navigate to second page"),
        ),
      ),
    );
  }
}

// Page two
class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page two")),
      body: const Center(
        child: Text("Hello from page two"),
      ),
    );
  }
}
```

### Create module and register routes

```dart
class ExampleModule extends Module {
  ExampleModule({super.testMode = false});

  @override
  void build(Registry registry) {
    registry
        // Initial route
        ..registerRoute(const Route(
            "one",
            "/one",
            initial: true,
            page: PageOne(),
        ))
        // Second route
        ..registerRoute(const Route(
            "two",
            "/two",
            page: PageTwo(),
        ));
  }
}
```

### Build module

```dart
Fluent.build([
    NavigationModule(),
    ExampleModule(),
]);
```

### Use it
```dart
class App extends StatelessWidget {
    const App({super.key});

    @override
    Widget build(BuildContext context) {    
        // Get router config
        final config = getApi<NavigationApi>().getConfig();
        
        return MaterialApp.router(
            title: "Fluent Navigation Demo",
            routerConfig: config,
        );
    }
}
```

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_navigation_example.gif" width="400" />