import 'package:fluent_cms/fluent_cms.dart';
import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';

class DevEnvironment extends Environment {
  @override
  String get name => 'Development';

  @override
  Color get color => Colors.blue;

  @override
  EnvironmentType get type => EnvironmentType.dev;

  @override
  Map<String, String> get values => const <String, String>{
    'apiUrl': 'https://api.fluent.dev',
  };

  @override
  Map<String, bool> get features => const <String, bool>{
    'loyalty_v2': true,
    'show_hero': true,
  };
}

class StagingEnvironment extends Environment {
  @override
  String get name => 'Staging';

  @override
  Color get color => Colors.orange;

  @override
  EnvironmentType get type => EnvironmentType.stg;

  @override
  Map<String, String> get values => const <String, String>{
    'apiUrl': 'https://staging.fluent.dev',
  };

  @override
  Map<String, bool> get features => const <String, bool>{
    'loyalty_v2': false,
    'show_hero': true,
  };
}

class LoyaltyBannerModule extends SduiModule {
  const LoyaltyBannerModule();

  @override
  String get type => 'loyalty_banner';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    final greeting = moduleContext.getString(
      'greeting',
      defaultValue: 'Bienvenido',
    );
    final savings = moduleContext.getString(
      'savingsText',
      defaultValue: 'Ahorro: \$0.00',
    );
    final wallet = moduleContext.getString(
      'walletText',
      defaultValue: 'Cashback: \$0.00',
    );
    final cardColor = moduleContext.getColor(
      context,
      'cardColor',
      defaultValue: const Color(0xFF1E222A),
    );

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              savings,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              wallet,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.lightGreenAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget? buildSkeleton(BuildContext context, ModuleNode node) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}

class SearchInputModule extends SduiModule {
  const SearchInputModule();

  @override
  String get type => 'search_input_module';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    final placeholder = moduleContext.getString(
      'placeholder',
      defaultValue: 'Buscar...',
    );
    final bindTo = moduleContext.getString('bindTo', defaultValue: 'query');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: placeholder,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) {
          moduleContext.pageStore.setValue(bindTo, val);
          moduleContext.triggerAction(
            'onChanged',
            extraPayload: {'query': val},
          );
        },
      ),
    );
  }
}

class ProductCardModule extends SduiModule {
  const ProductCardModule();

  @override
  String get type => 'product_card';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    final title = moduleContext.getString('title', defaultValue: 'Producto');
    final price = moduleContext.getString('price', defaultValue: '\$0.00');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 36, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Fluent.build([
    EnvironmentModule(
      environment: DevEnvironment(),
      availableEnvironments: [DevEnvironment(), StagingEnvironment()],
    ),
    const CmsModule(
      config: CmsConfig(
        hydrate: true,
        enableDebugOverlay: true,
        initialModules: [
          LoyaltyBannerModule(),
          SearchInputModule(),
          ProductCardModule(),
          RepeaterModule(),
        ],
      ),
    ),
  ]);

  runApp(const CmsExampleApp());
}

class CmsExampleApp extends StatefulWidget {
  const CmsExampleApp({super.key});

  @override
  State<CmsExampleApp> createState() => _CmsExampleAppState();
}

class _CmsExampleAppState extends State<CmsExampleApp> {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  int _selectedTierIndex = 1;
  CmsBreakpoint _selectedBreakpoint = CmsBreakpoint.mobile;

  final CmsPage _staticTier1Page = CmsPage.fromJson(const {
    'schemaVersion': '1.0.0',
    'pageId': 'static_page',
    'layout': {
      'mobile': {
        'type': 'single_column',
        'zonesOrder': ['banner_zone', 'body_zone'],
      },
    },
    'zones': {
      'banner_zone': {
        'modules': [
          {
            'id': 'hero_static',
            'type': 'loyalty_banner',
            'props': {
              'greeting': 'Página Estática (Tier 1)',
              'savingsText': 'Zero-Hydration activado (O(1) pass-through)',
              'walletText': 'Sin overhead de isolates ni expresiones',
              'cardColor': '#2D3748',
            },
          },
        ],
      },
      'body_zone': {
        'modules': [
          {
            'id': 'card_1',
            'type': 'product_card',
            'props': {
              'title': 'Rendimiento Nativo 120 FPS',
              'price': '0 ms overhead',
            },
          },
          {
            'id': 'card_2',
            'type': 'product_card',
            'props': {
              'title': 'NoOpHydrationEngine',
              'price': 'Zero heap allocations',
            },
          },
        ],
      },
    },
  });

