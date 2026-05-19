## 0.6.0

* FEAT: Added Feature Flags capability to `Environment` and `EnvironmentApi`.
* FEAT: Added `isFeatureEnabled` and `setFeatureFlag` to `EnvironmentApi`.

## 0.5.0

* FEAT: Added `environmentNotifier` (ValueListenable) to `EnvironmentApi` for reactive UI updates.
* FEAT: Added `updateEnvironment` and `availableEnvironments` to support runtime environment switching.
* FEAT: Added `registerResetService` to allow automatic reconstruction of dependent services (e.g., Networking) when the environment changes.

## 0.4.0

* **FEAT**: Add `sensitiveKeys` support to `Environment` model.
* **FEAT**: Update `EnvironmentApi` to support environment inspection.

## 0.3.0

* Update version to 0.3.0

## 0.2.0

* FIX: `EnvironmentType` typo was fixed
* FEAT: Add convenience extension on `EnvironmentType`

## 0.1.0

* Method `getEnvironment` replaced by `environment` getter on `EnvironmentApi` interface
* Method `buildEnvironmentBanner` method removed in favor of export `EnvironmentBanner` widget directly

## 0.0.4

* `type` getter was added to `Environment` interface

## 0.0.3

* Dependency `fluent_sdk` was removed

## 0.0.2+1

* Dev dependency `flutter_test` was removed

## 0.0.2

* Version of `fluent_sdk` was updated to v0.1.1
* `Environment` class was added (This class was removed from `fluent_sdk`)
* Public APIs was documented

## 0.0.1

* Initial version.