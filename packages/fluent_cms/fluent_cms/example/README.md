# Fluent CMS Showcase Example

Demonstration application for the `fluent_cms` and `fluent_cms_api` packages.

## Overview

This example demonstrates the full omnichannel capabilities of `fluent_cms`:

- **Tier 1 (Zero-Hydration) vs Tier 3 (Reactive Hydration)**: Toggle in real-time to compare $O(1)$ fast-path rendering against dynamic mustache expressions.
- **Async Data Sources & Shimmer Skeletons**: Live simulation of asynchronous prefetching (`asyncSources`) with fallback protection and `AutoSkeletonModuleWrapper`.
- **Omnichannel Responsive Grid**: Switch between `Mobile`, `Tablet`, and `Desktop` layouts to see dynamic 12-column spans adapt seamlessly.
- **Dynamic Theme Token Resolution**: Switch between Light and Dark mode to observe `ThemeTokenResolver` dynamically resolving `{light, dark}` palettes and semantic tokens (`$surface`, `$primary`).
- **Declarative Actions**: Interactive triggers demonstrating `scroll_to`, `modal_zone` (bottom sheets), `custom_command` with optimistic counter updates and rollback, and `state_mutation`.
- **Environment Integration**: Direct access to `fluent_environment`'s `EnvironmentInspector` to toggle SDUI zone debug borders, flush caches, and inspect the active tree.
- **JSON Schema Viewer**: Inspect the live JSON Schema Draft 2020-12 generated on the fly by `CmsJsonSchemaGenerator`.

## Running the Application

Run the app on your preferred platform:

```bash
# macOS
fvm flutter run -d macos

# Android
fvm flutter run -d android

# iOS Simulator
fvm flutter run -d ios

# Web
fvm flutter run -d chrome
```

## Running Tests

```bash
fvm flutter test
```