  final CmsPage _hydratedTier3Page = CmsPage.fromJson(const {
    'schemaVersion': '1.0.0',
    'pageId': 'ecommerce_hydrated',
    'refreshable': true,
    'preserveStateOnRefresh': true,
    'dataContext': {
      'user': {'firstName': 'Alfonso'},
      'membership': {'savings': 1250.50},
      'products': [
        {'sku': 'P1', 'name': 'MacBook Pro M3', 'price': 38999.0},
        {'sku': 'P2', 'name': 'Teclado Mecánico RGB', 'price': 2499.0},
        {'sku': 'P3', 'name': 'Mouse Ergonómico', 'price': 1299.0},
        {'sku': 'P4', 'name': 'Monitor 4K 144Hz', 'price': 8999.0},
      ],
    },
    'asyncSources': {
      'wallet': {
        'endpoint': '/v1/wallet/summary',
        'ttlSeconds': 120,
        'fallback': {'balance': 450.0},
      },
    },
    'layout': {
      'mobile': {
        'type': 'single_column',
        'zonesOrder': ['search_zone', 'hero_zone', 'catalog_zone'],
      },
      'desktop': {
        'type': 'grid_12_cols',
        'columns': [
          {
            'span': 12,
            'zones': ['search_zone'],
          },
          {
            'span': 4,
            'zones': ['hero_zone'],
          },
          {
            'span': 8,
            'zones': ['catalog_zone'],
          },
        ],
      },
    },
    'zones': {
      'search_zone': {
        'pinned': true,
        'modules': [
          {
            'id': 'search_bar',
            'type': 'search_input_module',
            'props': {
              'placeholder': 'Buscar en catálogo SDUI...',
              'bindTo': 'filterQuery',
            },
          },
        ],
      },
      'hero_zone': {
        'visibleWhen': '{{env.features.loyalty_v2}} == true',
        'requiresData': ['async.wallet'],
        'modules': [
          {
            'id': 'loyalty_hero',
            'type': 'loyalty_banner',
            'props': {
              'greeting': 'Hola, {{data.user.firstName}}',
              'savingsText':
                  'Ahorro acumulado: {{data.membership.savings | currency:MXN}}',
              'walletText':
                  'Cashback disponible: {{async.wallet.balance | currency:MXN}}',
              'cardColor': {'light': '#1A365D', 'dark': '#1A202C'},
            },
          },
        ],
      },
      'catalog_zone': {
        'modules': [
          {
            'id': 'products_repeater',
            'type': 'cms_repeater',
            'props': {
              'layoutMode': 'grid',
              'crossAxisCount': {'mobile': 2, 'desktop': 3},
              'itemsDataPath': 'data.products',
              'itemTemplate': {
                'id': 'item_{{item.sku}}',
                'type': 'product_card',
                'props': {
                  'title': '{{item.name}}',
                  'price': '{{item.price | currency:MXN}}',
                },
              },
            },
          },
        ],
      },
    },
  });

  @override
  Widget build(BuildContext context) {
    final activePage = _selectedTierIndex == 0
        ? _staticTier1Page
        : _hydratedTier3Page;

    return MaterialApp(
      title: 'Fluent CMS Omnichannel Demo',
      theme: ThemeData.dark(useMaterial3: true),
      navigatorKey: navigatorKey,
      builder: (context, child) => EnvironmentBanner(
        enableInspector: true,
        navigatorKey: navigatorKey,
        child: child!,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fluent CMS Showcase'),
          actions: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Tier 1')),
                ButtonSegment(value: 1, label: Text('Tier 3')),
              ],
              selected: {_selectedTierIndex},
              onSelectionChanged: (val) {
                setState(() => _selectedTierIndex = val.first);
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _selectedBreakpoint == CmsBreakpoint.mobile
                    ? Icons.phone_android
                    : Icons.desktop_windows,
              ),
              tooltip: 'Cambiar Breakpoint',
              onPressed: () {
                setState(() {
                  _selectedBreakpoint =
                      _selectedBreakpoint == CmsBreakpoint.mobile
                      ? CmsBreakpoint.desktop
                      : CmsBreakpoint.mobile;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Environment Inspector',
              onPressed: () {
                Fluent.get<EnvironmentApi>().showInspector(
                  context,
                  navigatorKey: navigatorKey,
                );
              },
            ),
          ],
        ),
        body: CmsPageView(
          page: activePage,
          hydrate: _selectedTierIndex == 1,
          breakpointOverride: _selectedBreakpoint,
        ),
      ),
    );
  }
}
