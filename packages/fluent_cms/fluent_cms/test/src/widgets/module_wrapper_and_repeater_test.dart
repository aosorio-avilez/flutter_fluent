import 'package:fluent_cms/fluent_cms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/cms_mocks.dart';

class _InteractiveBannerModule extends SduiModule {
  const _InteractiveBannerModule();

  @override
  String get type => 'interactive_banner';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    final title = moduleContext.getString('title', defaultValue: 'Untitled');
    final count = moduleContext.getInt('count');
    final ratio = moduleContext.getDouble('ratio');
    final active = moduleContext.getBool('active');
    final tags = moduleContext.getList<String>('tags');
    final meta = moduleContext.getMap('meta');
    final bgColor = moduleContext.getColor(
      context,
      'bgColor',
      defaultValue: Colors.transparent,
    );
    final pad =
        moduleContext.getEdgeInsets('padding', context: context) ??
        EdgeInsets.zero;

    return ValueListenableBuilder<bool>(
      valueListenable: moduleContext.actionRunningListenable,
      builder: (context, running, _) {
        return GestureDetector(
          key: ValueKey<String>('tap_${moduleContext.moduleId}'),
          onTap: () => moduleContext.triggerAction(
            'onTap',
            extraPayload: const <String, dynamic>{'extra': 'yes'},
          ),
          child: Container(
            color: bgColor,
            padding: pad,
            height: 80,
            child: Text(
              '$title|$count|$ratio|$active|${tags.length}|${meta['k'] ?? ''}|'
              'running:${moduleContext.isActionRunning || running}',
            ),
          ),
        );
      },
    );
  }
}

class _ThrowingModule extends SduiModule {
  const _ThrowingModule();

