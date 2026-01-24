## 2026-01-22 - [Initialization Cost]
**Learning:** Eager loading of heavy dependencies (like `Dio` in networking or `Loggy` in logging) in `FluentModule.onCreate` causes unnecessary startup overhead, even if the feature is not immediately used.
**Action:** Use `registerLazySingleton` instead of `registerSingleton` for module dependencies to defer initialization until the first `Fluent.get<T>()` call.

## 2024-05-22 - [Strict Exports]
**Learning:** Exporting implementation files (e.g., `package:lib/src/...`) bypasses public API boundaries and threatens stability if internal structures change. It also exposes symbols not intended for public consumption, potentially hindering tree-shaking.
**Action:** Always export from the package's main entry point (e.g., `package:lib/lib.dart`) and use `show` to strictly define the API surface.
