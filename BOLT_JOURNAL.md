## 2026-01-22 - [Initialization Cost]
**Learning:** Eager loading of heavy dependencies (like `Dio` in networking or `Loggy` in logging) in `FluentModule.onCreate` causes unnecessary startup overhead, even if the feature is not immediately used.
**Action:** Use `registerLazySingleton` instead of `registerSingleton` for module dependencies to defer initialization until the first `Fluent.get<T>()` call.

## 2026-01-22 - [Global Configuration Safety]
**Learning:** Deferring initialization of global configuration (like `Loggy.initLoggy`) to a lazy singleton factory can cause race conditions where the configuration is not applied before the first usage, leading to incorrect behavior (e.g., logs leaking to console).
**Action:** Keep global configuration in `onCreate` or ensure it is initialized before any usage.

## 2026-01-22 - [Tree-Shaking & Production Safety]
**Learning:** Simply checking `if (config.enableLog)` allows debug-only packages (like `pretty_dio_logger`) to be included in the release bundle.
**Action:** Guard debug tool instantiation with `!const bool.fromEnvironment('dart.vm.product')` to allow the compiler to tree-shake the dependency entirely in production builds.

## 2026-01-24 - [String Interpolation Optimization]
**Learning:** Iterative `replaceAll` for string interpolation is O(N*M) and creates intermediate string allocations for every argument.
**Action:** Use `RegExp.replaceAllMapped` to perform single-pass interpolation (O(M)), reducing CPU and memory overhead significantly for localization.

## 2026-05-25 - [JSON Parsing Optimization]
**Learning:** `Isolate.run` has significant overhead (2-10ms) which exceeds the parsing time for small JSON payloads (<50KB). This delays UI availability during startup.
**Action:** Use a hybrid parsing strategy: Sync parsing for small files (<50KB), Async Isolate for large files.

## 2026-05-25 - [Closure Allocation in Hot Paths]
**Learning:** Usage of higher-order functions like `Iterable.any` in frequently called methods (like `LocalizationsDelegate.isSupported`) creates closure allocations that add unnecessary pressure to the GC.
**Action:** Use standard `for-in` loops in critical paths to eliminate closure overhead.
