## 0.0.1

* Initial version.

## 0.0.2

* Class `FluentRoute` was added to define routes (This class was removed from `fluent_sdk` package)
* A `Registry` extension was added in order to define the `registerRoute` method (This method was removed from `Registry` interface on `fluent_sdk`)
* Document all the public APIs

## 0.0.2+1

* Package `fluent_navigation_api` was updated to `v0.0.2+1`

## 0.0.3

* Package `fluent_navigation_api` was updated to `v0.0.3`
* Package `fluent_sdk` was added

## 0.0.4

* `pop` method was added in order to let users go back to previous routes if is possible

## 0.0.5

* Package `fluent_sdk` was updated to `v0.2.0`

## 0.0.6

* Class `FluentRoute` was removed
* `registerRoute` now use `GoRoute` instead of `FluentRoute` in order to expose more out-of-the-box functionalities 

## 1.0.0

* Typedef `FluentRoutes` was added in order to use it instead of `List<RouteBase>`
* Constant `rootNavigatorKey` was added if you need to use it to define different navigations
* Extension method `registerRoute` was updated in order to use `RouteBase` instead of `GoRoute` to be able to register `ShellRoute` class for nested navigation
* Package `fluent_navigation_api` was updated to `v1.0.0`
* Package `go_router` was updated to `v9.0.0`
* Package `collection` was updated to `v1.17.1`
* Package `very_good_analysis` was updated to `v5.0.0+1`

## 1.1.0

* Package `go_router` was updated to `v13.2.1`
* Package `collection` was updated to `v1.18.0`
* Package example was updated to latest version
* Example android and ios platform updated to latest versions
* Example web platform enabled
* Dev dependencies updated