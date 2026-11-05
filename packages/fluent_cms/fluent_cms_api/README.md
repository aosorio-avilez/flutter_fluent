## fluent_cms_api

A common interface and AST contract definitions for the [`fluent_cms`](https://github.com/aosorio-avilez/flutter_fluent/tree/main/packages/fluent_cms/fluent_cms) package.

This package defines the public contracts, abstract models, hydration interfaces, and schema generator for Server-Driven UI (SDUI) without pulling heavy third-party dependencies or implementation details.

### Core Contracts & Models

- **`CmsApi`**: Public service contract for registering modules, pipes, and command handlers.
- **`SduiModule`**: Base class for declaring custom SDUI component renderers.
- **`CmsPage` & AST Models**: Immutable data models including `ContentZone`, `ModuleNode`, `ActionNode`, `ResponsiveLayoutConfig`, `AsyncSource`, and `RepeaterConfig`.
- **`HydrationEngine` & `NoOpHydrationEngine`**: Contracts for expression evaluation and fast-path zero-overhead hydration.
- **`PipeTransformer`**: Interface for inline expression transformers.
- **`CmsPageStore`**: Interface for page-scoped reactive state management.
- **`CmsJsonSchemaGenerator`**: Generator for JSON Schema Draft 2020-12 specifications.
