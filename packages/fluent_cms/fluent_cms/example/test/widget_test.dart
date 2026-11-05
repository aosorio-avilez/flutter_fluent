import 'package:fluent_cms/fluent_cms.dart';
import 'package:fluent_cms_example/main.dart';
import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CmsExampleApp boots up and renders full SDUI showcase', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await Fluent.build([
      EnvironmentModule(
        environment: DevEnvironment(),
        availableEnvironments: [DevEnvironment(), StagingEnvironment()],
      ),
      CmsModule(
        config: CmsConfig(
          hydrate: true,
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
          initialCommandHandlers: {
            'add_to_cart': (target, payload) async => true,
          },
        ),
      ),
    ]);

    await tester.pumpWidget(const CmsExampleApp());
    await tester.pumpAndSettle();

    // 1. Initial Tier 3 assertions
    expect(find.text('Fluent CMS Showcase'), findsOneWidget);
    expect(find.textContaining('Hola, Alfonso'), findsOneWidget);
    expect(find.textContaining('MacBook Pro M3'), findsOneWidget);
    expect(find.textContaining('🔥 -15% OFF'), findsOneWidget);
    expect(find.textContaining('Filtro: TODOS'), findsOneWidget);

    // 2. Test reactive search input with pipe transformation
    await tester.enterText(find.byType(TextField), 'laptop');
    await tester.pumpAndSettle();
    expect(find.textContaining('Filtro: LAPTOP'), findsOneWidget);

    // 3. Test action: add to cart (custom_command with optimisticState)
    final addButtons = find.widgetWithText(ElevatedButton, 'Agregar');
    expect(addButtons, findsWidgets);
    await tester.tap(addButtons.first);
    await tester.pumpAndSettle();

    // Sticky bar appears because cartCount > 0
    expect(find.textContaining('Listo para comprar (1)'), findsOneWidget);

    // 4. Test modal_zone bottom sheet trigger
    await tester.tap(find.text('Ver Carrito'));
    await tester.pumpAndSettle();

    expect(find.text('🛒 Resumen de tu Carrito'), findsOneWidget);
    expect(
      find.textContaining('Total de productos agregados: 1'),
      findsOneWidget,
    );

    // 5. Test state_mutation action inside modal
    await tester.tap(find.text('Vaciar Carrito'));
    await tester.pumpAndSettle();

    // Modal closed and cartCount reset
    expect(find.text('🛒 Resumen de tu Carrito'), findsNothing);
    expect(find.textContaining('Items: 0'), findsOneWidget);

    // 6. Test scroll_to action
    await tester.tap(find.text('Ver Oferta Flash'));
    await tester.pumpAndSettle();
    expect(find.textContaining('🎉 ¡Oferta Flash Exclusiva!'), findsOneWidget);

    // 7. Test Breakpoint Cycling (Mobile -> Tablet -> Desktop -> Mobile)
    expect(find.byIcon(Icons.phone_android), findsOneWidget);
    await tester.tap(find.byIcon(Icons.phone_android));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.tablet_mac), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tablet_mac));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.desktop_windows), findsOneWidget);

    await tester.tap(find.byIcon(Icons.desktop_windows));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.phone_android), findsOneWidget);

    // 8. Test Theme Toggle (Dark -> Light -> Dark)
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    // 9. Test JSON Schema Dialog
    await tester.tap(find.byIcon(Icons.schema_outlined));
    await tester.pumpAndSettle();
    expect(find.text('JSON Schema Draft 2020-12'), findsOneWidget);
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();

    // 10. Switch to Tier 1 (Static O(1))
    await tester.tap(find.text('Tier 1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Página Estática (Tier 1)'), findsOneWidget);
    expect(find.textContaining('NoOpHydrationEngine'), findsOneWidget);

    await Fluent.reset();
  });
}
