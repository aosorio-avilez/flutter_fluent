## 0.0.1

* Initial version.

## 0.0.2

* Version of `fluent_sdk` was updated to v0.1.1
* Public APIs was documented

## 0.0.2+1

* Dev dependency `flutter_test` was removed

## 0.0.3

* Dependency `fluent_sdk` was removed

## 0.0.4

* `pathFunction` parameter was added to `getLocalizationDelegates` in order to change the default localization file
* `args` parameter was added to `translate` in order to enable format arguments

## 1.0.0

* `getLocalizationDelegates` API method signature changed to `getDelegate` in order to return only the localization delegate

## 1.0.1

* `getDelegate` API method signature changed to `getDelegates` in order to return all localization delegate needed
* Added `shouldThrowExceptions` parameter to `getDelegates` API method in order to silence exception when the delegate try to load resources, this is convinience for example when you are execute unit test

## 1.0.2

* Removed `shouldThrowExceptions` parameter to `getDelegates` API method

