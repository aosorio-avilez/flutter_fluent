# **Architectural Blueprint: `fluent_cms` & `fluent_cms_api`**

# **1\. Visión y Propósito del Sistema**

Motor empresarial de **Server-Driven UI (SDUI)** y **Headless CMS** para Flutter (Android, iOS, Web, Windows, macOS, Linux) integrado de forma nativa en el ecosistema flutter\_fluent.

A diferencia de las librerías que serializan widgets primitivos de Flutter (`Padding`, `Row`, `Column`), **`fluent_cms`** opera bajo el paradigma de **Módulos de Negocio Semánticos distribuidos en Content Zones Responsivas**. Esto desacopla el backend de los detalles de implementación visual de Flutter, permitiendo que un único payload JSON sirva a múltiples plataformas sin duplicar tenants.

## **Principios Fundamentales (Core Tenets)**

* **Contract-First Architecture:** Separación estricta entre contratos/modelos (`fluent_cms_api`) e implementación/motor de renderizado (`fluent_cms`), siguiendo el estándar de `flutter_fluent`.  
* **Universal Module Portability:** Los módulos nunca están restringidos por `PageType`. Cualquier módulo registrado puede inyectarse en cualquier página y zona siempre que cumpla con las restricciones de espacio (*Zone Constraints*).  
* **Single-Tenant Omnichannel Payload:** Un solo contrato JSON define la página. La adaptación entre Mobile (1 columna vertical de Slivers) y Web/Desktop (grillas multi-columna) ocurre en el cliente mediante reglas declarativas por *breakpoint*.  
* **Progressive Disclosure (Opt-in Hydration):**  
  1. **Tier 1 (Zero-Hydration):** Renderizado directo de propiedades estáticas en `O(1)` usando `NoOpHydrationEngine`. Los módulos pueden consumir sus propios servicios en el FE.  
  2. **Tier 2 (Sync Context Injection):** Interpolación de placeholders `{{...}}` con datos pre-hidratados en el JSON (`dataContext`) o en memoria del cliente (`clientContext`).  
  3. **Tier 3 (Full Mixed Hydration):** Descarga asíncrona por módulo (`asyncSources`), *Auto-Skeletons*, *Pipe Transformers* (`| currency`, `| translate`) y estado reactivo entre zonas.  
* **Forward Compatibility (Never Crash):** Degradación elegante obligatoria (`SizedBox.shrink()` en release, tarjeta visual de diagnóstico en debug) ante módulos, acciones o propiedades desconocidas.

# **2\. Estructura dentro del Monorepo `flutter_fluent`**

Se incorpora al `pubspec.yaml` raíz (Dart Workspace \+ Melos) manteniendo el estándar de calidad del repositorio (`very_good_analysis` y cobertura mínima del 90%):

```
packages/
└── fluent_cms/
    ├── fluent_cms_api/                # Dart/Flutter API Contract
    │   ├── lib/
    │   │   ├── fluent_cms_api.dart
    │   │   └── src/
    │   │       ├── cms_api.dart                 # Interfaz principal registrada en Fluent
    │   │       ├── models/                      # AST Inmutable (CmsPage, ContentZone, ModuleNode, ActionNode)
    │   │       ├── registry/                    # Contratos SduiModule, CmsModuleContext, ZoneConstraints
    │   │       ├── hydration/                   # Contratos HydrationEngine, PipeTransformer, AsyncDataSource
    │   │       ├── state/                       # Contrato CmsPageStore (Two-way binding y validación)
    │   │       └── schema/                      # Generador de JSON Schema (Draft 2020-12) para IDEs
    │   └── test/
    │
    └── fluent_cms/                    # Implementación del Motor y Widgets
        ├── lib/
        │   ├── fluent_cms.dart
        │   └── src/
        │       ├── cms_module.dart              # FluentModule para registro en Fluent.build([])
        │       ├── cms_config.dart              # Configuración global (breakpoints, fallbacks, flags)
        │       ├── api/                         # CmsApiImpl y NoOpHydrationEngine
        │       ├── parser/                      # Hybrid Isolate JSON Parser (<50KB sync / >=50KB Isolate)
        │       ├── engine/                      # Sliver Zone Engine, Responsive Layout, Repeater & Viewport Impression
        │       ├── hydration/                   # Single-pass ExpressionResolver ({{}}), Pipes y Auto-Skeleton
        │       ├── actions/                     # ActionEngine (Debounce, DropIfBusy, Optimistic Rollback)
        │       ├── theming/                     # Semantic Token Resolver (Light/Dark Mode)
        │       └── inspector/                   # Integración con fluent_environment (Overlay de zonas y caché)
        ├── example/                             # App omnicanal de demostración
        └── test/
```

