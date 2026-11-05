import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoOpHydrationEngine & HydrationScope', () {
    test('returns original references in O(1) without allocation', () {
      const engine = NoOpHydrationEngine();
      const scope = HydrationScope.empty;
      const input = 'Hello {{data.user.name}}';
      final props = <String, dynamic>{'greeting': input};
      final listValue = <String>['a', 'b'];

      expect(identical(engine.resolveString(input, scope), input), isTrue);
      expect(
        identical(engine.resolveValue(listValue, scope), listValue),
        isTrue,
      );
      expect(identical(engine.resolveProps(props, scope), props), isTrue);
      expect(
        engine.evaluateCondition('{{data.active}} == false', scope),
        isTrue,
      );
    });

    test('HydrationScope supports copyWith and Equatable equality', () {
      bool flagLookup(String key) => key == 'v2';
      final scope = HydrationScope(
        dataContext: const {'a': 1},
        clientContext: const {'b': 2},
        stateValues: const {'c': 3},
        asyncData: const {
          'wallet': {'balance': 10},
        },
        itemData: const {'sku': '1'},
        itemIndex: 0,
        featureFlagLookup: flagLookup,
      );

      final copied = scope.copyWith(itemIndex: 1);
      expect(copied.itemIndex, 1);
      expect(copied.dataContext, {'a': 1});
      expect(copied.copyWith(), equals(copied));
    });
  });
}
