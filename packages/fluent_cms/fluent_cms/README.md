## fluent_cms

Enterprise Server-Driven UI (SDUI) and Headless CMS rendering engine for `flutter_fluent`.

Designed with an omnichannel, performance-first architecture, `fluent_cms` enables dynamic layouts, reactive state binding, async data hydration, and declarative interaction flows from a single JSON contract across Mobile, Tablet, and Desktop.

---

## Features

- ⚡ **Zero-Overhead Fast-Path (Tier 1)**: Pages without expressions render in $O(1)$ with `NoOpHydrationEngine`, avoiding regex evaluation and heap allocations.
- 🔄 **Reactive Opt-In Hydration (Tier 3)**: Single-pass expression resolver supporting `{{data.*}}`, `{{state.*}}`, `{{async.*}}`, `{{client.*}}`, `{{env.features.*}}`, `{{item.*}}` and `{{index}}`.
- 🧩 **Built-in & Custom Pipes**: Transform data inline (`currency`, `date`, `number`, `uppercase`, `lowercase`, `default`, `translate`) with chained pipe support.
- 📐 **Sliver-Based Omnichannel Layout**: Responsive `single_column` (Mobile) and `grid_12_cols` (Tablet/Desktop) with dynamic spans, `pinned: true` headers, and `stickyBottom: true` footers.
- 🔁 **SDUI Repeater**: Virtualized `list`, `grid`, and `carousel` repeating templates bound to data arrays.
- ⏳ **Async Sources & Auto-Skeleton**: Asynchronous data prefetching with TTL caching, fallback values, and automatic shimmer skeletons via `AutoSkeletonModuleWrapper`.
- 🎯 **Declarative Action Engine**: Concurrency management (`dropIfBusy`, `debounce`, `throttle`, `allowParallel`), optimistic UI mutations with automatic rollback, `scroll_to`, `modal_zone`, and analytics dispatch.
- 🎨 **Semantic Design Tokens**: Automatic light/dark palette resolution and design token mapping via `ThemeTokenResolver`.
- 🛡️ **Fault Isolation & Error Boundaries**: Unregistered modules render graceful fallbacks (`FallbackModuleWidget`), and build errors are isolated within `ModuleWrapperWidget`.
- 📋 **JSON Schema Validation**: Built-in JSON Schema Draft 2020-12 generation via `CmsJsonSchemaGenerator`.

---

## Getting Started

### Add dependency

```yaml
dependencies:
  fluent_cms: ^0.1.0
```

### 1. Create Custom SDUI Modules

Implement `SduiModule` and specify the unique `type` identifier corresponding to your backend JSON contract.

```dart
import 'package:fluent_cms/fluent_cms.dart';
import 'package:flutter/material.dart';

class PromoBannerModule extends SduiModule {
  const PromoBannerModule();

  @override
  String get type => 'promo_banner';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    final title = moduleContext.getString('title', defaultValue: 'Oferta');
    final discount = moduleContext.getString('discountText');
    final cardColor = moduleContext.getColor(
      context,
      'cardColor',
      defaultValue: Theme.of(context).cardColor,
    );

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.local_offer, color: Colors.amber),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: discount != null ? Text(discount) : null,
        trailing: ElevatedButton(
          onPressed: () => moduleContext.triggerAction('onTap'),
          child: const Text('Aprovechar'),
        ),
      ),
    );
  }

  @override
  Widget? buildSkeleton(BuildContext context, ModuleNode node) {
    return Container(
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
```

### 2. Configure & Build CmsModule