# **3\. Sinergia Nativa con el Ecosistema `flutter_fluent`**

`fluent_cms` descubre dinámicamente los demás paquetes del ecosistema a través del Registry de fluent\_sdk sin forzar dependencias duras hacia sus implementaciones (`it.isRegistered<T>()`):

* **`fluent_sdk`:** Inicialización mediante `CmsModule` usando `registerLazySingleton` para evitar costo de arranque hasta que se abra la primera pantalla controlada por CMS.  
* **`fluent_networking_api`:** Si `NetworkingApi` está registrado en `Fluent`, el motor lo utiliza automáticamente para descargar las páginas JSON y resolver los `asyncSources`, heredando el caché LRU (`CacheConfig`), reintentos (`RetryConfig`), sanitización de logs y generación de cURLs.  
* **`fluent_environment_api`:**  
  * Se suscribe a `registerResetService<CmsApi>()` para limpiar el caché de plantillas y recargar las pantallas activas cuando el desarrollador cambie de entorno (`Dev` \-\> `Staging` \-\> `Prod`) en tiempo de ejecución.  
  * Expone el scope `{{env.features.flag_name}}` en `visibleWhen` conectado a `EnvironmentApi.isFeatureEnabled()`, permitiendo prender o apagar zonas y módulos en vivo desde el `EnvironmentInspector`.  
  * Registra acciones rápidas vía `registerEnvironmentAction`: *"Toggle CMS Zone Debug Borders"* y *"Flush CMS Page Cache"*.  
* **`fluent_logger_api`:** Reporta advertencias de módulos no registrados, errores de interpolación o fallos de validación de esquemas a `LoggerApi` (con costo cero en producción gracias a `NoOpLoggerApiImpl`).  
* **`fluent_localization_api` y `fluent_navigation_api`:** Provee el pipe nativo `| translate` para traducir claves dinámicas usando la localización activa, y encamina las acciones `actionType: "navigation"` directamente hacia `NavigationApi` si está disponible.

# **4\. Reglas Estrictas de Rendimiento (Mandatos de `BOLT_JOURNAL.md`)**

Todo código generado para `fluent_cms` debe cumplir las siguientes invariantes de rendimiento:

1. **Hybrid JSON Parsing (Umbral de 50KB):** `Isolate.run` introduce un overhead de 2-10ms. El `CmsPageParser` debe evaluar el tamaño del payload: si `rawJson.length < 50000`, parsea de forma síncrona en el hilo actual; si es `>= 50000`, delega la deserialización del AST a `Isolate.run()`.  
2. **Single-Pass Interpolation (`O(M)`):** Prohibido el uso de `.replaceAll()` iterativos. El `ExpressionResolver` debe utilizar una única expresión regular precompilada (`static final _tokenRegExp = RegExp(r'\{\{([^}]+)\}\}')`) con `replaceAllMapped` en una sola pasada. Además, aplica **Fast-Path**: si `!value.contains('{{')`, retorna la referencia del `String` original en `O(1)`.  
3. **Zero Closure Allocations en Hot Paths:** En los métodos `build` de zonas, resolución de propiedades y evaluación de visibilidad, está prohibido encadenar `.map()`, `.where()` o `.any()`. Se deben utilizar bucles `for-in` o `for (var i = 0; ...)` estándar para evitar alojar *closures* que presionen al Garbage Collector durante el scroll a 120fps.  
4. **No-Op Pattern & Tree-Shaking:** Cuando la hidratación o las herramientas visuales de debug de zonas estén desactivadas, se deben usar implementaciones `const NoOp...` decoradas con `@pragma('vm:prefer-inline')` y protegidas con `!const bool.fromEnvironment('dart.vm.product')` para garantizar *tree-shaking* total en binarios de producción.

# **5\. Especificación de Subsistemas y Solución a los 8 Gaps Críticos**

