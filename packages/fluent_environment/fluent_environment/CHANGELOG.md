## 0.10.1

* FIX: Resolved global semantics overlay issue in `EnvironmentBanner` by restricting `Semantics` boundaries to the interactive corner of the banner instead of wrapping the entire application layout.

## 0.10.0

* FEAT: Added custom environment actions section and UI grid to the inspector.
* FEAT: Implemented `RegistryExtension` to enable registering environment actions directly on the service registry.
* PERF: Stored available environments and registered actions in local variables within the inspector build method to avoid redundant list allocations.

## 0.9.1


* FEAT: Added haptic feedback (`HapticFeedback.lightImpact` and `HapticFeedback.mediumImpact`) to environment switching, feature flag toggles, copy actions, and long-press inspector triggers.
* STYLE: Wrapped environment name with `Expanded` and `TextOverflow.ellipsis` to prevent overflow in layout header.
* STYLE: Added environment color indicator `avatar` and switch `tooltip` to `ChoiceChip` in environment switcher.

## 0.9.0


* FEAT: Integrated Feature Flags support in `EnvironmentInspector` with interactive toggles.
* FEAT: Implemented runtime feature flag overrides in `EnvironmentApiImpl`.
* FEAT: Updated `example` to demonstrate feature flag usage and reactivity.
* FEAT: Added standard Close button (`IconButton` with cross icon) to `EnvironmentInspector`.
* FEAT: Added accessibility semantics (`onLongPressHint`, labels, and `Sensitive configuration value` semantics) to both `EnvironmentBanner` and `EnvironmentInspector`.
* FEAT: Colored sensitive configurations with the theme's error color in the inspector.
* TEST: Enhanced tests for semantic elements and copy buttons under sensitive configurations.

## 0.8.0

* FEAT: Implemented runtime environment switching in `EnvironmentInspector`.
* FEAT: Integrated automatic service reconstruction when the environment changes via `registerResetService`.
* FEAT: Updated `EnvironmentBanner` to reactively update its text and color.
* FIX: Ensured `EnvironmentBanner` and its inspector trigger remain visible in debug mode even for production environment, hiding them only in release mode.
* PERF: Improved `EnvironmentInspector` scrollability and layout.
* CHORE: Updated `fluent_sdk` dependency to `^0.8.0`.

## 0.7.0

* CHORE: Updated `fluent_sdk` dependency to `^0.7.0`.
* REFACTOR: Refactored `EnvironmentModule` to support the new stable Registry contract.

## 0.6.0

* **FEAT**: Implement **Environment Inspector** for real-time configuration viewing and copying ([#114](https://github.com/aosorio-avilez/flutter_fluent/pull/114)).
* **FEAT**: Integrate Inspector with `EnvironmentBanner` ([#114](https://github.com/aosorio-avilez/flutter_fluent/pull/114)).
* **FEAT**: Improve accessibility and allow text style customization in `EnvironmentBanner` ([#117](https://github.com/aosorio-avilez/flutter_fluent/pull/117)).
* **FIX**: Implement redaction of sensitive keys in Environment Inspector ([#119](https://github.com/aosorio-avilez/flutter_fluent/pull/119)).
* **FIX**: Resolve directionality leakage and improve gesture handling in `EnvironmentBanner`.
* **REFACTOR**: Replace `print`/`debugPrint` with `LoggerApi`.

## 0.5.0

* Enable const constructors for EnvironmentModule
* Show/hide environment banner validation added
* Use registerLazySingleton for environment optimization

## 0.4.0

* BREAKING CHANGE: Updated `fluent_sdk` dependency to `^0.5.0`
* REFACTOR: Renamed `build` method to `onCreate` in `EnvironmentModule`
* CHORE: Recreated example platforms and updated READMEs.

## 0.3.0

* Upgrade fluent_sdk version to v0.4.0

## 0.2.0

* Upgrade package to flutter version v3.35

## 0.1.1

* Example android and ios platform updated to latest versions
* Example web platform enabled
* Dev dependencies updated

## 0.1.0

* Version of `fluent_environment_api` was updated to v0.1.0
* Hide `EnvironmentBanner` widget in production is now validate internally

## 0.0.4

* Version of `fluent_environment_api` was updated to v0.0.4
* Version of `fluent_sdk` was updated to v0.2.0

## 0.0.3

* Version of `fluent_environment_api` was updated to v0.0.3
* Dependency `fluent_sdk` was added

## 0.0.2+1

* Version of `fluent_environment_api` was updated to v0.0.2+1

## 0.0.2

* Version of `fluent_environment_api` was updated to v0.0.2
* Public APIs was documented

## 0.0.1

* Initial version.