  @override
  String get type => 'throwing_mod';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    throw StateError('Boom inside module build');
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
  });

  group('ModuleWrapperWidget & CmsModuleContextImpl', () {
    testWidgets(
      'handles platform filtering, reactive state, semantics, and impressions',
      (tester) async {
        final logger = MockLoggerApi();
        final registry = CmsModuleRegistry(
          logger: logger,
          initialModules: const <SduiModule>[
            _InteractiveBannerModule(),
            _ThrowingModule(),
            RepeaterModule(),
          ],
        );
        final hydration = MixedHydrationEngine();
        final controller = CmsPageController();
        controller.pageStore.setValue('query', 'Inicial');
        controller.pageStore.setValue('visibleFlag', true);

        final observedTriggers = <String>[];
        final actionEngine = CmsActionEngine(
          pageId: 'test_page',
          pageStore: controller.pageStore,
          hydrationEngine: hydration,
          observers: <CmsActionObserver>[
            (event) =>
                observedTriggers.add('${event.moduleId}:${event.trigger}'),
          ],
        );
        final tokenResolver = ThemeTokenResolver();

        const node = ModuleNode(
          id: 'banner_1',
          type: 'interactive_banner',
          platforms: <String>['ios', 'android'],
          visibleWhen: '{{state.visibleFlag}} == true',
          keepAlive: true,
          a11y: A11yConfig(
            label: 'Banner {{state.query}}',
            hint: 'Toca para abrir',
            isButton: true,
            isHeader: true,
          ),
          props: <String, dynamic>{
            'title': 'Busqueda: {{state.query}}',
            'count': 2,
            'ratio': 1.5,
            'active': true,
            'tags': <String>['a', 'b'],
            'meta': <String, dynamic>{'k': 'v'},
            'bgColor': r'$surfaceSecondary',
            'padding': r'$spacingSm',
          },
          responsiveProps: <String, Map<String, dynamic>>{
            'desktop': <String, dynamic>{'count': 99},
          },
          actions: <String, ActionNode>{
            'onAppear': ActionNode(actionType: 'analytics_only'),
            'onImpression': ActionNode(actionType: 'analytics_only'),
            'onTap': ActionNode(
              actionType: 'state_mutation',
              target: 'query',
              payload: <String, dynamic>{'value': 'Tocado'},
            ),
          },
        );

        const throwingNode = ModuleNode(
          id: 'bad_mod',
          type: 'throwing_mod',
          a11y: A11yConfig(excludeSemantics: true),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Unsupported platform -> collapses to SizedBox.shrink
                  ModuleWrapperWidget(
                    node: node,
                    zoneId: 'hero',
                    breakpoint: CmsBreakpoint.mobile,
                    moduleRegistry: registry,
                    hydrationEngine: hydration,
                    baseScope: HydrationScope.empty,
                    controller: controller,
                    actionEngine: actionEngine,
                    themeTokenResolver: tokenResolver,
                    platformOverride: 'windows',
                  ),
                  // Supported platform on desktop breakpoint
                  ModuleWrapperWidget(
                    node: node,
                    zoneId: 'hero',
                    breakpoint: CmsBreakpoint.desktop,
                    moduleRegistry: registry,
                    hydrationEngine: hydration,
                    baseScope: HydrationScope.empty,
                    controller: controller,
                    actionEngine: actionEngine,
                    themeTokenResolver: tokenResolver,
                    config: const CmsConfig(
                      defaultImpressionDuration: Duration(milliseconds: 50),
                    ),
                    platformOverride: 'ios',
                  ),
                  // Throwing module caught by error boundary
                  ModuleWrapperWidget(
                    node: throwingNode,
                    zoneId: 'hero',
                    breakpoint: CmsBreakpoint.desktop,
                    moduleRegistry: registry,
                    hydrationEngine: hydration,
                    baseScope: HydrationScope.empty,
                    controller: controller,
                    actionEngine: actionEngine,
                    themeTokenResolver: tokenResolver,
                    logger: logger,
                    platformOverride: 'ios',
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 80));

        expect(
          find.text('Busqueda: Inicial|99|1.5|true|2|v|running:false'),
          findsOneWidget,
        );
        expect(observedTriggers, contains('banner_1:onAppear'));
        expect(observedTriggers, contains('banner_1:onImpression'));
        expect(controller.hasFiredImpression('banner_1'), isTrue);
        verify(
          () => logger.logError(
            any<String>(),
            stackTrace: any<StackTrace>(named: 'stackTrace'),
          ),
        ).called(1);

        // Tap module to mutate state reactively
        await tester.tap(find.byKey(const ValueKey<String>('tap_banner_1')));
        await tester.pump();
        expect(
          find.text('Busqueda: Tocado|99|1.5|true|2|v|running:false'),
          findsOneWidget,
        );

        // Toggle visibleWhen -> collapses in 0ms
        controller.pageStore.setValue('visibleFlag', false);
        await tester.pump();
        expect(
          find.text('Busqueda: Tocado|99|1.5|true|2|v|running:false'),
          findsNothing,
        );

        actionEngine.dispose();
        controller.dispose();
      },
    );
  });

  group('RepeaterModule & CmsRepeaterWidget', () {
    testWidgets(
      'renders list and grid repeaters with item/index scope and pagination',
      (tester) async {
        const repModule = RepeaterModule();
        expect(repModule.type, 'cms_repeater');

        final registry = CmsModuleRegistry(
          initialModules: const <SduiModule>[
            _InteractiveBannerModule(),
            RepeaterModule(),
          ],
        );
        final hydration = MixedHydrationEngine();
        final controller = CmsPageController();
        final actionEngine = CmsActionEngine(
          pageId: 'catalog_page',
          pageStore: controller.pageStore,
          hydrationEngine: hydration,
        );
        final tokenResolver = ThemeTokenResolver();

        var pageRequested = 0;
        final asyncDataSource = NetworkingAsyncDataSource(
          customFetcher:
              (source, {forceRefresh = false, queryParameters}) async {
                pageRequested = (queryParameters?['page'] as int?) ?? 0;
                return const <String, dynamic>{
                  'items': <Map<String, dynamic>>[
                    <String, dynamic>{'sku': 'SKU-3', 'name': 'Monitor'},
                  ],
                };
              },
        );

        final repeaterNode = ModuleNode.fromJson(const <String, dynamic>{
          'id': 'catalog_rep',
          'type': 'cms_repeater',
          'props': <String, dynamic>{
            'layoutMode': 'grid',
            'crossAxisCount': <String, dynamic>{'mobile': 2, 'desktop': 4},
            'itemsDataPath': 'data.products',
            'pagination': <String, dynamic>{
              'endpoint': '/v1/products',
              'pageParam': 'page',
              'pageSize': 2,
            },
            'itemTemplate': <String, dynamic>{
              'id': 'prod_{{item.sku}}',
              'type': 'interactive_banner',
              'props': <String, dynamic>{
                'title': '{{item.name}} #{{index}}',
              },
            },
          },
        });

        const baseScope = HydrationScope(
          dataContext: <String, dynamic>{
            'products': <Map<String, dynamic>>[
              <String, dynamic>{'sku': 'SKU-1', 'name': 'Teclado'},
              <String, dynamic>{'sku': 'SKU-2', 'name': 'Mouse'},
            ],
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                controller: controller.scrollController,
                slivers: [
                  CmsRepeaterWidget(
                    node: repeaterNode,
                    zoneId: 'main_feed',
                    breakpoint: CmsBreakpoint.mobile,
                    moduleRegistry: registry,
                    hydrationEngine: hydration,
                    baseScope: baseScope,
                    controller: controller,
                    actionEngine: actionEngine,
                    themeTokenResolver: tokenResolver,
                    asyncDataSource: asyncDataSource,
                    asSliver: true,
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(pageRequested, 2);
        expect(
          find.textContaining('Teclado #0'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Mouse #1'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Monitor #2'),
          findsOneWidget,
        );

        // Also test box mode (asSliver: false) in list layout
        final boxRepeaterNode = ModuleNode.fromJson(const <String, dynamic>{
          'id': 'box_rep',
          'type': 'cms_repeater',
          'props': <String, dynamic>{
            'layoutMode': 'list',
            'itemsDataPath': 'state.dynamicList',
            'itemTemplate': <String, dynamic>{
              'id': 'row_{{item.sku}}',
              'type': 'interactive_banner',
              'props': <String, dynamic>{
                'title': 'Row {{item.name}}',
              },
            },
          },
        });
        controller.pageStore.setValue(
          'dynamicList',
          const <Map<String, dynamic>>[
            <String, dynamic>{'sku': 'A1', 'name': 'Audifonos'},
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CmsRepeaterWidget(
                  node: boxRepeaterNode,
                  zoneId: 'sidebar',
                  breakpoint: CmsBreakpoint.desktop,
                  moduleRegistry: registry,
                  hydrationEngine: hydration,
                  baseScope: baseScope,
                  controller: controller,
                  actionEngine: actionEngine,
                  themeTokenResolver: tokenResolver,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Row Audifonos'), findsOneWidget);

        actionEngine.dispose();
        controller.dispose();
      },
    );
  });
}