## **5.1. Layout Responsivo Omnicanal y Content Zones**

* Cada `CmsPage` organiza sus módulos dentro de `ContentZones` semánticas (ej. `header_zone`, `hero_zone`, `main_feed`, `sidebar_zone`, `sticky_bottom`).  
* El nodo `layout` define cómo se distribuyen las zonas por *breakpoint* (`mobile`, `tablet`, `desktop`):  
  * En **Mobile**, las zonas fluyen en un único `CustomScrollView` unificado basado en `Slivers`.  
  * En **Web/Desktop**, un `ResponsiveZoneLayout` distribuye las zonas en columnas (ej. `main_feed` 8 columnas a la izquierda, `sidebar_zone` 4 columnas fijas a la derecha) usando el mismo JSON.  
* Los módulos soportan `platforms: ["android", "ios", "web", "desktop"]` y `responsiveProps` para sobrescribir propiedades específicas según el tamaño de pantalla.

## **5.2. Listas Infinitas y Plantillas Repetibles (`RepeaterModule` \- *Gap 1*)**

* Para evitar que el backend envíe cientos de nodos repetidos en catálogos o feeds, se incluye el módulo estructural nativo `cms_repeater`.  
* Recibe un `itemTemplate` (un `ModuleNode` con placeholders `{{item.*}}` e `{{index}}`), un arreglo inicial en `itemsDataPath` (ej. `"data.products"`) y una configuración opcional `pagination` (`endpoint`, `pageParam`, `pageSize`).  
* Se renderiza internamente como un `SliverList.builder` o `SliverGrid.builder` perezoso que dispara la carga de la siguiente página al alcanzar el umbral de scroll.

## **5.3. Analítica de Impresiones Reales en Viewport (`onImpression` \- *Gap 2*)**

* Además de `onTap`, `onLongPress` y `onSubmit`, todo módulo soporta el disparador `"onImpression"`.  
* El `ModuleWrapperWidget` monitorea la fracción visible real en el viewport (por defecto: `>= 50%` del área visible durante `>= 800ms`) antes de emitir el evento de analítica, evitando falsos positivos por el `cacheExtent` de los `Slivers`. Incluye deduplicación por `module.id` durante el ciclo de vida de la página.

## **5.4. Semantic Design Tokens & Dark Mode (`ThemeTokenResolver` \- *Gap 3*)**

* Las propiedades de color, tipografía y espaciado en el JSON aceptan:  
  1. Tokens semánticos registrados (ej. `"color": "$surfacePrimary"`, `"padding": "$spacingMd"`).  
  2. Mapas adaptativos por brillo: `"backgroundColor": { "light": "#FFFFFF", "dark": "#121212" }`.  
  3. Valores directos HEX (`"#FF5733"`).  
* `CmsModuleContext` expone helpers tipados (`props.getColor(context, 'backgroundColor')`, `props.getEdgeInsets('padding')`) que resuelven automáticamente el token según el `ThemeData` actual.

## **5.5. Ciclo de Vida de Página, Pull-to-Refresh y Caché (*Gap 4*)**

* `CmsPageView` integra soporte nativo para `Pull-to-Refresh` y re-hidratación opcional al regresar del background (`refreshOnAppResume`).  
* Al refrescar, solicita a `NetworkingApi` o al `AsyncDataFetcher` los datos con `CacheConfig(forceRefresh: true)` y permite conservar los valores que el usuario ya había escrito en el formulario local si `preserveStateOnRefresh: true`.

## **5.6. Motor de Acciones con Concurrencia, Debounce y Optimistic UI (*Gap 5*)**

* Cada `ActionNode` incluye una política de concurrencia declarativa:  
  * `"concurrency": "dropIfBusy"` (por defecto en acciones de red/navegación: ignora toques repetidos mientras el `Future` de la acción está en curso y notifica al módulo mediante `moduleContext.isActionRunning`).  
  * `"concurrency": "debounce"` o `"throttle"` (configurable en milisegundos, ideal para barras de búsqueda o filtros dinámicos).  
* **Optimistic State Mutation:** Una acción puede declarar `"optimisticState": { "key": "isFavorite", "value": true, "rollbackOnError": true }`. El cambio se refleja en 0ms en la UI y se revierte automáticamente si el comando devuelve `Failure`.

