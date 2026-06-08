## 0.9.2

* PERF: Optimized `NetworkingLogInterceptor` formatting by decoding JSON string data prior to sanitization.
* PERF: Used `uri.hasQuery` check instead of allocating a `queryParameters` map when checking for empty query params.
* PERF: Avoided redundant empty map allocation when merging request options without extra configuration.
* PERF: Reduced map lookups during API error mapping by fetching error message directly without redundant `containsKey` checks.
* PERF: Simplified sensitive keys lookup in logs by directly checking lowercase keys against lowercased predefined sets.

## 0.9.1


* PERF: Optimized `NetworkingLogInterceptor` header formatting to use a lazy `sync*` generator and avoided closure allocation overhead in the logging path.
* PERF: Cached `queryParametersAll` lookup in URI sanitization to reduce getter invocations.

## 0.9.0

* CHORE: Updated `fluent_sdk` dependency to `^0.8.0`.

## 0.8.0

* FEAT: Add support for `FormData` sanitization in log interceptor.
* SECURITY: Expanded default sensitive keys for headers, query params, and body (including email, phone_number, and credit_card).
* PERF: Optimized sensitive key checking for `FormData` fields.
* PERF: Further optimized `NetworkingLogInterceptor` map processing and reduced allocations.

## 0.7.0

* FIX: Redact sensitive query parameters in log interceptor.
* PERF: Optimized `NetworkingLogInterceptor` string processing and allocations.
* CHORE: Updated `fluent_sdk` dependency to `^0.7.0`.
* REFACTOR: Refactored `NetworkingModule` to support the new stable Registry contract.

## 0.6.0

* **FEAT**: Implement caching support using `NetworkingCacheInterceptor`.
* **FEAT**: Implement customizable retry policy with `NetworkingRetryInterceptor` (PR #108).
* **PERF**: Optimize performance and memory efficiency in `NetworkingLogInterceptor`.
* **PERF**: Optimize `LoggerApi` lookup in `NetworkingLogInterceptor`.
* **FIX**: Restore secure logging features and custom redaction support.

## 0.5.4

* **FIX**: Reintroduce `Options` export that was missed in previous merge.

## 0.5.3

* **FEAT**: Add customizable retry interceptor and test coverage.
* **FIX**: Implement secure logging with body sanitization and configurable redaction.
* **FIX**: Add missing dio exports.
* **PERF**: Optimize logging in networking interceptor.

## 0.5.2

* **FIX**: Implement a secure `NetworkingLogInterceptor` that redacts sensitive headers (Authorization, Cookie, Set-Cookie).
* **FEAT**: Expose `Options` type from `dio` in the public barrel file.
* **REFACTOR**: Integrate `LoggerApi` for internal package logging instead of `print`/`debugPrint`.
* **CHORE**: Replace `pretty_dio_logger` dependency with `fluent_logger_api`.

## 0.5.1

* **FIX**: Export common dio types and cleanup test imports.

## 0.5.0

* lazy initialization
* Enable const constructors for NetworkingModule and NetworkingConfig
* Guard debug tools for tree-shaking
* Refactor fluent networking package
* Upgrade `dio` dependency to `^5.9.1`
* Upgrade `equatable` dependency to `^2.0.8`

## 0.4.0

* BREAKING CHANGE: Updated `fluent_sdk` dependency to `^0.5.0`
* REFACTOR: Renamed `build` method to `onCreate` in `NetworkingModule`
* CHORE: Recreated example platforms and updated READMEs.

## 0.3.0

* Upgrade fluent_sdk version to v0.4.0

## 0.2.0

> **BREAKING CHANGE:** This version migrates response handling to Sealed Classes.

* **FIX:** Interceptors provided in config are now correctly added to Dio.
* **REFACTOR:** `NetworkingConfig` now requires `enableLog` boolean instead of auto-detecting debug mode.
* **FEAT:** Defined `ResponseResult` as a `sealed class` for exhaustiveness checking.
* **REFACTOR:** Renamed/Removed old result classes (`Succeeded`, `Failed`, `Error`) in favor of `Success` and `Failure`.

## 0.1.0

* Upgrade package to flutter version v3.35

## 0.0.4

* Version of `fluent_sdk` was updated to v0.2.0

## 0.0.3

* Dependency `fluent_sdk` was added
* Version of `fluent_networking_api` was updated to v0.0.4

## 0.0.2+1

* Removed sdk flutter dependency
* Replace `flutter_test` to `test` dependency

## 0.0.2

* Version of `fluent_networking_api` was updated to v0.0.3

## 0.0.1

* Initial version.