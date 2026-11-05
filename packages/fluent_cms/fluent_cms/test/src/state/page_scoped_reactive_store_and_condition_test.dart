import 'package:fluent_cms/fluent_cms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PageScopedReactiveStore', () {
    test(
      'notifies per-key listeners surgically, validates, and preserves state',
      () {
        final store = PageScopedReactiveStore(
          initialValues: const <String, dynamic>{'sysKey': 'initial'},
        );

        var queryNotifications = 0;
        store.listenKey('searchQuery').addListener(() {
          queryNotifications++;
        });

        store.registerValidator('searchQuery', (val) {
          final text = val?.toString() ?? '';
          return text.length < 3 ? 'Min 3 chars' : null;
        });

        final errorListenable = store.listenError('searchQuery');
        expect(errorListenable.value, isNull);

        store.setValue('searchQuery', 'ab');
        expect(queryNotifications, 1);
        expect(store.getValue<String>('searchQuery'), 'ab');
        expect(errorListenable.value, 'Min 3 chars');
        expect(store.validateAll(), isFalse);

        store.setValue('searchQuery', 'flutter');
        expect(queryNotifications, 2);
        expect(errorListenable.value, isNull);
        expect(store.validateAll(), isTrue);

        // Clear while preserving user-mutated keys
        store.clear(preserveUserState: true);
        expect(store.getValue<String>('sysKey'), isNull);
        expect(store.getValue<String>('searchQuery'), 'flutter');

        final snapshot = store.toMap();
        store.clear();
        expect(store.getValue<String>('searchQuery'), isNull);

        store
          ..restoreState(snapshot)
          ..restoreState(const <String, dynamic>{'newKey': 123});
        expect(store.getValue<String>('searchQuery'), 'flutter');
        expect(store.getValue<int>('newKey'), 123);

        store.dispose();
        expect(store.isDisposed, isTrue);
        store.setValue('searchQuery', 'ignored');
        expect(store.getValue<String>('searchQuery'), isNull);
        expect(store.validateAll(), isFalse);
        expect(store.toMap(), isEmpty);
      },
    );
  });

  group('ConditionEvaluator', () {
    test('evaluates complex boolean expressions across all scopes', () {
      const evaluator = ConditionEvaluator();
      expect(evaluator, isNotNull);

      final scope = HydrationScope(
        dataContext: const <String, dynamic>{
          'user': <String, dynamic>{
            'tier': 'Gold',
            'points': 1500,
            'tags': <String>['vip', 'early'],
          },
          'membership': <String, dynamic>{'active': true},
        },
        clientContext: const <String, dynamic>{
          'platform': 'ios',
        },
        stateValues: const <String, dynamic>{
          'searchQuery': 'shoes',
          'filterCount': 2,
        },
        asyncData: const <String, Map<String, dynamic>>{
          'wallet': <String, dynamic>{'balance': 250.5},
        },
        itemData: const <String, dynamic>{'sku': 'SKU-1', 'stock': 5},
        itemIndex: 0,
        featureFlagLookup: (flag) => flag == 'loyalty_v2',
      );

      expect(ConditionEvaluator.evaluate(null, scope), isTrue);
      expect(ConditionEvaluator.evaluate('   ', scope), isTrue);

      expect(
        ConditionEvaluator.evaluate(
          '{{data.membership.active}} == true && '
          '{{env.features.loyalty_v2}} == true',
          scope,
        ),
        isTrue,
      );
      expect(
        ConditionEvaluator.evaluate(
          '{{data.user.points}} >= 1000 && {{async.wallet.balance}} > 100',
          scope,
        ),
        isTrue,
      );
      expect(
        ConditionEvaluator.evaluate(
          "{{client.platform}} == 'android' || {{state.filterCount}} <= 3",
          scope,
        ),
        isTrue,
      );
      expect(
        ConditionEvaluator.evaluate(
          '!{{env.features.disabled_flag}} && {{item.stock}} != 0 && '
          '{{index}} < 5',
          scope,
        ),
        isTrue,
      );
      expect(
        ConditionEvaluator.evaluate(
          '{{data.user.tags.0}} == "vip"',
          scope,
        ),
        isTrue,
      );
      expect(
        ConditionEvaluator.evaluate(
          'searchQuery == "shoes" && {{data.user.tags}} && {{async.wallet}}',
          scope,
        ),
        isTrue,
      );
      expect(
        ConditionEvaluator.evaluate(
          '{{data.membership.active}} == false',
          scope,
        ),
        isFalse,
      );
    });
  });
}