## **5.7. Preservación de Estado en Scroll (`keepAlive` \- *Gap 6*)**

* Los módulos que contienen estado interno pesado (carruseles horizontales con scroll propio, reproductores de video, mapas) pueden declarar `"keepAlive": true` en el JSON. El motor los envuelve automáticamente con `AutomaticKeepAlive` y les asigna un `PageStorageKey(module.id)`.

## **5.8. Accesibilidad Declarativa (`a11y` \- *Gap 7*)**

* Todo `ModuleNode` soporta el nodo opcional `"a11y"` (`label`, `hint`, `isButton`, `isHeader`, `excludeSemantics`).  
* El `ModuleWrapperWidget` construye el nodo `Semantics` correspondiente alrededor del módulo con las cadenas ya hidratadas por el `ExpressionResolver`.

## **5.9. Deep-Linking Interno y Auto-Scroll (`scrollToModule` \- *Gap 8*)**

* `CmsPageController` mantiene el registro de `GlobalObjectKey` por cada `module.id` y `zoneId`.  
* Permite invocar programáticamente `controller.scrollToModule('terms_block')` o disparar la acción declarativa `"actionType": "scroll_to", "target": "terms_block"` con curva y duración configurables.

## **5.10. Blindajes Críticos de Arquitectura y Resiliencia v1.0**

* **Error Boundary a nivel Módulo:** En `ModuleWrapperWidget`, la invocación de `module.build(context, moduleContext)` debe estar envuelta en un bloque `try-catch` y protegida por un `ErrorWidget` local. Si un módulo arroja una excepción en su inicialización o renderizado, se colapsa a `SizedBox.shrink()` en release (mostrando tarjeta diagnóstica en debug) y reporta el fallo a `LoggerApi` con el `moduleId` causante, garantizando que un módulo defectuoso no derribe la pantalla entera.  
* **Whitelisting de URLs y Endpoints (Sentinel Security):**`CmsConfig` debe exponer una lista restrictiva `Set<String>? allowedHosts` y validar esquemas permitidos (`http`, `https`) antes de resolver peticiones en `asyncSources` o ejecutar acciones de navegación externa (`external_url`), bloqueando esquemas no seguros o no autorizados (ej. `javascript:`, `tel:`, `file:`).  
* **Limpieza de Timers y Concurrencia (isDisposed Guard):** Tanto `PageScopedReactiveStore` como `CmsActionEngine` deben cancelar sus `Timer` activos en `dispose()` y verificar explícitamente `if (isDisposed) return;` después de cualquier operación asíncrona (`await`) o callback de temporizador antes de intentar mutar el estado o notificar escuchas, erradicando errores de ciclo de vida.

# **6\. Especificación del Contrato JSON (Master Schema v1.0)**

