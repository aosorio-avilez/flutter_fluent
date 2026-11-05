import 'dart:async';
import 'dart:convert';

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

/// Custom pipe that transforms a discount number into a badge string.
class DiscountBadgePipe extends PipeTransformer {
  @override
  String get name => 'discount_badge';

  @override
  Object? transform(Object? value, {String? argument, BuildContext? context}) {
    if (value is num && value > 0) {
      return '🔥 -${value.toInt()}% OFF';
    }
    return '';
  }
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
                Expanded(
                  child: Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    wallet,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.lightGreenAccent,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      moduleContext.triggerAction('onScrollToPromo'),
                  icon: const Icon(
                    Icons.arrow_downward,
                    size: 16,
                    color: Colors.amber,
                  ),
                  label: const Text(
                    'Ver Oferta Flash',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Cargando cashback en vivo...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
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
          fillColor: Theme.of(context).cardColor,
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

class SearchStatusBannerModule extends SduiModule {
  const SearchStatusBannerModule();

  @override
  String get type => 'search_status_banner';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    final query = moduleContext.getString(
      'queryText',
      defaultValue: 'Catálogo General',
    );
    final cartCount = moduleContext.getString(
      'cartText',
      defaultValue: 'Carrito vacío',
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 20, color: Colors.lightBlueAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              query,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              cartCount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
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
    final badge = moduleContext.getString('badge');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.shopping_bag,
                      size: 28,
                      color: Colors.blueAccent,
                    ),
                    if (badge.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => moduleContext.triggerAction('onAddToCart'),
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: const Text('Agregar', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StickyCheckoutBarModule extends SduiModule {
  const StickyCheckoutBarModule();

  @override
  String get type => 'sticky_checkout_bar';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    final title = moduleContext.getString(
      'title',
      defaultValue: 'Carrito listo',
    );
    final count = moduleContext.getString('count', defaultValue: '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_cart_checkout,
                color: Colors.lightGreenAccent,
              ),
              const SizedBox(width: 8),
              Text(
                '$title ($count)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => moduleContext.triggerAction('onOpenModal'),
            child: const Text('Ver Carrito'),
          ),
        ],
      ),
    );
  }
}

class CartModalModule extends SduiModule {
  const CartModalModule();

  @override
  String get type => 'cart_modal';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    final header = moduleContext.getString(
      'header',
      defaultValue: 'Resumen de Carrito',
    );
    final countText = moduleContext.getString(
      'countText',
      defaultValue: 'Productos: 0',
    );

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            header,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(countText, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    moduleContext.triggerAction('onClearCart');
                    Navigator.of(context).pop();
                  },
                  child: const Text('Vaciar Carrito'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PromoFooterModule extends SduiModule {
  const PromoFooterModule();

  @override
  String get type => 'promo_footer';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    final title = moduleContext.getString(
      'title',
      defaultValue: 'Oferta Flash',
    );
    final subtitle = moduleContext.getString(
      'subtitle',
      defaultValue: 'Descuento extra',
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade900, Colors.deepPurple.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
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
    CmsModule(
      config: CmsConfig(
        hydrate: true,
        enableDebugOverlay: true,
        initialPipes: [DiscountBadgePipe()],
        initialModules: const [
          LoyaltyBannerModule(),
          SearchInputModule(),
          SearchStatusBannerModule(),
          ProductCardModule(),
          StickyCheckoutBarModule(),
          CartModalModule(),
          PromoFooterModule(),
          RepeaterModule(),
        ],
        asyncDataFetcher:
            (source, {forceRefresh = false, queryParameters}) async {
              // Simulate network latency to display skeleton loaders
              await Future<void>.delayed(const Duration(milliseconds: 400));
              if (source.endpoint == '/v1/wallet/summary') {
                return {'balance': 750.50, 'savings': 1250.50};
              }
              return const <String, dynamic>{};
            },
        initialCommandHandlers: {
          'add_to_cart': (target, payload) async {
            // Simulated command processing
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return true;
          },
        },
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
  ThemeMode _themeMode = ThemeMode.dark;
  String _lastTelemetry = 'Iniciando SDUI...';

  @override
  void initState() {
    super.initState();
    try {
      final cms = Fluent.get<CmsApi>();
      if (cms is CmsApiImpl) {
        cms.addActionObserver((event) {
          if (mounted) {
            setState(() {
              _lastTelemetry =
                  '[Action] ${event.trigger}: ${event.action.actionType} (${event.moduleId})';
            });
          }
        });
      }
    } on Object {
      // Ignored in headless tests
    }
  }

  void _cycleBreakpoint() {
    setState(() {
      if (_selectedBreakpoint == CmsBreakpoint.mobile) {
        _selectedBreakpoint = CmsBreakpoint.tablet;
      } else if (_selectedBreakpoint == CmsBreakpoint.tablet) {
        _selectedBreakpoint = CmsBreakpoint.desktop;
      } else {
        _selectedBreakpoint = CmsBreakpoint.mobile;
      }
    });
  }

  void _showSchemaDialog() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final schema = CmsJsonSchemaGenerator.generate(
      modules: Fluent.get<CmsApi>().registeredModules,
    );
    final jsonText = const JsonEncoder.withIndent('  ').convert(schema);

    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('JSON Schema Draft 2020-12'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonText,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

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
      'meta': {'timestamp': '2026-11-05T12:00:00Z'},
      'products': [
        {
          'sku': 'P1',
          'name': 'MacBook Pro M3',
          'price': 38999.0,
          'discount': 15,
        },
        {
          'sku': 'P2',
          'name': 'Teclado Mecánico RGB',
          'price': 2499.0,
          'discount': 20,
        },
        {
          'sku': 'P3',
          'name': 'Mouse Ergonómico',
          'price': 1299.0,
          'discount': 10,
        },
        {
          'sku': 'P4',
          'name': 'Monitor 4K 144Hz',
          'price': 8999.0,
          'discount': 25,
        },
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
        'zonesOrder': [
          'search_zone',
          'status_zone',
          'hero_zone',
          'catalog_zone',
          'footer_zone',
        ],
      },
      'tablet': {
        'type': 'grid_12_cols',
        'columns': [
          {
            'span': 12,
            'zones': ['search_zone', 'status_zone'],
          },
          {
            'span': 6,
            'zones': ['hero_zone'],
          },
          {
            'span': 6,
            'zones': ['catalog_zone'],
          },
          {
            'span': 12,
            'zones': ['footer_zone'],
          },
        ],
      },
      'desktop': {
        'type': 'grid_12_cols',
        'columns': [
          {
            'span': 12,
            'zones': ['search_zone', 'status_zone'],
          },
          {
            'span': 4,
            'zones': ['hero_zone'],
          },
          {
            'span': 8,
            'zones': ['catalog_zone'],
          },
          {
            'span': 12,
            'zones': ['footer_zone'],
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
      'status_zone': {
        'modules': [
          {
            'id': 'search_status',
            'type': 'search_status_banner',
            'props': {
              'queryText':
                  'Filtro: {{state.filterQuery | uppercase | default:TODOS}}',
              'cartText': 'Items: {{state.cartCount | default:0}}',
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
            'actions': {
              'onScrollToPromo': {
                'actionType': 'scroll_to',
                'target': 'promo_footer',
              },
              'onImpression': {
                'actionType': 'analytics_only',
                'target': 'loyalty_hero_viewed',
              },
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
              'crossAxisCount': {'mobile': 2, 'tablet': 2, 'desktop': 3},
              'itemsDataPath': 'data.products',
              'itemTemplate': {
                'id': 'item_{{item.sku}}',
                'type': 'product_card',
                'props': {
                  'title': '{{item.name}}',
                  'price': '{{item.price | currency:MXN}}',
                  'badge': '{{item.discount | discount_badge}}',
                },
                'actions': {
                  'onAddToCart': {
                    'actionType': 'custom_command',
                    'target': 'add_to_cart',
                    'payload': {'sku': '{{item.sku}}'},
                    'optimisticState': {
                      'key': 'cartCount',
                      'value': 1,
                      'rollbackOnError': true,
                    },
                    'onSuccess': {
                      'actionType': 'analytics_only',
                      'target': 'item_added',
                    },
                  },
                },
              },
            },
          },
        ],
      },
      'footer_zone': {
        'modules': [
          {
            'id': 'promo_footer',
            'type': 'promo_footer',
            'props': {
              'title': '🎉 ¡Oferta Flash Exclusiva!',
              'subtitle':
                  'Usa el cupón FLUENTCMS para 20% adicional en tu compra.',
            },
          },
        ],
      },
      'sticky_checkout_zone': {
        'stickyBottom': true,
        'visibleWhen': '{{state.cartCount}} > 0',
        'modules': [
          {
            'id': 'checkout_bar',
            'type': 'sticky_checkout_bar',
            'props': {
              'title': 'Listo para comprar',
              'count': '{{state.cartCount}}',
            },
            'actions': {
              'onOpenModal': {
                'actionType': 'modal_zone',
                'target': 'cart_modal_zone',
              },
            },
          },
        ],
      },
      'cart_modal_zone': {
        'modules': [
          {
            'id': 'cart_modal',
            'type': 'cart_modal',
            'props': {
              'header': '🛒 Resumen de tu Carrito',
              'countText':
                  'Total de productos agregados: {{state.cartCount | default:0}}',
            },
            'actions': {
              'onClearCart': {
                'actionType': 'state_mutation',
                'target': 'cartCount',
                'payload': {'value': 0},
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
      themeMode: _themeMode,
      theme: ThemeData.light(
        useMaterial3: true,
      ).copyWith(splashFactory: InkRipple.splashFactory),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(splashFactory: InkRipple.splashFactory),
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
            IconButton(
              icon: Icon(
                _selectedBreakpoint == CmsBreakpoint.mobile
                    ? Icons.phone_android
                    : _selectedBreakpoint == CmsBreakpoint.tablet
                    ? Icons.tablet_mac
                    : Icons.desktop_windows,
              ),
              tooltip:
                  'Breakpoint: ${_selectedBreakpoint.name.toUpperCase()} (Click para cambiar)',
              onPressed: _cycleBreakpoint,
            ),
            IconButton(
              icon: Icon(
                _themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              tooltip: 'Alternar Tema Claro/Oscuro',
              onPressed: () {
                setState(() {
                  _themeMode = _themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.schema_outlined),
              tooltip: 'Ver JSON Schema Draft 2020-12',
              onPressed: _showSchemaDialog,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Environment Inspector',
              onPressed: () {
                final ctx = navigatorKey.currentContext ?? context;
                Fluent.get<EnvironmentApi>().showInspector(
                  ctx,
                  navigatorKey: navigatorKey,
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                size: 16,
                color: Colors.amber,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Telemetría SDUI: $_lastTelemetry',
                  style: const TextStyle(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
