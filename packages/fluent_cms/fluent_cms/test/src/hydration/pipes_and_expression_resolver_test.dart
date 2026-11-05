import 'package:fluent_cms/fluent_cms.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/cms_mocks.dart';

void main() {
  group('Built-in PipeTransformers & PipeTransformerRegistry', () {
    test('CurrencyPipe formats positive, negative, and ISO codes', () {
      const pipe = CurrencyPipe();
      expect(pipe.name, 'currency');
      expect(pipe.transform(1250.5, argument: 'MXN'), r'MXN $1,250.50');
      expect(pipe.transform(-1250.5, argument: 'USD'), r'USD -$1,250.50');
      expect(pipe.transform('99.9', argument: 'EUR'), '€99.90');
      expect(pipe.transform(45, argument: 'GBP'), '£45.00');
      expect(pipe.transform(1500, argument: 'JPY'), '¥1,500');
      expect(pipe.transform(10), r'$10.00');
      expect(pipe.transform('not_a_number'), 'not_a_number');
      expect(pipe.transform(null), '');
    });

    test('NumberPipe formats integers, decimals, and custom precision', () {
      const pipe = NumberPipe();
      expect(pipe.name, 'number');
      expect(pipe.transform(1234567), '1,234,567');
      expect(pipe.transform(-1234567), '-1,234,567');
      expect(pipe.transform(1234.5), '1,234.50');
      expect(pipe.transform(-1234.5), '-1,234.50');
      expect(pipe.transform('1234.567', argument: '1'), '1,234.6');
      expect(pipe.transform(-1234.567, argument: '2'), '-1,234.57');
      expect(pipe.transform('invalid'), 'invalid');
      expect(pipe.transform(null), '');
    });

    test('DatePipe formats DateTime, epoch ms, and ISO strings', () {
      const pipe = DatePipe();
      expect(pipe.name, 'date');
      final dt = DateTime.utc(2026, 11, 4, 15, 30);
      expect(pipe.transform(dt), '2026-11-04');
      expect(pipe.transform(dt, argument: 'dd/MM/yyyy'), '04/11/2026');
      expect(pipe.transform(dt, argument: 'MM/dd/yyyy'), '11/04/2026');
      expect(
        pipe.transform(dt, argument: 'yyyy-MM-dd HH:mm'),
        '2026-11-04 15:30',
      );
      expect(pipe.transform(dt.millisecondsSinceEpoch), '2026-11-04');
      expect(pipe.transform('2026-11-04T15:30:00Z'), '2026-11-04');
      expect(pipe.transform('not-a-date'), 'not-a-date');
      expect(pipe.transform(null), '');
    });

    test('UppercasePipe, LowercasePipe, DefaultPipe, and TranslatePipe', () {
      const upper = UppercasePipe();
      const lower = LowercasePipe();
      const def = DefaultPipe();
      final translate = TranslatePipe(
        translator: (key, {argument, context}) =>
            key == 'home.greeting' ? 'Hola Mundo' : null,
        dictionary: const <String, String>{'home.cta': 'Comprar'},
      );

      expect(upper.name, 'uppercase');
      expect(upper.transform('hola'), 'HOLA');
      expect(upper.transform(null), '');

      expect(lower.name, 'lowercase');
      expect(lower.transform('HOLA'), 'hola');
      expect(lower.transform(null), '');

      expect(def.name, 'default');
      expect(def.transform(null, argument: 'Invitado'), 'Invitado');
      expect(def.transform('', argument: 'Invitado'), 'Invitado');
      expect(def.transform('Alfonso', argument: 'Invitado'), 'Alfonso');

      expect(translate.name, 'translate');
      expect(translate.transform('home.greeting'), 'Hola Mundo');
      expect(translate.transform('home.cta'), 'Comprar');
      expect(
        translate.transform('home.missing', argument: 'Por defecto'),
        'Por defecto',
      );
      expect(translate.transform('home.raw'), 'home.raw');
      expect(translate.transform(null, argument: 'Vacío'), 'Vacío');
      expect(translate.transform('', argument: 'Vacío'), 'Vacío');
    });

    test('PipeTransformerRegistry registers and applies pipe segments', () {
      final logger = MockLoggerApi();
      final registry = PipeTransformerRegistry(logger: logger);

      expect(registry.registeredPipes.length, greaterThanOrEqualTo(7));
      expect(registry.getPipe('currency'), isNotNull);

      expect(
        registry.applyPipeSegment('currency:"MXN"', 500),
        r'MXN $500.00',
      );
      expect(
        registry.applyPipeSegment("default:'N/A'", ''),
        'N/A',
      );
      expect(registry.applyPipeSegment('   ', 'val'), 'val');
      expect(registry.applyPipeSegment('unknown_pipe', 'val'), 'val');
      verify(() => logger.logWarning(any<String>())).called(1);
    });
  });

  group('SinglePassExpressionResolver & MixedHydrationEngine', () {
    test(
      'returns identical reference on Fast-Path when no {{}} is present',
      () {
        final engine = MixedHydrationEngine();
        const scope = HydrationScope.empty;

        const staticStr = 'Banner Estático sin placeholders';
        expect(
          identical(engine.resolveString(staticStr, scope), staticStr),
          isTrue,
        );
        expect(
          identical(engine.resolveValue(staticStr, scope), staticStr),
          isTrue,
        );

        const staticProps = <String, dynamic>{
          'title': 'Fijo',
          'count': 3,
          'tags': <Object?>['a', 'b'],
        };
        expect(
          identical(engine.resolveProps(staticProps, scope), staticProps),
          isTrue,
        );
      },
    );

    test(
      'resolves all scopes, nested lists, chained pipes, and standalone types',
      () {
        final engine = MixedHydrationEngine();
        final scope = HydrationScope(
          dataContext: const <String, dynamic>{
            'user': <String, dynamic>{'firstName': 'Alfonso'},
            'membership': <String, dynamic>{'active': true, 'savings': 1250.5},
            'items': <Object?>[
              <String, dynamic>{'title': 'Laptop'},
            ],
          },
          clientContext: const <String, dynamic>{'locale': 'es_MX'},
          stateValues: const <String, dynamic>{
            'searchQuery': 'teclado',
            'missingVal': null,
          },
          asyncData: const <String, Map<String, dynamic>>{
            'wallet': <String, dynamic>{'balance': 300},
          },
          itemData: const <String, dynamic>{'sku': 'SKU-99', 'name': 'Mouse'},
          itemIndex: 2,
          featureFlagLookup: (flag) => flag == 'loyalty_v2',
        );

        expect(
          engine.resolveString(
            'Hola {{data.user.firstName}} ({{client.locale}}) - '
            '{{data.membership.savings | currency:MXN}} - '
            '{{async.wallet.balance | currency:USD}} - '
            '{{item.name | uppercase}} #{{index}} - '
            '{{data.items.0.title}} - '
            '{{state.missingVal | default:Sin filtro}}',
            scope,
          ),
          r'Hola Alfonso (es_MX) - MXN $1,250.50 - USD $300.00 - '
          'MOUSE #2 - Laptop - Sin filtro',
        );

        // Standalone tokens preserve runtime type
        expect(
          engine.resolveValue('{{data.membership.active}}', scope),
          isTrue,
        );
        expect(
          engine.resolveValue('{{env.features.loyalty_v2}}', scope),
          isTrue,
        );
        expect(engine.resolveValue('{{index}}', scope), 2);
        expect(
          engine.resolveValue('{{item}}', scope),
          const <String, dynamic>{'sku': 'SKU-99', 'name': 'Mouse'},
        );

        // Nested maps and lists hydration
        final rawProps = <String, dynamic>{
          'greeting': 'Hola {{data.user.firstName}}',
          'nested': <Object?, Object?>{'q': '{{state.searchQuery}}'},
          'list': <Object?>['{{item.sku}}', 'static'],
        };
        final resolvedProps = engine.resolveProps(rawProps, scope);
        expect(resolvedProps['greeting'], 'Hola Alfonso');
        expect(
          (resolvedProps['nested'] as Map<String, dynamic>)['q'],
          'teclado',
        );
        expect(resolvedProps['list'], <Object?>['SKU-99', 'static']);

        expect(
          engine.evaluateCondition(
            '{{data.membership.active}} == true && '
            '{{env.features.loyalty_v2}} == true',
            scope,
          ),
          isTrue,
        );

        final stateKeys = engine.extractStateKeys(
          rawProps,
          visibleWhen: '{{state.filterActive}} == true',
        );
        expect(
          stateKeys,
          containsAll(<String>['searchQuery', 'filterActive']),
        );
      },
    );
  });
}