```
{
  "schemaVersion": "1.0.0",
  "pageId": "home_omnicanal",
  "cacheTtlSeconds": 600,
  "refreshable": true,
  "preserveStateOnRefresh": true,
  "dataContext": {
    "user": { "firstName": "Alfonso", "tier": "Gold" },
    "membership": { "active": true, "savings": 1250.50 }
  },
  "asyncSources": {
    "wallet": {
      "endpoint": "/v1/wallet/summary",
      "ttlSeconds": 120,
      "fallback": { "balance": 0.0 }
    }
  },
  "layout": {
    "mobile": {
      "type": "single_column",
      "zonesOrder": ["sticky_top", "hero_zone", "main_feed", "promo_sidebar"]
    },
    "desktop": {
      "type": "grid_12_cols",
      "columns": [
        { "span": 12, "zones": ["sticky_top", "hero_zone"] },
        { "span": 8, "zones": ["main_feed"] },
        { "span": 4, "zones": ["promo_sidebar"] }
      ]
    }
  },
  "zones": {
    "sticky_top": {
      "pinned": true,
      "modules": [
        {
          "id": "search_bar_mod",
          "type": "search_input_module",
          "props": {
            "placeholder": "Buscar productos...",
            "bindTo": "searchQuery",
            "backgroundColor": "$surfaceSecondary"
          },
          "actions": {
            "onChanged": {
              "actionType": "custom_command",
              "target": "filter_results",
              "concurrency": "debounce",
              "debounceMs": 300,
              "payload": { "query": "{{state.searchQuery}}" }
            }
          }
        }
      ]
    },
    "hero_zone": {
      "modules": [
        {
          "id": "loyalty_hero_1",
          "type": "loyalty_banner",
          "platforms": ["android", "ios", "web"],
          "visibleWhen": "{{data.membership.active}} == true && {{env.features.loyalty_v2}} == true",
          "requiresData": ["async.wallet"],
          "keepAlive": true,
          "a11y": {
            "label": "Resumen de membresía de {{data.user.firstName}}",
            "isButton": true
          },
          "props": {
            "greeting": "Hola, {{data.user.firstName}}",
            "savingsText": "Ahorro acumulado: {{data.membership.savings | currency:MXN}}",
            "walletText": "Cashback: {{async.wallet.balance | currency:MXN}}",
            "cardColor": { "light": "#F5F7FA", "dark": "#1E222A" }
          },
          "responsiveProps": {
            "mobile": { "compactMode": true, "maxLines": 2 },
            "desktop": { "compactMode": false, "maxLines": 4 }
          },
          "actions": {
            "onImpression": {
              "actionType": "analytics_only",
              "analytics": { "event": "hero_loyalty_viewed", "tier": "{{data.user.tier}}" }
            },
            "onTap": {
              "actionType": "navigation",
              "target": "/wallet-details",
              "concurrency": "dropIfBusy",
              "payload": { "source": "home_hero" }
            }
          }
        }
      ]
    },
    "main_feed": {
      "modules": [
        {
          "id": "catalog_repeater",
          "type": "cms_repeater",
          "props": {
            "layoutMode": "grid",
            "crossAxisCount": { "mobile": 2, "desktop": 4 },
            "itemsDataPath": "data.featuredProducts",
            "pagination": {
              "endpoint": "/v1/catalog/products",
              "pageParam": "page",
              "pageSize": 20
            },
            "itemTemplate": {
              "id": "prod_{{item.sku}}",
              "type": "product_card",
              "props": {
                "title": "{{item.name}}",
                "price": "{{item.price | currency:MXN}}",
                "imageUrl": "{{item.thumbnail}}"
              },
              "actions": {
                "onTap": {
                  "actionType": "navigation",
                  "target": "/product/{{item.sku}}"
                }
              }
            }
          }
        }
      ]
    }
  }
}
```

## **6.1. Diccionario de Datos y Especificación de Atributos (Schema Reference)**

### **A. Nivel Raíz: Objeto `CmsPage`**

Define el documento principal devuelto por el servicio o cargado localmente.

| Atributo | Tipo | Requerido | Default | Descripción |
| :---- | :---- | :---- | :---- | :---- |
| `schemaVersion` | `String` | Sí | `"1.0.0"` | Versión semántica del esquema para validación de *Forward Compatibility*. |
| `pageId` | `String` | Sí | \- | Identificador único de la página o sub-página (usado como llave primaria de caché y telemetría). |
| `cacheTtlSeconds` | `int?` | No | `null` | Tiempo de vida en caché en segundos. Si se integra con `fluent_networking_api`, alimenta el `CacheConfig`. |
| `refreshable` | `bool` | No | `false` | Habilita el gesto *Pull-to-Refresh* nativo en el `CustomScrollView` de la página. |
| `preserveStateOnRefresh` | `bool` | No | `true` | Si es `true`, conserva los valores ingresados por el usuario en el `PageScopedReactiveStore` durante un *Pull-to-Refresh*. |
| `dataContext` | `Map<String, dynamic>?` | No | `null` | Diccionario de datos pre-hidratados por el BFF. Accesible mediante el scope `{{data.*}}`. |
| `asyncSources` | `Map<String, AsyncSource>?` | No | `null` | Mapa de fuentes de datos diferidas que el cliente descargará bajo demanda. Accesible vía `{{async.<key>.*}}`. |
| `layout` | `ResponsiveLayoutConfig` | Sí | \- | Reglas de distribución y ordenamiento de las `ContentZones` según el *breakpoint* activo. |
| `zones` | `Map<String, ContentZone>` | Sí | \- | Diccionario de zonas semánticas que componen la página. |

### **B. Objeto `AsyncSource` (Dentro de `asyncSources`)**

Configura una petición asíncrona independiente ligada a uno o más módulos.

