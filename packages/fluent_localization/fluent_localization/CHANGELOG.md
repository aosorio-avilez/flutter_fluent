## 1.8.0

* CHORE: Updated `fluent_sdk` dependency to `^0.7.0`.
* REFACTOR: Refactored `LocalizationModule` to support the new stable Registry contract.

## 1.7.0

* **Feature**: Added support for a configurable base locale in the code generator.
* **Feature**: The CLI tool now accepts an optional third argument to specify the base locale file (e.g., `es` for `es.json`).
* **Enhancement**: Improved error reporting when the base localization file is missing or invalid.

## 1.6.1

* **Fix**: Resolved linter warnings in the CLI tool and generator logic.
* **Fix**: Added missing linter ignores to the generated file for better consumer compatibility.
* **Test**: Added unit tests for the localization generator and string utilities.

## 1.6.0

* **Feature**: Added a built-in code generator for type-safe localization keys.
* **Feature**: Support for typed arguments in generated keys (e.g., `context.loc.hello(name: 'John')`).
* **Refactor**: Replaced `print` and `debugPrint` with `LoggerApi` for better integration with the toolkit.
* **Optimization**: Applied micro-optimizations to the JSON loading process.

## 1.5.0

* optimize json parsing
* string interpolation optimization
* runtime optimization
* Return empty map of string when locale file does not exists
* Added nested strings and format arguments functionality

## 1.4.0
...