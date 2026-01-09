---
trigger: always_on
---

This document serves as the primary guide for AI agents and developers working on the `flutter_fluent` codebase. It outlines the technology stack, architectural patterns, coding standards, and project structure for this toolkit.

## 1. Tech Stack

-  **Language:** Dart (>=3.9.2)
-  **Framework:** Flutter
-  **Monorepo Management:** [Melos](https://pub.dev/packages/melos)
-  **Dependency Injection:**  `fluent_sdk` (Service Locator pattern via `Fluent.get<T>()`)
-  **Navigation:**  `fluent_navigation` (wrapper around `go_router`)
-  **Localization:**  `fluent_localization`
-  **Networking:** `fluent_networking` (wrapper around `dio`)
-  **Logging:** `fluent_logger`
-  **Environment Management:** `fluent_environment`
-  **Linting:** `very_good_analysis` (implied by standard practices)

## 2. Project Structure

This project is a **Toolkit Monorepo** managed by Melos, providing a set of packages for building Flutter applications.

### Top-Level Directories

-  **`packages/`**: Contains the toolkit modules.
- Each major component is typically split into two packages:
-  **`fluent_<name>`**: The implementation package. Contains logic and internal details.
-  **`fluent_<name>_api`**: The public API package. Defines interfaces/contracts exposed to consumers to avoid implementation leakage.
-  **`packages/fluent_sdk`**: The core package providing the module system and registry.

### Package Structure (`packages/fluent_<name>/lib/src`)

Inside an implementation package, code is generally organized as:

-  **`api/`**: Implementation of the interfaces defined in the `_api` package.
-  **`provider/`**: Riverpod providers or other state management wrappers (if any).
-  **`widgets/`**: Reusable UI components specific to the toolkit's purpose.
-  **`<NameSpace>Module.dart`**: The module definition extending `FluentModule`. Registers dependencies and configurations.

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
- **✅ Constructor Injection:** Always inject dependencies through the class constructor.
- Access dependencies using `Fluent.get<T>()` at the entry points or within modules:
```dart
final api = Fluent.get<MyApi>();
```

### Module Orchestration

The `Fluent.build()` method is used to initialize all modules in the correct order:
```dart
await Fluent.build([
  EnvironmentModule(),
  NetworkingModule(),
  NavigationModule(),
  // ... other modules
]);
```

### Navigation

- `fluent_navigation` provides a `NavigationApi` (wrapping `go_router`).
- Routes are registered using the `Registry` extension:
```dart
registry.registerRoute(
  GoRoute(
    path: '/path',
    builder: (context, state) => const MyPage(),
  ),
);
```

### API Separation

- **✅ API Packages:** Define interfaces in the `_api` package. This allows other packages to depend on the interface without pulling in the implementation details.
- **❌ Direct Implementation Imports:** Never import code from `fluent_<name>/src` into another package. Always use the `_api` package.

## 4. Naming Conventions

-  **Files & Directories:**  `snake_case` (e.g., `navigation_module.dart`, `internal_navigation_api.dart`).
-  **Classes:**  `PascalCase` (e.g., `FluentModule`, `NavigationApi`).
-  **Variables & Functions:**  `camelCase` (e.g., `isRegistered`, `getRegisteredRoutes`).
-  **Constants:**  `lowerCamelCase` or `SCREAMING_SNAKE_CASE` (follow Dart style guide).

## 5. Development Commands

Run these commands from the root of the repository using `melos`:  

-  **Clean Workspace:**  `melos clean`
-  **Bootstrap Dependencies:**  `melos bs`
-  **Format Code:**  `melos format`
-  **Analyze Code:**  `melos analyze`
-  **Run Tests:** `melos test`
-  **Run Coverage:** `melos coverage`

## 6. Rules for Agents

1.  **Library Mindset:** Remember this is a set of tools. Focus on API clarity, modularity, and extensibility.
2.  **Respect Module Boundaries:** Strictly adhere to the `_api` vs implementation package separation.
3.  **Update Registry:** When adding new services, ensure they are registered in the appropriate `FluentModule`.
4.  **Verify Before Commit:** Always run `melos analyze`, `melos test`, and `melos coverage` to ensure the code is of high quality.
5.  **Example Applications:** When modifying a package, check its `example/` directory to ensure the changes don't break the demo apps.

## 7. Git & PR Conventions

### Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):
-  **`feat`**: New toolkit feature/module.
-  **`fix`**: Bug fix in a package.
-  **`refactor`**: Internal package cleanup.
-  **`docs`**: Documentation changes.
-  **`chore`**: Workspace updates, Melos config, etc.

**Example:**  `feat(navigation): add support for nested routing`

### Pull Requests

- Use the provided template at [.github/PULL_REQUEST_TEMPLATE.md].
- **Write for a non-technical audience:** Briefly describe the changes made and their impact without diving into technical implementation details.
- The result must be in raw markdown format (wrapped in a ```markdown code block) and in English ready for copy and paste.
- Ensure all packages in the monorepo still pass analysis.
- Update `CHANGELOG.md` in the affected packages if necessary.

## 8. Release Preparation

When a user requests to prepare the packages for a new release, follow these steps:

1.  **Analyze Commits:** Identify the starting point (commit hash) and analyze all commits since then.
2.  **Update CHANGELOG.md:** Add a new section at the top for the target version (e.g., `## 1.1.0`). Group changes by type (Features, Improvements, Bug Fixes, Chore).
3.  **Update Version:** Synchronize the version and build number in both the root `pubspec.yaml` and `packages/<name>/pubspec.yaml`.
4.  **Sync Workspace:** Run `melos clean && melos bs` to ensure all packages are up to date.
5.  **Analyze:** Run `melos run analyze` to validate code quality.
6.  **Test:** Run `melos test` to run all tests.
7.  **Coverage:** Run `melos coverage` to validate code coverage.

## 9. Publish

To publish a new version of a package, navigate to `packages/fluent_<name>/fluent_<name>_api` or `packages/fluent_<name>/fluent_<name>` and use the following command first to check if the package is ready to be published:

```bash
fvm dart pub publish --dry-run
```

If the package is ready to be published, run the following command:

```bash
fvm dart pub publish
```