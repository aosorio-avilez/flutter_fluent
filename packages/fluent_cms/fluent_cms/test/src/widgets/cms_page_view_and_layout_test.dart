import 'dart:convert';

import 'package:fluent_cms/fluent_cms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SimpleCardModule extends SduiModule {
  const _SimpleCardModule();

  @override
  String get type => 'simple_card';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    final label = moduleContext.getString('label');
    return InkWell(
      key: ValueKey<String>('card_${moduleContext.moduleId}'),
      onTap: () => moduleContext.triggerAction('onTap'),
      child: SizedBox(
        height: 120,
        child: Center(child: Text(label)),
      ),
    );
  }
}

void main() {
  group('CmsPageView, CmsPageController & ResponsiveZoneLayout', () {
    final samplePage = CmsPage.fromJson(const <String, dynamic>{
      'schemaVersion': '1.0.0',
      'pageId': 'omnicanal_home',
      'refreshable': true,
      'preserveStateOnRefresh': true,
      'dataContext': <String, dynamic>{
        'user': <String, dynamic>{'name': 'Alfonso'},
      },
      'layout': <String, dynamic>{
        'mobile': <String, dynamic>{
          'type': 'single_column',
          'zonesOrder': <String>[
            'sticky_header',
            'hero_zone',
            'feed_zone',
            'checkout_sticky',
          ],
        },
        'desktop': <String, dynamic>{
          'type': 'grid_12_cols',
          'columns': <Map<String, dynamic>>[
            <String, dynamic>{
              'span': 12,
              'zones': <String>['sticky_header'],
            },
            <String, dynamic>{
              'span': 8,
              'zones': <String>['hero_zone'],
            },
            <String, dynamic>{
              'span': 4,
              'zones': <String>['feed_zone'],
            },
          ],
        },
      },
      'zones': <String, dynamic>{
        'sticky_header': <String, dynamic>{
          'pinned': true,
          'padding': r'$spacingSm',
          'modules': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'header_mod',
              'type': 'simple_card',
              'props': <String, dynamic>{
                'label': 'Hola {{data.user.name}}',
              },
              'actions': <String, dynamic>{
                'onTap': <String, dynamic>{
                  'actionType': 'scroll_to',
                  'target': 'footer_target',
                },
              },
            },
          ],
        },
        'hero_zone': <String, dynamic>{
          'visibleWhen': '{{env.features.show_hero}} == true',
          'modules': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'hero_mod',
              'type': 'simple_card',
              'props': <String, dynamic>{
                'label': 'Hero Principal',
              },
              'actions': <String, dynamic>{
                'onTap': <String, dynamic>{
                  'actionType': 'modal_zone',
                  'target': 'modal_promo',
                },
              },
            },
          ],
        },
        'feed_zone': <String, dynamic>{
          'modules': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'spacer_1',
              'type': 'simple_card',
              'props': <String, dynamic>{'label': 'Bloque 1'},
            },
            <String, dynamic>{
              'id': 'footer_target',
              'type': 'simple_card',
              'props': <String, dynamic>{'label': 'Destino Scroll'},
            },
          ],
        },
        'checkout_sticky': <String, dynamic>{
          'stickyBottom': true,
          'modules': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'checkout_bar',
              'type': 'simple_card',
              'props': <String, dynamic>{'label': 'Pagar Ahora'},
            },
          ],
        },
        'modal_promo': <String, dynamic>{
          'modules': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'promo_sheet_mod',
              'type': 'simple_card',
              'props': <String, dynamic>{'label': 'Detalle en Modal'},
            },
          ],
        },
      },
    });

    testWidgets(
      'renders Mobile and Desktop layouts, stickyBottom, scrollTo, and modals',
      (tester) async {
        final cmsApi = CmsApiImpl(
          config: const CmsConfig(
            hydrate: true,
            enableDebugOverlay: true,
            initialModules: <SduiModule>[
              _SimpleCardModule(),
              RepeaterModule(),
            ],
          ),
        );
        final controller = CmsPageController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CmsPageView(
                page: samplePage,
                cmsApi: cmsApi,
                controller: controller,
                breakpointOverride: CmsBreakpoint.mobile,
                featureFlagLookup: (flag) => flag == 'show_hero',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hola Alfonso'), findsOneWidget);
        expect(find.text('Hero Principal'), findsOneWidget);
        expect(find.text('Pagar Ahora'), findsOneWidget);
        expect(find.text('zone:sticky_header'), findsOneWidget);

        // Programmatic scrollToModule
        final scrollFuture = controller.scrollToModule('footer_target');
        await tester.pumpAndSettle();
        expect(await scrollFuture, isTrue);

        // Tap header_mod to trigger declarative scroll_to
        await tester.tap(find.byKey(const ValueKey<String>('card_header_mod')));
        await tester.pumpAndSettle();

        // Tap hero_mod to open modal_zone bottom sheet
        await tester.tap(find.byKey(const ValueKey<String>('card_hero_mod')));
        await tester.pumpAndSettle();
        expect(find.text('Detalle en Modal'), findsOneWidget);

        // Dismiss modal bottom sheet
        Navigator.of(tester.element(find.text('Detalle en Modal'))).pop();
        await tester.pumpAndSettle();

        // Switch to Desktop grid_12_cols breakpoint
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CmsPageView(
                page: samplePage,
                cmsApi: cmsApi,
                controller: controller,
                breakpointOverride: CmsBreakpoint.desktop,
                featureFlagLookup: (flag) => flag == 'show_hero',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hola Alfonso'), findsOneWidget);
        expect(find.text('Hero Principal'), findsOneWidget);
        expect(find.text('Destino Scroll'), findsOneWidget);

        controller.dispose();
      },
    );

    testWidgets(
      'fetches remote pageEndpoint, preserves state on refresh, and errors',
      (tester) async {
        var fetchCalls = 0;
        final cmsApi = CmsApiImpl(
          config: CmsConfig(
            hydrate: true,
            initialModules: const <SduiModule>[_SimpleCardModule()],
            pageJsonFetcher: (endpoint, {forceRefresh = false}) async {
              fetchCalls++;
              if (endpoint == '/v1/broken') {
                throw StateError('404 Page Not Found');
              }
              return jsonEncode(samplePage.toJson());
            },
          ),
        );

        final controller = CmsPageController();
        controller.pageStore.setValue('userTyped', 'Mi Filtro');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CmsPageView(
                pageEndpoint: '/v1/home',
                cmsApi: cmsApi,
                controller: controller,
                refreshOnAppResume: true,
                featureFlagLookup: (_) => true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(fetchCalls, 1);
        expect(find.text('Hola Alfonso'), findsOneWidget);

        // Trigger programmatic refresh and verify preserveStateOnRefresh
        await controller.refresh();
        await tester.pumpAndSettle();
        expect(fetchCalls, 2);
        expect(controller.pageStore.getValue<String>('userTyped'), 'Mi Filtro');

        // Simulate AppLifecycleState.resumed
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        expect(fetchCalls, 3);

        // Error builder when pageEndpoint fails
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CmsPageView(
                pageEndpoint: '/v1/broken',
                cmsApi: cmsApi,
                errorBuilder: (context, error) => Text('Error: $error'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('404 Page Not Found'), findsOneWidget);

        controller.dispose();
      },
    );
  });
}
