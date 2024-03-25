## 0.0.1

* Initial version.

## 0.0.2

* Update fluent_sdk version on example project and README file.

## 0.1.0

* Remove environment dependencies
* Refactor sdk to get objects and mock object through `Fluent` class
* Removed global function `mockApi` and `getApi`
* Added `registerFactory` and `registerLazySingleton` methods to `Registry` interface in order to register a lazy singleton and factory classes
* Refactor `registerSingleton` of `Registry` interface in order to remove the `lazy` parameter
* Removed `fluent_route` from fluent_sdk
* Removed `registerRoute` method from `Registry` interface
* Added `isRegistered` method to `Registry` interface to check if an object is already registered
* Document all the public apis

## 0.1.1

* Removed flutter dependency

## 0.1.1+1

* Removed sdk flutter dependency
* Replace `flutter_test` to `test` dependency

## 0.1.2

* `reset` method was added to `Fluent` class to clear all registered objects
* Avoid clear all registered objects before build modules

## 0.2.0

* FluentModule `build` method return type was converted to async

## 0.2.1

* Example android and ios platform updated to latest versions
* Example web platform enabled
* Dev dependencies updated