## 0.0.1

* Initial version.

## 0.0.2

* Version of `fluent_networking_api` was updated to v0.0.3

## 0.0.2+1

* Removed sdk flutter dependency
* Replace `flutter_test` to `test` dependency

## 0.0.3

* Dependency `fluent_sdk` was added
* Version of `fluent_networking_api` was updated to v0.0.4

## 0.0.4

* Version of `fluent_sdk` was updated to v0.2.0

## 0.1.0

* Upgrade package to flutter version v3.35

## 0.2.0

> **BREAKING CHANGE:** This version migrates response handling to Sealed Classes.

* **FIX:** Interceptors provided in config are now correctly added to Dio.
* **REFACTOR:** `NetworkingConfig` now requires `enableLog` boolean instead of auto-detecting debug mode.
* **FEAT:** Defined `ResponseResult` as a `sealed class` for exhaustiveness checking.
* **REFACTOR:** Renamed/Removed old result classes (`Succeeded`, `Failed`, `Error`) in favor of `Success` and `Failure`.

## 0.3.0

* Upgrade fluent_sdk version to v0.4.0

## 0.4.0

* BREAKING CHANGE: Updated `fluent_sdk` dependency to `^0.5.0`
* REFACTOR: Renamed `build` method to `onCreate` in `NetworkingModule`
* CHORE: Recreated example platforms and updated READMEs.

## 0.5.0

* lazy initialization
* Enable const constructors for NetworkingModule and NetworkingConfig
* Guard debug tools for tree-shaking
* Refactor fluent networking package
* Upgrade `dio` dependency to `^5.9.1`
* Upgrade `equatable` dependency to `^2.0.8`