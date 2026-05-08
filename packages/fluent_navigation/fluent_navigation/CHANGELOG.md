## 1.9.0

* CHORE: Updated `fluent_sdk` dependency to `^0.8.0`.

## 1.8.0

* CHORE: Updated `fluent_sdk` dependency to `^0.7.0`.
* REFACTOR: Refactored `NavigationModule` to support the new stable Registry contract.

## 1.7.0

* **Feature**: Added `replaceWith` method to `NavigationApiImpl` to allow replacing the current route without adding it to the history stack.

## 1.6.9

* **Fix**: Restored architectural stability by decoupling internal route initialization.
* **Fix**: Simplified internal navigation API and restored registry contract.

## 1.6.8

* **Fix**: Restored full compatibility with `fluent_sdk` v0.6.0.
* **Fix**: Standardized on explicit `.get<T>()` and factory patterns for maximum stability across different build environments.

## 1.6.7

* **Fix**: Optimized dependency retrieval using static locator for better modular compatibility.
* **Fix**: Adjusted singleton registration to use direct instances, resolving final compilation hurdles.

## 1.6.6

* **Fix**: Cleaned up barrel file exports to prevent type conflicts in consumer applications.
* **Fix**: Normalized internal imports to use relative paths, improving Flutter compiler compatibility.

## 1.6.5

* **Fix**: Resolved critical compilation errors when consuming the package from external apps.
* **Fix**: Replaced implicit registry calls with explicit `.get<T>()` to ensure compatibility.
* **Fix**: Corrected `registerSingleton` usage for route registration.

## 1.6.1

* **Fixes**: Fixed analysis issues on pub.dev by making dependency registration and retrieval more explicit.

## 1.6.0

*   **Features**: Added `navigatorKey` to `NavigationApi` to allow access to the global navigator state.
*   **Improvements**: Optimized dependency injection and internal router initialization for better startup performance.

## 1.5.0

* lazy initialization
* runtime optimization
* Fix `fluent_navigation` strict exports
* Enable const constructors for NavigationModule
* Upgrade `go_router` dependency to `^17.0.1`
* Upgrade `collection` dependency to `^1.19.1`

## 1.4.0

* BREAKING CHANGE: Updated `fluent_sdk` dependency to `^0.5.0`
* REFACTOR: Renamed `build` method to `onCreate` in `NavigationModule`
* CHORE: Recreated example platforms and updated READMEs.

## 1.3.1

* New parameter `refreshListenable` was added to `NavigationModule` in order to let users listen to `GoRouter` refresh streams

## 1.3.0

* Upgrade fluent_sdk version to v0.4.0

## 1.2.2

* Upgrade interface `fluent_navigation_api` to `v1.0.1`

## 1.2.1

* New method `canPop` was added in order to let users know if they can go back to previous routes

## 1.2.0

* Upgrade package to flutter version v3.35

## 1.1.0

* Package `go_router` was updated to `v13.2.1`
* Package `collection` was updated to `v1.18.0`
* Package example was updated to latest version
* Example android and ios platform updated to latest versions
* Example web platform enabled
* Dev dependencies updated

## 1.0.0

* Typedef `FluentRoutes` was added in order to use it instead of `List<RouteBase>`
* Constant `rootNavigatorKey` was added if you need to use it to define different navigations
* Extension method `registerRoute` was updated in order to use `RouteBase` instead of `GoRoute` to be able to register `ShellRoute` class for nested navigation
* Package `fluent_navigation_api` was updated to `v1.0.0`
* Package `go_router` was updated to `v9.0.0`
* Package `collection` was updated to `v1.17.1`
* Package `very_good_analysis` was updated to `v5.0.0+1`

## 0.0.6

* Class `FluentRoute` was removed
* `registerRoute` now use `GoRoute` instead of `FluentRoute` in order to expose more out-of-the-box functionalities 

## 0.0.5

* Package `fluent_sdk` was updated to `v0.2.0`

## 0.0.4

* `pop` method was added in order to let users go back to previous routes if is possible

## 0.0.3

* Package `fluent_navigation_api` was updated to `v0.0.3`
* Package `fluent_sdk` was added

## 0.0.2+1

* Package `fluent_navigation_api` was updated to `v0.0.2+1`

## 0.0.2

* Class `FluentRoute` was added to define routes (This class was removed from `fluent_sdk` package)
* A `Registry` extension was added in order to define the `registerRoute` method (This method was removed from `Registry` interface on `fluent_sdk`)
* Document all the public APIs

## 0.0.1

* Initial version.