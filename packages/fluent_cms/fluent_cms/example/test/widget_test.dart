import 'package:fluent_cms/fluent_cms.dart';
import 'package:fluent_cms_example/main.dart';
import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CmsExampleApp boots up and renders SDUI showcase', (
    tester,
  ) async {
    await Fluent.build([
      EnvironmentModule(
        environment: DevEnvironment(),
        availableEnvironments: [DevEnvironment(), StagingEnvironment()],
      ),
      const CmsModule(
        config: CmsConfig(
          hydrate: true,
          initialModules: [
            LoyaltyBannerModule(),
            SearchInputModule(),
            ProductCardModule(),
            RepeaterModule(),
          ],
        ),
      ),
    ]);

    await tester.pumpWidget(const CmsExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Fluent CMS Showcase'), findsOneWidget);
    expect(find.textContaining('Hola, Alfonso'), findsOneWidget);
    expect(find.textContaining('MacBook Pro M3'), findsOneWidget);

    // Switch to Tier 1 (Static)
    await tester.tap(find.text('Tier 1'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Página Estática (Tier 1)'), findsOneWidget);
    expect(find.textContaining('NoOpHydrationEngine'), findsOneWidget);

    // Switch breakpoint to Desktop
    await tester.tap(find.byIcon(Icons.phone_android));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.desktop_windows), findsOneWidget);

    await Fluent.reset();
  });
}
