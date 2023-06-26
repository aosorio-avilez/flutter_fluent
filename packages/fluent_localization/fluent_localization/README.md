## fluent_localization
Package that allows you to set up and use translations in an easy and quick way

## Getting Started

### Add dependencies

```yaml
fluent_localization: ^1.0.0
```

### Add language folder to Flutter assets

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
void main() async {
  await Fluent.build([
    LocalizationModule(),
  ]);
  runApp(App());
}
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
        final delegate = Fluent.get<LocalizationApi>().getDelegate(locales);
        
        return MaterialApp(
            title: 'Fluent Localization Demo',
            localizationsDelegates: [
                delegate,
                // From `flutter_localization` package, more info https://docs.flutter.dev/accessibility-and-localization/internationalization
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
            ],
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