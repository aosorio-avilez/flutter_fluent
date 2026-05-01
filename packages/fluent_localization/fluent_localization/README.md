## fluent_localization
Package that allows you to set up and use translations in an easy and quick way.

## Getting Started

### Add dependencies

```yaml
fluent_localization: ^1.6.0
```

### Add language folder to Flutter assets

```yaml 
flutter:
    assets:
        - "assets/languages/"
```

### Create assets files

```json
// assets/languages/en.json
{
    "hello": "Hello {name}!",
    "title": "Welcome"
}
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

## Type-Safe Generation (NEW 🚀)

To avoid using strings keys manually, you can generate type-safe keys using the built-in generator.

### 1. Run the generator
Run this command in your project root:

```bash
fvm dart run fluent_localization:generate [inputPath] [outputPath] [baseLocale]
```

By default, it uses:
- `inputPath`: `assets/languages`
- `outputPath`: `lib/localization_keys.g.dart`
- `baseLocale`: `en` (uses `en.json` as source)

Example using Spanish as the base language:
```bash
fvm dart run fluent_localization:generate assets/languages lib/localization_keys.g.dart es
```

This will create a file at `lib/localization_keys.g.dart` using `es.json` to generate the keys.

### 2. Use it in your code
Import the generated file and use the `context.loc` extension:

```dart
// Simple key
Text(context.loc.title)

// Key with arguments
Text(context.loc.hello(name: 'John'))
```

## Manual Usage
If you prefer not to use the generator:

```dart
final hello = context.tr('hello', args: {'name': 'John'});
```

## Example

<img src="https://raw.githubusercontent.com/aosorio-avilez/flutter_fluent/main/resources/fluent_localization_example.png" width="400" />