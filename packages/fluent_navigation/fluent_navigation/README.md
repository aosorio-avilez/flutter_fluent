## fluent_navigation
Package that provides a simple way to navigate within your app

## Getting Started

### Add dependencies

```yaml
fluent_navigation: ^1.10.0
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
                // Navigate with params and query params
                Fluent.get<NavigationApi>().navigateTo(
                  "details",
                  params: {"id": "123"},
                  queryParams: {"tab": "info"},
                );
              },
              child: const Text("Navigate with parameters"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Replace current route (useful for login flows)
                Fluent.get<NavigationApi>().replaceWith("home");
              },
              child: const Text("Replace with Home"),
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
            // Check if can pop before popping
            if (Fluent.get<NavigationApi>().canPop()) {
              Fluent.get<NavigationApi>().pop(true);
            }
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
  Future<void> onCreate(Registry registry) async {
    registry
        // Initial route
        ..registerRoute(GoRoute(
          name: "one",
          path: "/one",
          builder: (context, state) => const PageOne(),
        ))
        // Route with parameters
        ..registerRoute(GoRoute(
          name: "details",
          path: "/details/:id",
          builder: (context, state) {
            final id = state.pathParameters["id"];
            final tab = state.uri.queryParameters["tab"];
            return DetailsPage(id: id, tab: tab);
          },
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
        final navigationApi = Fluent.get<NavigationApi>();
        
        return MaterialApp.router(
            title: "Fluent Navigation Demo",
            // The router configuration
            routerConfig: navigationApi.router,
            // Access the GlobalKey<NavigatorState> if needed
            // builder: (context, child) => MyWrapper(
            //    navigatorKey: navigationApi.navigatorKey,
            //    child: child!,
            // ),
        );
    }
}
```

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_navigation_example.gif" width="400" />