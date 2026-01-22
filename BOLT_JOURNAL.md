## 2026-01-22 - [Initialization Cost]
**Learning:** Eager loading of heavy dependencies (like `Dio` in networking or `Loggy` in logging) in `FluentModule.onCreate` causes unnecessary startup overhead, even if the feature is not immediately used.
**Action:** Use `registerLazySingleton` instead of `registerSingleton` for module dependencies to defer initialization until the first `Fluent.get<T>()` call.
