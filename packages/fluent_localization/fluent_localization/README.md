## fluent_localization
Package that allows you to set up and use translations in an easy and quick way

## Getting Started

### Add dependencies

```yaml
fluent_localization: ^0.0.2+1
```

### Add assets folder to Flutter

```yaml 
flutter:
    assets:
        - "assets/languages/"
```

### Create assets files

```yaml 
assets/
    languages/
        en.json
        es.json
```

### Build module

```dart
Fluent.build([
    LocalizationModule(),
]);
```

### Use it
```dart
class App extends StatelessWidget {
    const App({super.key});

    @override
    Widget build(BuildContext context) {
        // Define your supported locales
        final locales = [
            Locale("es"),
            Locale("en"),
        ];
        // Get localization delegates
        final localizationDelegates = Fluent.get<LocalizationApi>().getLocalizationDelegates(locales);
        
        return MaterialApp(
            title: 'Fluent Localization Demo',
            localizationsDelegates: localizationDelegates,
            supportedLocales: locales,
            home: Scaffold(
                body: Builder(
                    builder: (context) {
                        final hello = context.tl('hello');
                        return Center(
                            child: Text(hello),
                        );
                    },
                ),
            ),
        );
    }
}
```

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_localization_example.png" width="400" />