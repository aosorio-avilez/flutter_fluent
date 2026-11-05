import 'package:fluent_cms/fluent_cms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/cms_mocks.dart';

class _ConstrainedModule extends SduiModule {
  const _ConstrainedModule();

  @override
  String get type => 'desktop_only_banner';

  @override
  ZoneConstraints get constraints => const ZoneConstraints(
    minWidth: 600,
    allowInPinnedZone: false,
  );

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    return const SizedBox.shrink();
  }
}

void main() {
  group('CmsModuleRegistry & FallbackModuleWidget', () {
    late MockLoggerApi logger;
    late CmsModuleRegistry registry;

    setUp(() {
      logger = MockLoggerApi();
      registry = CmsModuleRegistry(
        logger: logger,
        initialModules: const [_ConstrainedModule()],
      );
    });

    test('registers and resolves valid module satisfying ZoneConstraints', () {
      expect(registry.getModule('desktop_only_banner'), isNotNull);
      expect(registry.registeredModules.length, 1);

      const node = ModuleNode(id: 'b1', type: 'desktop_only_banner');
      final resolution = registry.resolveForZone(
        node,
        availableWidth: 800,
      );

      expect(resolution.isValid, isTrue);
      expect(resolution.module?.type, 'desktop_only_banner');
      verifyNever(() => logger.logWarning(any<dynamic>()));
    });

    test('logs warning and fails resolution for unknown module type', () {
      const node = ModuleNode(id: 'u1', type: 'unknown_widget');
      final resolution = registry.resolveForZone(node);

      expect(resolution.isValid, isFalse);
      expect(resolution.module, isNull);
      expect(resolution.failureReason, contains('Unregistered module type'));
      verify(() => logger.logWarning(any<dynamic>())).called(1);
    });

    test('logs warning and fails resolution when ZoneConstraints violated', () {
      const node = ModuleNode(id: 'b1', type: 'desktop_only_banner');
      final resolution = registry.resolveForZone(
        node,
        availableWidth: 320,
        isPinned: true,
      );

      expect(resolution.isValid, isFalse);
      expect(resolution.failureReason, contains('violates ZoneConstraints'));
      verify(() => logger.logWarning(any<dynamic>())).called(1);
    });

    testWidgets(
      'FallbackModuleWidget collapses when showDiagnostics is false '
      'and shows card when true',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FallbackModuleWidget(
                moduleId: 'm1',
                moduleType: 'missing',
                reason: 'Not registered',
              ),
            ),
          ),
        );
        expect(find.textContaining('[CMS Fallback]'), findsNothing);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FallbackModuleWidget(
                moduleId: 'm1',
                moduleType: 'missing',
                reason: 'Not registered',
                showDiagnostics: true,
              ),
            ),
          ),
        );
        expect(find.textContaining('[CMS Fallback]'), findsOneWidget);
      },
    );
  });
}