Register your modules, custom pipes, and global CMS configuration using `fluent_sdk`.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Fluent.build([
    EnvironmentModule(
      environment: DevEnvironment(),
      availableEnvironments: [DevEnvironment(), ProdEnvironment()],
    ),
    const CmsModule(
      config: CmsConfig(
        hydrate: true, // Enables expression hydration globally
        enableDebugOverlay: true, // Zone debug borders in non-prod
        initialModules: [
          PromoBannerModule(),
          RepeaterModule(), // Built-in virtualized repeater
        ],
      ),
    ),
  ]);

  runApp(const MainApp());
}
```

### 3. Render Pages with `CmsPageView`

Display pre-parsed `CmsPage` models or fetch remote templates on demand:

```dart
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storefront')),
      body: CmsPageView(
        pageEndpoint: '/v1/pages/home', // Or provide `page: myCmsPage`
        refreshOnAppResume: true,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

---

## Hydration Engine (Tier 1 vs Tier 3)

`fluent_cms` allows you to select the hydration strategy per-page or globally:

| Tier | Engine | Behavior | Ideal Use Case |
| :--- | :--- | :--- | :--- |
| **Tier 1** | `NoOpHydrationEngine` | Zero regex evaluation, passes values in $O(1)$ without heap allocations. | Static landing pages, marketing walls, legal docs. |
| **Tier 3** | `MixedHydrationEngine` | Single-pass expression parsing with full reactive scope interpolation. | E-commerce storefronts, dashboards, user feeds. |

### Hydration Scopes

Expressions use mustache-like syntax `{{scope.key}}` and support 7 distinct data scopes:

- `{{data.*}}`: Static context bundled with the page AST (`page.dataContext`).
- `{{state.*}}`: Ephemeral reactive page store mutated by user inputs (`pageStore`).
- `{{async.*}}`: Dynamic data resolved asynchronously by `asyncSources`.
- `{{client.*}}`: App-provided client runtime context (e.g., app version, user location).
- `{{env.features.*}}`: Feature flags evaluated in real-time via `fluent_environment`.
- `{{item.*}}`: Item model passed by parent `RepeaterModule`.
- `{{index}}`: Item index within a repeated collection.

---

## Built-in & Custom Pipes

Pipes format and transform expressions on the fly using the pipe syntax `{{value | pipeName:arg1}}` with chaining support:

```json
{
  "priceText": "{{item.price | currency:MXN}}",
  "joinedDate": "{{data.user.createdAt | date:dd/MM/yyyy}}",
  "category": "{{item.category | uppercase | default:GENERAL}}"
}
```

### Built-in Pipes

| Pipe | Description | Example |
| :--- | :--- | :--- |
| `currency` | Formats numbers with ISO 4217 currency symbols | `{{item.price \| currency:USD}}` -> `$1,250.00` |
| `date` | Formats `DateTime`, epoch milliseconds, or ISO-8601 strings | `{{data.timestamp \| date:yyyy-MM-dd}}` |
| `number` | Formats decimal numbers with custom precision | `{{item.rating \| number:1}}` -> `4.8` |
| `uppercase` | Converts string to uppercase | `{{item.code \| uppercase}}` |
| `lowercase` | Converts string to lowercase | `{{item.email \| lowercase}}` |
| `default` | Provides a fallback string if value is null or empty | `{{state.query \| default:All}}` |
| `translate` | Resolves localized strings via `translationResolver` | `{{item.tag \| translate}}` |

### Registering Custom Pipes

Create a class extending `PipeTransformer` and register it in `CmsConfig.initialPipes` or via `Fluent.get<CmsApi>().registerPipe(...)`:

```dart
class DiscountBadgePipe extends PipeTransformer {
  @override
  String get name => 'discount_badge';

  @override
  dynamic transform(dynamic value, List<String> args) {
    if (value is num && value > 0) {
      return '🔥 -${value.toInt()}% OFF';
    }
    return '';
  }
}
```

---

## Responsive Layout & Slivers

Pages describe layout configurations for multiple viewports from a single contract:

```json
{
  "layout": {
    "mobile": {
      "type": "single_column",
      "zonesOrder": ["search_zone", "banner_zone", "products_zone"]
    },
    "tablet": {
      "type": "grid_12_cols",
      "columns": [
        { "span": 12, "zones": ["search_zone"] },
        { "span": 6, "zones": ["banner_zone"] },
        { "span": 6, "zones": ["products_zone"] }
      ]
    },
    "desktop": {
      "type": "grid_12_cols",
      "columns": [
        { "span": 12, "zones": ["search_zone"] },
        { "span": 4, "zones": ["banner_zone"] },
        { "span": 8, "zones": ["products_zone"] }
      ]
    }
  }
}
```

- **`pinned: true`**: Locks a header zone at the top of the viewport using `PinnedHeaderSliver`.
- **`stickyBottom: true`**: Pins a bottom bar or checkout tray above the safe area.
- **`visibleWhen`**: Conditional zone and module visibility (e.g. `'{{env.features.loyalty_v2}} == true'`).

---

## Repeater Module

`RepeaterModule` provides high-performance virtualized rendering for repeating templates:

```json
{
  "id": "product_grid",
  "type": "cms_repeater",
  "props": {
    "layoutMode": "grid",
    "crossAxisCount": { "mobile": 2, "desktop": 4 },
    "itemsDataPath": "data.products",
    "itemTemplate": {
      "id": "product_{{item.sku}}",
      "type": "product_card",
      "props": {
        "title": "{{item.name}}",
        "price": "{{item.price | currency:MXN}}"
      }
    }
  }
}
```

---

## Async Sources & Auto-Skeleton

Define asynchronous endpoints on the page. The CMS pre-fetches them in parallel and automatically handles loading skeletons:

```json
{
  "asyncSources": {
    "wallet": {
      "endpoint": "/v1/wallet/summary",
      "ttlSeconds": 120,
      "fallback": { "balance": 0.0 }
    }
  },
  "zones": {
    "wallet_zone": {
      "requiresData": ["async.wallet"],
      "modules": [
        {
          "id": "wallet_banner",
          "type": "wallet_module",
          "props": {
            "balance": "{{async.wallet.balance | currency:MXN}}"
          }
        }
      ]
    }
  }
}
```

---

## Declarative Action Engine

Trigger actions with built-in concurrency guards and optimistic updates:

```json
{
  "actions": {
    "onTap": {
      "actionType": "custom_command",
      "target": "add_to_cart",
      "concurrency": "dropIfBusy",
      "payload": { "sku": "{{item.sku}}" },
      "optimisticState": {
        "key": "cartCount",
        "value": "{{state.cartCount + 1}}",
        "rollbackOnError": true
      },
      "onSuccess": {
        "actionType": "scroll_to",
        "target": "checkout_bar"
      }
    }
  }
}
```

### Action Types

- `state_mutation`: Updates a key in the reactive `pageStore`.
- `navigation`: Deep-links within the application.
- `external_url`: Validates scheme/host against `allowedHosts` and opens external URLs.
- `scroll_to`: Smoothly scrolls the `CustomScrollView` to the target module ID.
- `modal_zone`: Opens a zone dynamically inside a native bottom sheet.
- `custom_command`: Delegates execution to a registered `CmsCommandHandler`.
- `analytics_only`: Dispatches event to `CmsActionObserver` without UI mutations.

---

## Semantic Design Tokens

`ThemeTokenResolver` transparently resolves semantic tokens and theme maps:

```json
{
  "cardColor": {
    "light": "#FFFFFF",
    "dark": "#1A202C"
  },
  "accentColor": "$primary",
  "backgroundColor": "$surface"
}
```

---

## Environment Inspector Integration

When paired with `fluent_environment`, `fluent_cms` integrates diagnostic tools directly into the runtime `EnvironmentInspector`:

- 🟦 **Toggle CMS Zone Debug Borders**: Visually highlights SDUI zone boundaries in debug builds.
- 🧹 **Clear CMS Memory Caches**: Flushes pre-fetched `asyncSources` and in-memory page models.
- 🌳 **Inspect Active SDUI Tree**: Views the parsed AST hierarchy and reactive store state.

---

## JSON Schema Generator

Generate an official JSON Schema Draft 2020-12 representing your valid CMS contract:

```dart
final schemaJson = CmsJsonSchemaGenerator.generate(
  registeredModules: Fluent.get<CmsApi>().registeredModules,
  registeredPipes: Fluent.get<CmsApi>().pipeRegistry.registeredPipes,
);
```