| Atributo | Tipo | Requerido | Default | Descripción |
| :---- | :---- | :---- | :---- | :---- |
| `endpoint` | `String` | Sí | \- | URL absoluta o ruta relativa que será consumida por `NetworkingApi` o el `AsyncDataFetcher`. |
| `method` | `String` | No | `"GET"` | Verbo HTTP (`"GET"`, `"POST"`). |
| `headers` | `Map<String, String>?` | No | `null` | Cabeceras HTTP adicionales para la consulta. |
| `ttlSeconds` | `int?` | No | `null` | Tiempo en segundos que la respuesta de esta fuente se mantiene en caché. |
| `fallback` | `Map<String, dynamic>?` | No | `null` | Datos por defecto inyectados en el scope `{{async.<key>}}` si la petición falla, evitando errores de interpolación. |

### **C. Objeto `ResponsiveLayoutConfig` (Dentro de `layout`)**

Define cómo el motor acomoda las `ContentZones` en Mobile, Tablet y Desktop sin duplicar tenants.

| Atributo | Tipo | Requerido | Default | Descripción |
| :---- | :---- | :---- | :---- | :---- |
| `mobile` | `BreakpointLayout` | Sí | \- | Configuración obligatoria para pantallas `< 600px` (y fallback por defecto si no se definen `tablet` o `desktop`). |
| `tablet` | `BreakpointLayout?` | No | `null` | Configuración opcional para pantallas entre `600px` y `1024px`. Si es `null`, hereda `mobile`. |
| `desktop` | `BreakpointLayout?` | No | `null` | Configuración opcional para pantallas `> 1024px`. Si es `null`, hereda `tablet` o `mobile`. |
| `type` *(en Breakpoint)* | `String` | Sí | `"single_column"` | Valores: `"single_column"` (flujo vertical de Slivers) o `"grid_12_cols"` (distribución multi-columna). |
| `zonesOrder` | `List<String>?` | Condicional | \- | Lista ordenada de llaves de `zones` a renderizar cuando `type == "single_column"`. |
| `columns` | `List<ColumnSpanConfig>?` | Condicional | \- | Lista de columnas (`span` de 1 a 12 y arreglo `zones`) cuando `type == "grid_12_cols"`. |

### **D. Objeto `ContentZone` (Dentro de `zones`)**

Contenedor lógico que agrupa módulos y define restricciones de espacio.

| Atributo | Tipo | Requerido | Default | Descripción |
| :---- | :---- | :---- | :---- | :---- |
| `pinned` | `bool` | No | `false` | Si es `true`, la zona se mantiene fija en la parte superior del scroll (`PinnedHeaderSliver`). |
| `stickyBottom` | `bool` | No | `false` | Si es `true`, la zona se ancla en la parte inferior de la pantalla fuera del scroll (ideal para barras de Checkout). |
| `visibleWhen` | `String?` | No | `null` | Expresión booleana reactiva. Si evalúa a `false`, toda la zona se oculta en `0ms`. |
| `padding` | `dynamic` | No | `null` | Token semántico (`"$spacingMd"`), número o mapa `{top, bottom, left, right}`. |
| `modules` | `List<ModuleNode>` | Sí | `[]` | Lista ordenada de módulos que se renderizarán dentro de esta zona. |

### **E. Objeto `ModuleNode` (Dentro de `zones[key].modules`)**

Unidad funcional atómica que se mapea al `CmsModuleRegistry`.

