---
trigger: always_on
---

# Expendy Blueprint & Developer Guide

This document serves as the primary guide for AI agents and developers working on the `expendy_flutter` codebase. It outlines the technology stack, architectural patterns, coding standards, and project structure.

## 1. Tech Stack

-  **Language:** Dart (>=3.10.1 <4.0.0)
-  **Framework:** Flutter
-  **Version Management:** FVM (Flutter Version Management) - *MUST use `fvm flutter` for all flutter commands.*
-  **Monorepo Management:** [Melos](https://pub.dev/packages/melos)
-  **State Management:** [Riverpod](https://riverpod.dev/) (`hooks_riverpod`, `flutter_hooks`)
-  **Dependency Injection:** `fluent_sdk` (Service Locator pattern via `Fluent.get<T>()`)
-  **Navigation:** `fluent_navigation` (wrapper around `go_router`)
-  **Localization:** `fluent_localization`
-  **Backend & DB:** Supabase
-  **Telemetry & Notifications:** Firebase (Analytics, Crashlytics, Messaging)
-  **Linting:** `very_good_analysis`
-  **UI Components:** `platform_design` package (contains `Expendy*` widgets)

## 2. Project Structure

This project follows a **Feature-First Monorepo** architecture managed by Melos.

### Top-Level Directories

-  **`apps/`**: Contains application entry points (e.g., `apps/expendy`, `apps/expendy_config`). These packages assemble features into a runnable app.
-  **`features/`**: Independent feature modules (e.g., `auth`, `wallets`).
   - Each feature is typically split into two packages:
     -  **`feature_<name>`**: The implementation package. Contains UI, logic, and internal details.
     -  **`feature_<name>_api`**: The public API package. Defines interfaces/contracts exposed to other modules to avoid circular dependencies.
-  **`platform/`**: Shared core libraries.
   -  **`platform_sdk`**: Core infrastructure, third-party wrappers, validation rules, and shared utilities.
   -  **`platform_design`**: Design system, shared UI widgets, and themes.

### Feature Package Structure (`lib/src/`)

**In `feature_<name>_api` (Public Contract):**
- `entities/`: Pure domain models shared across boundaries (e.g., `Wallet`, `Outflow`).
- `<name>_api.dart`: Abstract interfaces for internal/public use.

**In `feature_<name>` (Implementation):**
-  **`api/`**: Implementation of the interfaces defined in the `_api` package.
-  **`datasources/`**: Raw data access (Supabase RPCs, database access).
-  **`models/`**: DTOs, request models, or view models specific to the implementation (e.g., `transaction_list_item.dart`).
-  **`exceptions/`**: Custom exception classes.
-  **`notifiers/`**: Riverpod `Notifier` or `AsyncNotifier` classes for state management.
-  **`pages/`**: Screen widgets (usually extend `HookConsumerWidget`).
-  **`repositories/`**: Business logic layer that mediates between datasources and the app.
-  **`widgets/`**: Feature-specific reusable UI organisms (following Strict Composition rules).
-  **`extensions/`**: Dart extensions for UI mapping, lists, and feature-specific Analytics tracking.
-  **`<FeatureName>Module.dart`**: The module definition extending `FluentModule`. Registers routes and dependencies.

*Existing Domains Context:* `account`, `accumulators`, `auth`, `firebase`, `history`, `home`, `outflows`, `supabase`, and `wallets`. Always verify if a domain exists before creating a new one.

## 3. Architecture & Patterns

### Dependency Injection

- Use `fluent_sdk` for DI.
- Register dependencies in the `build` method of your `Module` class:
```dart
registry.registerLazySingleton<MyRepository>((it) => MyRepository());
```
- **✅ Constructor Injection:** Always inject dependencies through the class constructor. Avoid using `Fluent.get<T>()` inside business or data logic classes.
- Access dependencies using `Fluent.get<T>()` only when strictly necessary (e.g., in a Module or global provider):
```dart
final repo = Fluent.get<MyRepository>();
```

### State Management

- Use **Riverpod** (`hooks_riverpod`).
- Create Notifiers extending `Notifier<T>` or `AsyncNotifier<T>`.
- **State vs. Hooks Separation**: Use `AsyncNotifier` for business logic, DB fetching, and global state. Use `useState` (Hooks) ONLY for ephemeral, UI-only state (e.g., animations, local toggle states).
- Expose them via global `NotifierProvider` definitions.
- In widgets (`HookWidget`), use `Consumer` or `HookConsumer` to watch providers.
  
### Navigation

- Routes are registered in the `Module` class using `registry.registerRoute`.
- Use `ExpendyTransitionPage` for page transitions.
- Navigation between features is handled via the Feature API. For example, `Auth` feature might call `Fluent.get<HomeApi>().navigateToHome()`.

### Data Layer

**DataSources:**
- Use `supabase` for database access.
- Use `Fluent.get<SupabaseApi>().database` as a wrapper for Supabase interactions.
- Always use the `MapResponse` type for responses defined in `platform_sdk` when dealing with raw data.

**Repositories:**
- Wrap calls in `try-catch`.
- **MUST** log errors using `loggerApi.logError` before rethrowing or mapping to domain exceptions.

### Presentation Layer (UI)

**Composition over Inheritance (Strict):**
- We enforce a highly modular UI component strategy. Never build deep, nested widget trees in a single file.
- **The "100-Line Build Rule"**: If a `build` method exceeds roughly 100 lines, or indentation goes beyond 4 levels deep, the UI logic **must** be extracted into a smaller, private or public `StatelessWidget`/`HookConsumerWidget`.
- Keep `pages/` focused purely on scaffold layout and data connection; encapsulate specific UI logic (like forms, lists, summary cards) in standalone components inside `widgets/`.

**Widgets & Theming:**
- **❌ Avoid Raw Material Widgets:** Do not use standard Material buttons, inputs, or dialogs if an `Expendy*` equivalent exists.
- **✅ Use Platform Design:** Use widgets from `platform_design` (e.g., `ExpendyButton`, `ExpendyAppBar`, `ExpendyTextFormField`, `ExpendyCard`).
- Use `context.tr('section.key')` for translations. **Never hardcode string literals in the UI.**

**State Access & Hooks:**
- `ref.watch(provider)` for reading state.
- `ref.read(provider.notifier)` for actions.
- Use `ref.listenState` extension for side effects. Always listen to errors here to trigger error visuals, never handle business errors directly in the UI build method.
- **✅ useForm:** Always use the `useForm` mixin for form keys.
- **✅ useTextEditingController:** Always use this hook from `platform_sdk` for controllers.
- **Validation:** Use `FieldValidator` class to compose rules.

### Error Handling

- **AsyncValue:** Use `AsyncValue.guard(() async { ... })` in Notifiers to automatically handle loading and error transitions.
- **UI:** Use `.when(error: ...)` to handle error states natively.

## 4. Naming Conventions

-  **Files & Directories:** `snake_case` (e.g., `sign_in_page.dart`, `auth_repository.dart`).
-  **Classes:** `PascalCase` (e.g., `SignInPage`, `AuthRepository`).
-  **Variables & Functions:** `camelCase` (e.g., `isLoading`, `onSignInTap`).
-  **Constants:** `lowerCamelCase` or `SCREAMING_SNAKE_CASE` depending on context (prefer dart style guide).

## 5. Development Commands

Run these commands from the root of the repository using `melos` and `fvm`:  

-  **Clean Dependencies:** `melos clean`
-  **Install Dependencies:** `melos bs`
-  **Format Code:** `melos run format`
-  **Analyze Code:** `melos run analyze`
-  **Build/Run App:** Navigate to `apps/expendy` and run `fvm flutter run`.

## 6. Rules for Agents (Golden Rules)

1.  **Respect the Module Boundary:** Do not import files from `feature_<name>/src` into another feature. Always go through the `feature_<name>_api` package.
2.  **Verify Before Commit:** Always run `melos run analyze` to ensure no linting errors were introduced.
3.  **Use Existing Patterns:** Follow the established pattern of `DataSource` -> `Repository` -> `Notifier` -> `Page`.
4.  **Update Module Registry:** When creating a new Page or Service, remember to register it in the corresponding `Module.dart` file.
5.  **Prioritize Platform SDK:** Before implementing new utilities (e.g., validations, hooks), always check `platform_sdk` and `platform_design` for existing solutions. Use the provided extensions and utilities whenever possible.
6.  **THINK BEFORE YOU UI (Mandatory Plan)**: Before generating code for a new screen/page, you MUST output a brief markdown outline of the Widget Tree hierarchy, explicitly identifying which parts will be extracted into separate widget classes or files.
7.  **Max 100 Lines Build**: Never generate monolithic files. Proactively break down complex rows, columns, and lists into separate stateless/hook widgets to respect the 100-line limit per build method.

## 7. Git & PR Conventions

### Commit Messages

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for all commit messages. This helps in maintaining a clear history and automates versioning.

**Format:** `<type>(<scope>): <description>`
-  **`feat`**: A new feature for the user.
-  **`fix`**: A bug fix for the user.
-  **`refactor`**: A code change that neither fixes a bug nor adds a feature.
-  **`perf`**: A code change that improves performance.
-  **`style`**: Changes that do not affect the meaning of the code (whitespace, formatting, missing semi-colons, etc.).
-  **`docs`**: Documentation only changes.
-  **`test`**: Adding missing tests or correcting existing tests.
-  **`chore`**: Changes to the build process or auxiliary tools and libraries.

**Example:** `refactor(auth): consolidate form validation using useForm hook`

### Branch Naming

-  **Features:** `feature/<short-description>` or `feat/<short-description>`
-  **Bug Fixes:** `fix/<short-description>` or `bugfix/<short-description>`
-  **Refactor:** `refactor/<short-description>`

### Pull Requests

- Use the provided template at `.github/PULL_REQUEST_TEMPLATE.md`.
- **Write for a non-technical audience:** Briefly describe the changes made and their impact without diving into technical implementation details.
- Generate also the most accurate title for the PR.
- The result must be in raw markdown format (wrapped in a ```markdown code block) and in English ready for copy and paste.
- Ensure `melos run analyze` passes before requesting review.

## 8. Release Preparation

When a user requests to prepare the application for a new release, follow these steps:

1.  **Analyze Commits:** Identify the starting point (commit hash) and analyze all commits since then.
2.  **Update CHANGELOG.md:** Add a new section at the top for the target version (e.g., `## 1.1.0`). Group changes by type (Features, Improvements & UX, Bug Fixes, Chore).
3.  **Update Version:** Synchronize the version and build number in both the root `pubspec.yaml` and `apps/expendy/pubspec.yaml`.
4.  **Sync Workspace:** Run `melos clean && melos bs` to ensure all packages are up to date.
5.  **Analyze:** Run `melos run analyze` to verify the state of the app.

## 9. Production Build

To generate a production build for release, navigate to `apps/expendy` and use the following command:

```bash
fvm flutter build appbundle --flavor production --target lib/main_production.dart --dart-define-from-file secrets.json
```