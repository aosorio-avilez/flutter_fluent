## 0.0.1

* Initial version.

## 0.0.2

* Version of `fluent_environment_api` was updated to v0.0.2
* Public APIs was documented

## 0.0.2+1

* Version of `fluent_environment_api` was updated to v0.0.2+1

## 0.0.3

* Version of `fluent_environment_api` was updated to v0.0.3
* Dependency `fluent_sdk` was added

## 0.0.4

* Version of `fluent_environment_api` was updated to v0.0.4
* Version of `fluent_sdk` was updated to v0.2.0

## 0.1.0

* Version of `fluent_environment_api` was updated to v0.1.0
* Hide `EnvironmentBanner` widget in production is now validate internally

## 0.1.1

* Example android and ios platform updated to latest versions
* Example web platform enabled
* Dev dependencies updated

## 0.2.0

* Upgrade package to flutter version v3.35

## 0.3.0

* Upgrade fluent_sdk version to v0.4.0

## 0.4.0

* BREAKING CHANGE: Updated `fluent_sdk` dependency to `^0.5.0`
* REFACTOR: Renamed `build` method to `onCreate` in `EnvironmentModule`
* CHORE: Recreated example platforms and updated READMEs.

## 0.5.0

* Enable const constructors for EnvironmentModule
* Show/hide environment banner validation added
* Use registerLazySingleton for environment optimization
* Added `textStyle` parameter to `EnvironmentBanner` for better customization
* Fixed `Directionality` leakage in `EnvironmentBanner` to prevent affecting child layouts