| Atributo | Tipo | Requerido | Default | Descripción |
| :---- | :---- | :---- | :---- | :---- |
| `id` | `String` | Sí | \- | Identificador único de instancia en la página (usado para `PageStorageKey`, `scrollToModule` y deduplicación de `onImpression`). |
| `type` | `String` | Sí | \- | Llave del módulo registrada en `CmsModuleRegistry` (ej. `"loyalty_banner"`, `"cms_repeater"`). |
| `platforms` | `List<String>?` | No | `null` | Filtro de plataformas permitidas: `["android", "ios", "web", "macos", "windows", "linux"]`. Si es `null`, se renderiza en todas. |
| `visibleWhen` | `String?` | No | `null` | Expresión condicional evaluada contra `data`, `client`, `state` o `env.features`. |
| `requiresData` | `List<String>?` | No | `null` | Lista de rutas (ej. `["async.wallet"]`) que deben resolverse antes de pintar el módulo. Activa el *Auto-Skeleton* mientras cargan. |
| `hideOnError` | `bool` | No | `true` | Si alguna fuente en `requiresData` falla y no tiene `fallback`, colapsa el módulo a `SizedBox.shrink()`. |
| `keepAlive` | `bool` | No | `false` | Envuelve el módulo en `AutomaticKeepAlive` para preservar su estado visual cuando sale del viewport de Slivers. |
| `a11y` | `A11yConfig?` | No | `null` | Configuración de accesibilidad (`label`, `hint`, `isButton`, `isHeader`, `excludeSemantics`). |
| `props` | `Map<String, dynamic>` | No | `{}` | Propiedades de negocio y estilo entregadas al módulo (soportan placeholders `{{...}}`, pipes y tokens `$token`). |
| `responsiveProps` | `Map<String, Map>?` | No | `null` | Sobrescrituras parciales de `props` por breakpoint (`mobile`, `tablet`, `desktop`). Se hace *shallow merge* sobre `props`. |
| `actions` | `Map<String, ActionNode>?` | No | `null` | Mapa de disparadores (`onTap`, `onLongPress`, `onChanged`, `onSubmit`, `onImpression`, `onAppear`). |

### **F. Objeto `ActionNode` (Dentro de `module.actions`)**

Define una intención declarativa ejecutada por el `CmsActionEngine`.

| Atributo | Tipo | Requerido | Default | Descripción |
| :---- | :---- | :---- | :---- | :---- |
| `actionType` | `String` | Sí | \- | Valores: `"navigation"`, `"external_url"`, `"state_mutation"`, `"modal_zone"`, `"scroll_to"`, `"analytics_only"`, `"custom_command"`. |
| `target` | `String?` | Condicional | `null` | Ruta de navegación, URL, llave del estado a mutar, ID del módulo para hacer scroll, o nombre del comando personalizado. |
| `concurrency` | `String` | No | `"dropIfBusy"` | Política de ejecución ante múltiples disparos: `"dropIfBusy"`, `"debounce"`, `"throttle"`, `"allowParallel"`. |
| `debounceMs` | `int` | No | `300` | Ventana de tiempo en milisegundos cuando `concurrency` es `"debounce"` o `"throttle"`. |
| `payload` | `Map<String, dynamic>?` | No | `null` | Argumentos enviados al manejador de la acción (acepta placeholders dinámicos como `"{{state.userEmail}}"`). |
| `optimisticState` | `OptimisticMutation?` | No | `null` | Objeto `{ "key": "...", "value": ..., "rollbackOnError": true }` que muta el `PageStore` inmediatamente antes de resolver la acción. |
| `analytics` | `Map<String, dynamic>?` | No | `null` | Metadatos emitidos automáticamente al `ActionObserver` global al dispararse la acción. |
| `onSuccess` | `ActionNode?` | No | `null` | Acción encadenada que se ejecuta si la acción principal concluye con éxito. |
| `onError` | `ActionNode?` | No | `null` | Acción encadenada que se ejecuta si la acción principal falla. |

### **G. Sintaxis de Expresiones, Scopes y Pipes**

* **Scopes válidos dentro de `{{...}}`:**  
  * `data.<path>`: Lee de `CmsPage.dataContext`.  
  * `client.<path>`: Lee del mapa local inyectado por el FE en `CmsPageView`.  
  * `state.<key>`: Lee y suscribe reactivamente el módulo a una llave del `PageScopedReactiveStore`.  
  * `async.<sourceId>.<path>`: Lee el resultado de una fuente definida en `asyncSources`.  
  * `env.features.<flagKey>`: Lee en vivo una bandera de `EnvironmentApi.isFeatureEnabled()`.  
  * `item.<path>` / `index`: Exclusivos dentro de la plantilla `itemTemplate` de un módulo `cms_repeater`.  
* **Pipes de Transformación nativos (`{{expresión | pipe:arg}}`):**  
  * `currency:<ISO>` (ej. `| currency:MXN`), `number`, `uppercase`, `lowercase`, `default:<fallbackValue>`, `translate` (conectado a `fluent_localization_api`).

# **7\. Plan de Implementación por Fases (Secuencia para Antigravity)**

