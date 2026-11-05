import 'package:fluent_cms/fluent_cms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeTokenResolver', () {
    testWidgets(
      'resolves semantic color tokens, adaptive maps, spacing, and typography',
      (tester) async {
        final resolver =
            ThemeTokenResolver(
                lightColors: const <String, Color>{
                  'brandAccent': Color(0xFF112233),
                },
                darkColors: const <String, Color>{
                  'brandAccent': Color(0xFF8899AA),
                },
                spacingTokens: const <String, EdgeInsets>{
                  'spacingCustom': EdgeInsets.all(20),
                },
                numericTokens: const <String, double>{'radiusCustom': 18},
                textStyleTokens: const <String, TextStyle>{
                  'heroTitle': TextStyle(fontSize: 32),
                },
              )
              ..registerColorToken(
                r'$customStatus',
                light: const Color(0xFF00AA00),
                dark: const Color(0xFF55FF55),
              )
              ..registerSpacingToken(r'$gapSm', const EdgeInsets.all(6))
              ..registerNumericToken(r'$cornerSm', 6)
              ..registerTextStyleToken(
                r'$captionCustom',
                const TextStyle(fontSize: 11),
              );

        late BuildContext lightCtx;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Builder(
              builder: (context) {
                lightCtx = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(
          resolver.resolveColor(lightCtx, r'$surfacePrimary'),
          const Color(0xFFFFFFFF),
        );
        expect(
          resolver.resolveColor(lightCtx, r'$brandAccent'),
          const Color(0xFF112233),
        );
        expect(
          resolver.resolveColor(lightCtx, r'$customStatus'),
          const Color(0xFF00AA00),
        );
        expect(
          resolver.resolveColor(lightCtx, r'$primary'),
          Theme.of(lightCtx).colorScheme.primary,
        );
        expect(
          resolver.resolveColor(
            lightCtx,
            const <String, dynamic>{'light': '#123456', 'dark': '#654321'},
          ),
          const Color(0xFF123456),
        );
        expect(
          resolver.resolveColor(lightCtx, '#F00'),
          const Color(0xFFFF0000),
        );
        expect(
          resolver.resolveColor(lightCtx, '0xFF00FF00'),
          const Color(0xFF00FF00),
        );
        expect(
          resolver.resolveColor(lightCtx, const Color(0xFFABCDEF)),
          const Color(0xFFABCDEF),
        );

        // EdgeInsets resolution
        expect(
          resolver.resolveEdgeInsets(r'$spacingMd', context: lightCtx),
          const EdgeInsets.all(16),
        );
        expect(
          resolver.resolveEdgeInsets(r'$spacingCustom', context: lightCtx),
          const EdgeInsets.all(20),
        );
        expect(
          resolver.resolveEdgeInsets(r'$gapSm', context: lightCtx),
          const EdgeInsets.all(6),
        );
        expect(
          resolver.resolveEdgeInsets(12, context: lightCtx),
          const EdgeInsets.all(12),
        );
        expect(
          resolver.resolveEdgeInsets('14', context: lightCtx),
          const EdgeInsets.all(14),
        );
        expect(
          resolver.resolveEdgeInsets(
            const <String, dynamic>{'all': r'$spacingSm'},
            context: lightCtx,
          ),
          const EdgeInsets.all(8),
        );
        expect(
          resolver.resolveEdgeInsets(
            const <String, dynamic>{
              'horizontal': r'$spacingMd',
              'vertical': r'$spacingXs',
            },
            context: lightCtx,
          ),
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        );
        expect(
          resolver.resolveEdgeInsets(
            const <String, dynamic>{
              'left': 2,
              'top': 4,
              'right': 6,
              'bottom': 8,
            },
            context: lightCtx,
          ),
          const EdgeInsets.fromLTRB(2, 4, 6, 8),
        );

        // BorderRadius resolution
        expect(
          resolver.resolveBorderRadius(r'$radiusMd', context: lightCtx),
          BorderRadius.circular(12),
        );
        expect(
          resolver.resolveBorderRadius(r'$radiusCustom', context: lightCtx),
          BorderRadius.circular(18),
        );
        expect(
          resolver.resolveBorderRadius(r'$cornerSm', context: lightCtx),
          BorderRadius.circular(6),
        );
        expect(
          resolver.resolveBorderRadius(10, context: lightCtx),
          BorderRadius.circular(10),
        );

        // TextStyle resolution
        expect(
          resolver.resolveTextStyle(lightCtx, r'$titleLarge'),
          Theme.of(lightCtx).textTheme.titleLarge,
        );
        expect(
          resolver.resolveTextStyle(lightCtx, r'$bodyMedium'),
          Theme.of(lightCtx).textTheme.bodyMedium,
        );
        expect(
          resolver.resolveTextStyle(lightCtx, r'$heroTitle')?.fontSize,
          32,
        );
        expect(
          resolver.resolveTextStyle(lightCtx, r'$captionCustom')?.fontSize,
          11,
        );

        // CmsProps integration via tokenLookup
        final cmsProps = CmsProps(
          const <String, dynamic>{
            'bg': r'$surfaceSecondary',
            'pad': r'$spacingLg',
          },
          tokenLookup: resolver.resolveToken,
        );
        expect(
          cmsProps.getColor(lightCtx, 'bg'),
          const Color(0xFFF5F7FA),
        );
        expect(
          cmsProps.getEdgeInsets('pad', context: lightCtx),
          const EdgeInsets.all(24),
        );

        // Dark mode resolution
        late BuildContext darkCtx;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Builder(
              builder: (context) {
                darkCtx = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          resolver.resolveColor(darkCtx, r'$surfacePrimary'),
          const Color(0xFF121212),
        );
        expect(
          resolver.resolveColor(darkCtx, r'$brandAccent'),
          const Color(0xFF8899AA),
        );
        expect(
          resolver.resolveColor(
            darkCtx,
            const <String, dynamic>{'light': '#123456', 'dark': '#654321'},
          ),
          const Color(0xFF654321),
        );
      },
    );
  });
}
