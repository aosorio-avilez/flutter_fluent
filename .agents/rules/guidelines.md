---
trigger: always_on
---

# Fluent Toolkit Blueprint & Developer Guide

This document serves as the primary guide for AI agents and developers working on the `flutter_fluent` codebase. It outlines the technology stack, architectural patterns, coding standards, and project structure for this toolkit monorepo.

## 1. Tech Stack

-  **Language:** Dart (>=3.9.2)
-  **Framework:** Flutter
-  **Version Management:** FVM (Flutter Version Management)
-  **Monorepo Management:** [Melos](https://pub.dev/packages/melos)
-  **Dependency Injection:** `fluent_sdk` (Service Locator pattern via `Fluent.get<T>()`)
-  **Navigation:** `fluent_navigation` (wrapper around `go_router`)
-  **Localization:** `fluent_localization`
-  **Networking:** `fluent_networking` (wrapper around `dio` and interceptors)
-  **Logging:** `fluent_logger` (abstracted logging mechanism)
-  **Environment Management:** `fluent_environment`
-  **Linting:** `very_good_analysis`
-  **Testing:** Native `flutter test` with `mocktail` (implied by mock structures).

## 2. Project Structure

This project is a **Toolkit Monorepo** managed by Melos, providing a cohesive set of packages for building highly scalable Flutter applications.

### Top-Level Directories

-  **`packages/`**: Contains all the toolkit modules.
   - Most major components are split into two strictly separated packages:
     -  **`fluent_<name>`**: The implementation package. Contains core logic, internal details, and tests.
     -  **`fluent_<name>_api`**: The public API package. Defines abstract interfaces, models, and contracts exposed to consumers to avoid implementation leakage.
   -  **`packages/fluent_sdk`**: The core infrastructure package providing the module system, registry, and Dependency Injection. (Does not have a separate `_api` package).

### Internal Package Structure (`packages/fluent_<name>/`)

Inside an implementation package, code is strictly organized:

-  **`lib/fluent_<name>.dart`**: The **Barrel File**. The ONLY file that should export public elements of the implementation.
-  **`lib/src/`**: Internal implementation (Never imported directly by external consumers).
   -  **`api/`**: Concrete implementations of the interfaces defined in the `_api` package.
   -  **`interceptors/` / `widgets/` / `utils/`**: Domain-specific helpers.
   -  **`<NameSpace>Module.dart`**: The module definition extending `FluentModule`. Registers dependencies and configurations.
-  **`example/`**: A standalone Flutter application demonstrating how to integrate and use the package.
-  **`test/`**: Unit tests for the package logic.
   -  **`test/mocks/`**: Mock definitions for internal/external dependencies.
   -  **`test/src/`**: Mirrored structure of `lib/src/` for targeted testing.

## 3. Architecture & Patterns

### Dependency Injection & Module System

- Use `fluent_sdk` for DI and package initialization.
- Register dependencies in the `onCreate` method of your `FluentModule` class:
```dart
@override
Future<void> onCreate(Registry registry) async {
  registry.registerLazySingleton<MyApi>((it) => MyApiImpl());
}
```
- **✅ Constructor Injection:** Always inject dependencies through the class constructor for internal logic to facilitate testing.
- Access dependencies using `Fluent.get<T>()` at the entry points or within `FluentModule` registrations:
```dart
final api = Fluent.get<MyApi>();
```

### Module Orchestration

The `Fluent.build()` method is used to initialize all modules in the correct order inside the consumer app's `main.dart` or `bootstrap.dart`:
```dart
await Fluent.build([
  EnvironmentModule(),
  NetworkingModule(),
  NavigationModule(),
  // ... other modules
]);
```

### Navigation Integration

- `fluent_navigation` provides an `InternalNavigationApi` and `NavigationApi`.
- Routes are registered using the `Registry` extension during module initialization:
```dart
registry.registerRoute(
  GoRoute(
    path: '/path',
    builder: (context, state) => const MyPage(),
  ),
);
```

### API Separation (The Contract)

- **✅ API Packages:** Define pure abstract classes/interfaces and DTOs in the `_api` package. This allows features to interact without pulling heavy third-party dependencies (like `dio` or `go_router`) into their scope.
- **❌ Direct Implementation Imports:** Never import code from `fluent_<name>/lib/src/` into another package. Always depend on `fluent_<name>_api`.

## 4. Naming Conventions

-  **Files & Directories:** `snake_case` (e.g., `navigation_module.dart`, `internal_navigation_api.dart`).
-  **Classes:** `PascalCase` (e.g., `FluentModule`, `NavigationApi`).
-  **Variables & Functions:** `camelCase` (e.g., `isRegistered`, `getRegisteredRoutes`).
-  **Tests:** Must end with `_test.dart`. Mocks should be named `[concept]_mock.dart`.

## 5. Development Commands

Run these commands from the root of the repository using `melos`:  

-  **Clean Workspace:** `melos clean`
-  **Bootstrap Dependencies:** `melos bs`
-  **Format Code:** `melos run format`
-  **Analyze Code:** `melos run analyze`
-  **Run Tests:** `melos test`
-  **Run Coverage:** `melos coverage`

*Note: When testing the `example/` apps manually, ensure you use `fvm flutter run` within the respective example directory.*

## 6. Rules for Agents (Library Maintainer Guidelines)

1.  **Library Mindset:** Remember this is a set of foundational tools. Focus on backwards compatibility, strict API contracts, and high reusability. 
2.  **Respect Module Boundaries:** Strictly adhere to the `_api` vs implementation package separation. An `_api` package should NEVER depend on its implementation counterpart.
3.  **Barrel File Strictness:** New internal classes should NOT be exported in `lib/fluent_<name>.dart` unless they are explicitly meant to be consumed by external applications (like Modules or public extensions). Keep internal logic hidden inside `src/`.
4.  **Update Registry:** When adding new services, ensure they are registered in the appropriate `FluentModule`.
5.  **Test Everything:** Any new feature, utility, or interceptor MUST be accompanied by a corresponding unit test in the `test/src/` folder. Use the `test/mocks/` directory for dependency isolation.
6.  **Example Applications:** When modifying an implementation package, you MUST verify or update its `example/` application to reflect the changes and ensure the demo does not break.

## 7. Git & PR Conventions

### Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):
-  **`feat`**: New toolkit feature/module.
-  **`fix`**: Bug fix in a package.
-  **`test`**: Adding or fixing unit tests.
-  **`refactor`**: Internal package cleanup without API changes.
-  **`docs`**: Documentation changes (README, code comments).
-  **`chore`**: Workspace updates, Melos config, CI/CD changes.

**Example:** `feat(networking): add support for global header interceptors`

### Pull Requests

- Use the provided template at `.github/PULL_REQUEST_TEMPLATE.md`.
- **Write for a non-technical audience:** Briefly describe the changes made and their impact on the consumer applications.
- Generate also the most accurate title for the PR.
- The result must be in raw markdown format (wrapped in a ```markdown code block) and in English ready for copy and paste.
- Ensure all packages in the monorepo still pass `melos run analyze` and `melos test`.
- Update `CHANGELOG.md` in the strictly affected packages.

## 8. Release Preparation

When a user requests to prepare the packages for a new release, follow these steps:

1.  **Analyze Commits:** Identify the starting point (commit hash) and analyze all commits since then.
2.  **Update CHANGELOG.md:** Add a new section at the top for the target version (e.g., `## 1.1.0`) ONLY for the packages that actually changed. Group changes by type (Features, Improvements, Bug Fixes, Chore).
3.  **Update Version:** Synchronize the version in `packages/<name>/pubspec.yaml` (and `_api` package if the contract changed).
4.  **Sync Workspace:** Run `melos clean && melos bs` to ensure all packages are up to date.
5.  **Analyze & Test:** Run `melos run analyze`, `melos test`, and `melos coverage` to validate absolute code quality.

## 9. Publish

To publish a new version of a package, navigate to the specific package directory (`packages/fluent_<name>/fluent_<name>_api` or `packages/fluent_<name>/fluent_<name>`) and use the following command first to check if the package is ready:

```bash
fvm dart pub publish --dry-run
```

If the package is ready and there are no warnings, run the final publish command:

```bash
fvm dart pub publish
```