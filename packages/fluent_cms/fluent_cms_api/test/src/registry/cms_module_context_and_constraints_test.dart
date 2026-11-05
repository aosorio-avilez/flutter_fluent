import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCmsPageStore extends Mock implements CmsPageStore {}

class _TestModuleContext extends CmsModuleContext {
  _TestModuleContext({
    required this.props,
    required this.pageStore,
  });

  @override
  String get moduleId => 'mod_1';

  @override
  String get moduleType => 'test_module';

  @override
  String get zoneId => 'hero_zone';

  @override
  CmsBreakpoint get breakpoint => CmsBreakpoint.mobile;

  @override
  final CmsProps props;

  @override
  final CmsPageStore pageStore;

  @override
  bool get isActionRunning => false;

  @override
  ValueListenable<bool> get actionRunningListenable =>
      ValueNotifier<bool>(false);

  @override
  Future<void> triggerAction(
    String trigger, {
    Map<String, dynamic>? extraPayload,
  }) async {}
}

class _DummySduiModule extends SduiModule {
  const _DummySduiModule();

  @override
  String get type => 'dummy_module';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    return const SizedBox.shrink();
  }
}

void main() {
  group('ZoneConstraints & SduiModule', () {
    test('ZoneConstraints validates width, pinned, and stickyBottom rules', () {
      const constraints = ZoneConstraints(
        minWidth: 200,
        maxWidth: 800,
        allowInPinnedZone: false,
        allowInStickyBottom: false,
      );

      expect(constraints.isSatisfiedBy(availableWidth: 400), isTrue);
      expect(constraints.isSatisfiedBy(availableWidth: 150), isFalse);
      expect(constraints.isSatisfiedBy(availableWidth: 900), isFalse);
      expect(constraints.isSatisfiedBy(isPinned: true), isFalse);
      expect(constraints.isSatisfiedBy(isStickyBottom: true), isFalse);
      expect(
        constraints,
        equals(
          const ZoneConstraints(
            minWidth: 200,
            maxWidth: 800,
            allowInPinnedZone: false,
            allowInStickyBottom: false,
          ),
        ),
      );
    });

    test('SduiModule provides sensible defaults for schema and skeleton', () {
      const module = _DummySduiModule();
      expect(module.type, 'dummy_module');
      expect(module.constraints, const ZoneConstraints());
      expect(module.propsSchema, isEmpty);
      expect(
        module.buildSkeleton(
          _FakeBuildContext(),
          const ModuleNode(id: '1', type: 'dummy_module'),
        ),
        isNull,
      );
    });
  });

  group('CmsProps & CmsModuleContext safe readers', () {
    test('reads primitives, lists, maps, and spacing tokens safely', () {
      final store = _MockCmsPageStore();
      final props = CmsProps(
        const <String, dynamic>{
          'str': 'hello',
          'numStr': 42,
          'intVal': 10,
          'doubleAsInt': 15.7,
          'strInt': '99',
          'invalidInt': <int>[],
          'doubleVal': 3.14,
          'intAsDouble': 5,
          'strDouble': '2.5',
          'invalidDouble': <int>[],
          'boolTrue': true,
          'boolNum': 1,
          'boolStrTrue': 'true',
          'boolStrFalse': '0',
          'boolStrInvalid': 'maybe',
          'typedList': <String>['a', 'b'],
          'mixedList': <dynamic>['x', 123, 'y'],
          'typedMap': <String, dynamic>{'k': 'v'},
          'untypedMap': <dynamic, dynamic>{'k2': 2},
          'padDirect': EdgeInsets.all(2),
          'padAll': 12,
          'padXs': r'$spacingXs',
          'padSm': r'$spacingSm',
          'padMd': r'$spacingMd',
          'padLg': r'$spacingLg',
          'padXl': r'$spacingXl',
          'padUnknownToken': r'$unknownSpacing',
          'padCustomToken': r'$customPad',
          'padStr': '20',
          'padInvalidStr': 'not_a_number',
          'padMap': <String, dynamic>{'horizontal': 8, 'top': 4},
          'padAllMap': <String, dynamic>{'all': 6},
        },
        tokenLookup: (context, token) {
          if (token == r'$customPad') return 10;
          return null;
        },
      );

      final ctx = _TestModuleContext(props: props, pageStore: store);

      expect(CmsProps.empty.raw, isEmpty);
      expect(ctx.props, equals(props));
      expect(ctx.props['str'], 'hello');
      expect(ctx.getString('str'), 'hello');
      expect(ctx.getString('numStr'), '42');
      expect(ctx.getString('missing', defaultValue: 'fallback'), 'fallback');

      expect(ctx.getInt('intVal'), 10);
      expect(ctx.getInt('doubleAsInt'), 15);
      expect(ctx.getInt('strInt'), 99);
      expect(ctx.getInt('invalidInt', defaultValue: 3), 3);
      expect(ctx.getInt('missing', defaultValue: 7), 7);

      expect(ctx.getDouble('doubleVal'), 3.14);
      expect(ctx.getDouble('intAsDouble'), 5.0);
      expect(ctx.getDouble('strDouble'), 2.5);
      expect(ctx.getDouble('invalidDouble', defaultValue: 0.5), 0.5);
      expect(ctx.getDouble('missing', defaultValue: 1.5), 1.5);

      expect(ctx.getBool('boolTrue'), isTrue);
      expect(ctx.getBool('boolNum'), isTrue);
      expect(ctx.getBool('boolStrTrue'), isTrue);
      expect(ctx.getBool('boolStrFalse'), isFalse);
      expect(ctx.getBool('boolStrInvalid'), isFalse);
      expect(ctx.getBool('missing', defaultValue: true), isTrue);

      expect(ctx.getList<String>('typedList'), ['a', 'b']);
      expect(ctx.getList<String>('mixedList'), ['x', 'y']);
      expect(ctx.getList<String>('missing'), isEmpty);

      expect(ctx.getMap('typedMap'), {'k': 'v'});
      expect(ctx.getMap('untypedMap'), {'k2': 2});
      expect(ctx.getMap('missing'), isEmpty);

      expect(ctx.getEdgeInsets('padDirect'), const EdgeInsets.all(2));
      expect(ctx.getEdgeInsets('padAll'), const EdgeInsets.all(12));
      expect(ctx.getEdgeInsets('padXs'), const EdgeInsets.all(4));
      expect(ctx.getEdgeInsets('padSm'), const EdgeInsets.all(8));
      expect(ctx.getEdgeInsets('padMd'), const EdgeInsets.all(16));
      expect(ctx.getEdgeInsets('padLg'), const EdgeInsets.all(24));
      expect(ctx.getEdgeInsets('padXl'), const EdgeInsets.all(32));
      expect(ctx.getEdgeInsets('padUnknownToken'), isNull);
      expect(ctx.getEdgeInsets('padCustomToken'), const EdgeInsets.all(10));
      expect(ctx.getEdgeInsets('padStr'), const EdgeInsets.all(20));
      expect(ctx.getEdgeInsets('padInvalidStr'), isNull);
      expect(ctx.getEdgeInsets('missing'), isNull);
      expect(
        ctx.getEdgeInsets('padMap'),
        const EdgeInsets.only(left: 8, right: 8, top: 4),
      );
      expect(ctx.getEdgeInsets('padAllMap'), const EdgeInsets.all(6));
    });

    testWidgets(
      'resolves Color from HEX, adaptive light/dark maps, and tokens',
      (tester) async {
        final props = CmsProps(
          const <String, dynamic>{
            'directColor': Color(0xFF123456),
            'intColor': 0xFF654321,
            'hex6': '#FF5733',
            'hex8': '0x80FF5733',
            'invalidHex': '#123',
            'emptyStr': '   ',
            'adaptive': {'light': '#FFFFFF', 'dark': '#121212'},
            'emptyMap': <String, dynamic>{},
            'tokenPrimary': r'$primary',
            'tokenSecondary': r'$secondary',
            'tokenSurface': r'$surfacePrimary',
            'tokenSurface2': r'$surfaceSecondary',
            'tokenError': r'$error',
            'tokenUnknown': r'$nonExistentToken',
            'customToken': r'$brandAccent',
          },
          tokenLookup: (context, token) {
            if (token == r'$brandAccent') return '#00FF00';
            return null;
          },
        );
        final ctx = _TestModuleContext(
          props: props,
          pageStore: _MockCmsPageStore(),
        );

        Color? lightAdaptive;
        Color? darkAdaptive;
        Color? hex6Color;
        Color? hex8Color;
        Color? customTokenColor;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Builder(
              builder: (context) {
                expect(
                  ctx.getColor(context, 'directColor'),
                  const Color(0xFF123456),
                );
                expect(
                  ctx.getColor(context, 'intColor'),
                  const Color(0xFF654321),
                );
                hex6Color = ctx.getColor(context, 'hex6');
                hex8Color = ctx.getColor(context, 'hex8');
                expect(ctx.getColor(context, 'invalidHex'), isNull);
                expect(ctx.getColor(context, 'emptyStr'), isNull);
                expect(ctx.getColor(context, 'emptyMap'), isNull);
                expect(ctx.getColor(context, 'missing'), isNull);
                lightAdaptive = ctx.getColor(context, 'adaptive');
                expect(ctx.getColor(context, 'tokenPrimary'), isNotNull);
                expect(ctx.getColor(context, 'tokenSecondary'), isNotNull);
                expect(ctx.getColor(context, 'tokenSurface'), isNotNull);
                expect(ctx.getColor(context, 'tokenSurface2'), isNotNull);
                expect(ctx.getColor(context, 'tokenError'), isNotNull);
                expect(ctx.getColor(context, 'tokenUnknown'), isNull);
                customTokenColor = ctx.getColor(context, 'customToken');
                return const SizedBox();
              },
            ),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Builder(
              builder: (context) {
                darkAdaptive = ctx.getColor(context, 'adaptive');
                return const SizedBox();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(hex6Color, const Color(0xFFFF5733));
        expect(hex8Color, const Color(0x80FF5733));
        expect(lightAdaptive, const Color(0xFFFFFFFF));
        expect(darkAdaptive, const Color(0xFF121212));
        expect(customTokenColor, const Color(0xFF00FF00));
      },
    );
  });

  group('CmsActionEvent', () {
    test('supports Equatable value equality', () {
      const action = ActionNode(actionType: 'navigation', target: '/home');
      const event1 = CmsActionEvent(
        pageId: 'home',
        moduleId: 'm1',
        trigger: 'onTap',
        action: action,
        resolvedPayload: {'k': 'v'},
        resolvedAnalytics: {'e': 'tap'},
      );
      const event2 = CmsActionEvent(
        pageId: 'home',
        moduleId: 'm1',
        trigger: 'onTap',
        action: action,
        resolvedPayload: {'k': 'v'},
        resolvedAnalytics: {'e': 'tap'},
      );
      expect(event1, equals(event2));
    });
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}
