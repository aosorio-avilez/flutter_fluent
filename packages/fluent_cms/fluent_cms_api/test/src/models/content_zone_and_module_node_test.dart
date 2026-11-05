import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContentZone, ModuleNode & A11yConfig', () {
    test('A11yConfig serializes, deserializes, and supports copyWith', () {
      const a11y = A11yConfig(
        label: 'Banner',
        hint: 'Double tap to open',
        isButton: true,
        isHeader: true,
        excludeSemantics: true,
      );
      final json = a11y.toJson();
      final parsed = A11yConfig.fromJson(json);
      expect(parsed, equals(a11y));
      expect(a11y.copyWith(label: 'Updated').label, 'Updated');
      expect(a11y.copyWith(), equals(a11y));
    });

    test('ModuleNode resolves responsiveProps and platform support', () {
      final node = ModuleNode.fromJson(const <String, dynamic>{
        'id': 'mod_1',
        'type': 'hero',
        'platforms': ['android', 'desktop'],
        'visibleWhen': '{{data.show}} == true',
        'requiresData': ['async.wallet'],
        'hideOnError': false,
        'keepAlive': true,
        'a11y': {'label': 'Hero'},
        'props': {'title': 'Base', 'maxLines': 2},
        'responsiveProps': {
          'desktop': {'maxLines': 4, 'wide': true},
        },
        'actions': {
          'onTap': {'actionType': 'navigation', 'target': '/home'},
        },
      });

      expect(
        identical(
          node.resolvePropsForBreakpoint(CmsBreakpoint.mobile),
          node.props,
        ),
        isTrue,
      );
      expect(
        node.resolvePropsForBreakpoint(CmsBreakpoint.desktop),
        {'title': 'Base', 'maxLines': 4, 'wide': true},
      );

      expect(node.isSupportedOnPlatform('android'), isTrue);
      expect(node.isSupportedOnPlatform('macos'), isTrue);
      expect(node.isSupportedOnPlatform('windows'), isTrue);
      expect(node.isSupportedOnPlatform('linux'), isTrue);
      expect(node.isSupportedOnPlatform('ios'), isFalse);

      final allPlatformsNode = node.copyWith(
        id: 'mod_2',
        type: 'banner',
        platforms: const [],
        visibleWhen: 'true',
        requiresData: const [],
        hideOnError: true,
        keepAlive: false,
        a11y: const A11yConfig(),
        props: const {'k': 'v'},
        responsiveProps: const {},
        actions: const {},
      );
      expect(allPlatformsNode.isSupportedOnPlatform('ios'), isTrue);
      expect(
        identical(
          allPlatformsNode.resolvePropsForBreakpoint(CmsBreakpoint.mobile),
          allPlatformsNode.props,
        ),
        isTrue,
      );
      expect(allPlatformsNode.copyWith(), equals(allPlatformsNode));
      expect(
        allPlatformsNode.hashCode,
        equals(allPlatformsNode.copyWith().hashCode),
      );
      expect(ModuleNode.fromJson(node.toJson()), equals(node));
    });

    test('ContentZone parses nested modules and supports copyWith', () {
      final zone = ContentZone.fromJson(const <String, dynamic>{
        'pinned': true,
        'stickyBottom': false,
        'visibleWhen': '{{state.ready}}',
        'padding': r'$spacingMd',
        'modules': <dynamic>[
          <dynamic, dynamic>{'id': 'm1', 'type': 'text'},
        ],
      });

      expect(zone.pinned, isTrue);
      expect(zone.modules.length, 1);
      expect(zone.modules.first.id, 'm1');

      final updated = zone.copyWith(
        pinned: false,
        stickyBottom: true,
        visibleWhen: 'true',
        padding: 16,
        modules: const [],
      );
      expect(updated.stickyBottom, isTrue);
      expect(updated.copyWith(), equals(updated));
      expect(ContentZone.fromJson(zone.toJson()), equals(zone));
    });
  });
}
