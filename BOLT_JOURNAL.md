## 2026-01-22 - [Initialization Cost]
**Learning:** Eager loading of heavy dependencies (like `Dio` in networking or `Loggy` in logging) in `FluentModule.onCreate` causes unnecessary startup overhead, even if the feature is not immediately used.
**Action:** Use `registerLazySingleton` instead of `registerSingleton` for module dependencies to defer initialization until the first `Fluent.get<T>()` call.

## 2026-01-22 - [Global Configuration Safety]
**Learning:** Deferring initialization of global configuration (like `Loggy.initLoggy`) to a lazy singleton factory can cause race conditions where the configuration is not applied before the first usage, leading to incorrect behavior (e.g., logs leaking to console).
**Action:** Keep global configuration in `onCreate` or ensure it is initialized before any usage.