## **Fase 1: `fluent_cms_api` — Modelos AST, Contratos y JSON Schema**

* Inicializar el paquete `packages/fluent_cms/fluent_cms_api` y registrarlo en el `pubspec.yaml` raíz del workspace.  
* Implementar modelos inmutables (`CmsPage`, `ContentZone`, `ModuleNode`, `ActionNode`, `ResponsiveLayoutConfig`, `A11yConfig`, `RepeaterConfig`).  
* Definir interfaces públicas: `CmsApi`, `SduiModule`, `CmsModuleContext` (con lectores seguros `getString`, `getInt`, `getBool`, `getColor`, `getList`), `HydrationEngine`, `CmsPageStore` y `PipeTransformer`.  
* Crear utilidad generadora de `cms_schema.json` y suite de tests unitarios al \>90%.

## **Fase 2: `fluent_cms` (Core) — Parser Híbrido, Module Registry, Store y Action Engine**

* Inicializar `packages/fluent_cms/fluent_cms` con su `CmsModule extends FluentModule` y `CmsConfig`.  
* Implementar `HybridCmsJsonParser` (Sync `< 50KB`, `Isolate.run` `>= 50KB`).  
* Implementar `CmsModuleRegistry` con validación de `ZoneConstraints` y `FallbackModuleWidget` (conectado a `LoggerApi` si está registrado).  
* Implementar `PageScopedReactiveStore` (`ValueNotifier` por llave para reconstrucción quirúrgica) y evaluador de expresiones booleanas `visibleWhen` (soportando `state.*`, `data.*`, `client.*` y `env.features.*`).  
* Implementar `CmsActionEngine` con políticas `dropIfBusy`, `debounce`, `throttle`, mutación optimista con rollback, `scroll_to` y delegación a `NavigationApi` / callback externo.

## **Fase 3: `fluent_cms` (Motor de Hidratación Opt-in & Tokens)**

* Implementar `NoOpHydrationEngine` (`const`, `@pragma('vm:prefer-inline')`) para modo estático con overhead cero.  
* Implementar `MixedHydrationEngine` con `SinglePassExpressionResolver` (`RegExp.replaceAllMapped` y Fast-Path `contains('{{')`).  
* Implementar `PipeTransformerRegistry` incluyendo pipes base (`currency`, `number`, `date`, `uppercase`, `lowercase`, `default`, `translate`).  
* Implementar gestor de `asyncSources` (usando `NetworkingApi` si está registrado en `Fluent` o un `AsyncDataFetcher` custom) y el wrapper `AutoSkeletonModuleWrapper`.  
* Implementar `ThemeTokenResolver` para tokens semánticos y mapas `{light, dark}`.

## **Fase 4: `fluent_cms` (Sliver Layout Engine, Repeater & Viewport Impressions)**

* Construir `CmsPageView` y `CmsPageController` con soporte para `Pull-to-Refresh` y `scrollToModule`.  
* Construir el motor de `ContentZones` sobre `CustomScrollView`:  
  * Renderizado Mobile en 1 columna de `Slivers` (incluyendo zonas `pinned`).  
  * Renderizado Web/Desktop multi-columna responsivo (`ResponsiveZoneLayout`).  
* Implementar `RepeaterModule` (`SliverList.builder` / `SliverGrid.builder` con paginación incremental).  
* Implementar `ModuleWrapperWidget` integrando: filtro de plataforma, `keepAlive`, `Semantics` (`a11y`), detector ligero de `onImpression` en viewport y resolución de `responsiveProps`.

## **Fase 5: Integración con `fluent_environment` & Example Omnicanal**

* Conectar `CmsModule` con `EnvironmentApi` (si está registrado): `registerResetService<CmsApi>()` y registro de `EnvironmentAction` para activar/desactivar bordes visuales de diagnóstico de `ContentZones` e inspección del `PageStore`.  
* Construir la app en `packages/fluent_cms/fluent_cms/example` mostrando:  
  1. Pantalla estática (Tier 1 \- Zero Hydration).  
  2. Pantalla e-commerce/membresía hidratada (Tier 3\) con `loyalty_banner`, `search_input_module` filtrando en vivo otra zona, y `cms_repeater` paginado.  
  3. Conmutación en vivo entre vista Mobile y Desktop y cambio de Feature Flags desde el `EnvironmentBanner`.

