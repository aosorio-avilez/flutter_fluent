## fluent_navigation
Package that provides a simple way to navigate within your app

## Getting Started

### Add dependencies

```yaml
fluent_navigation: ^1.0.0
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
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                // Push to registered route two
                final result = await Fluent.get<NavigationApi>().pushTo("two");
                if (result != null) {
                  debugPrint("Result: $result");
                }
              },
              child: const Text("Push to second page"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to page two
                Fluent.get<NavigationApi>().navigateTo("two");
              },
              child: const Text("Navigate to second page"),
            ),
          ],
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
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Fluent.get<NavigationApi>().pop(true);
          },
          child: const Text("Go back to previous page"),
        ),
      ),
    );
  }
}
```

### Create module and register routes

```dart
class ExampleModule extends FluentModule {

  @override
  Future<void> build(Registry registry) async {
    registry
        // Initial route
        ..registerRoute(GoRoute(
          name: "one",
          path: "/one",
          builder: (context, state) => const PageOne(),
        ))
        // Second route
        ..registerRoute(GoRoute(
          name: "two",
          path: "/two",
          builder: (context, state) => const PageTwo(),
        ));
  }
}
```

### Build module

```dart
void main() async {
  await Fluent.build([
    NavigationModule(initialLocation: "/one"),
    ExampleModule(),
  ]);

  runApp(const MainApp());
}
```

### Use it
```dart
class App extends StatelessWidget {
    const App({super.key});

    @override
    Widget build(BuildContext context) {    
        // Get router config
        final router = Fluent.get<NavigationApi>().router;
        
        return MaterialApp.router(
            title: "Fluent Navigation Demo",
            routerConfig: router,
        );
    }
}
```

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_navigation_example.gif" width="400" />