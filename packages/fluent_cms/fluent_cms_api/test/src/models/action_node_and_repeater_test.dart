import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActionNode, OptimisticMutation & RepeaterConfig', () {
    test('ActionNode and OptimisticMutation serialize and copyWith', () {
      final action = ActionNode.fromJson(const <String, dynamic>{
        'actionType': 'custom_command',
        'target': 'toggle_favorite',
        'concurrency': 'debounce',
        'debounceMs': 250,
        'payload': {'itemId': '123'},
        'optimisticState': {
          'key': 'isFavorite',
          'value': true,
          'rollbackOnError': true,
        },
        'analytics': {'event': 'fav_clicked'},
        'onSuccess': {
          'actionType': 'scroll_to',
          'target': 'top_banner',
        },
        'onError': {
          'actionType': 'analytics_only',
          'analytics': {'event': 'fav_failed'},
        },
      });

      expect(action.actionType, 'custom_command');
      expect(action.optimisticState?.key, 'isFavorite');
      expect(action.optimisticState?.value, isTrue);
      expect(action.onSuccess?.actionType, 'scroll_to');
      expect(action.onError?.actionType, 'analytics_only');

      final roundTripped = ActionNode.fromJson(action.toJson());
      expect(roundTripped, equals(action));

      final mutatedOptimistic = action.optimisticState!.copyWith(
        key: 'liked',
        value: false,
        rollbackOnError: false,
      );
      expect(mutatedOptimistic.key, 'liked');
      expect(mutatedOptimistic.copyWith(), equals(mutatedOptimistic));

      final copiedAction = action.copyWith(
        actionType: 'navigation',
        target: '/next',
        concurrency: 'dropIfBusy',
        debounceMs: 500,
        payload: const {'a': 1},
        optimisticState: mutatedOptimistic,
        analytics: const {'e': 1},
        onSuccess: const ActionNode(actionType: 'analytics_only'),
        onError: const ActionNode(actionType: 'analytics_only'),
      );
      expect(copiedAction.actionType, 'navigation');
      expect(copiedAction.copyWith(), equals(copiedAction));
    });

    test('RepeaterConfig resolves crossAxisCount per breakpoint', () {
      final repeater = RepeaterConfig.fromJson(const <String, dynamic>{
        'layoutMode': 'grid',
        'crossAxisCount': {'mobile': 2, 'desktop': 4},
        'itemsDataPath': 'data.products',
        'pagination': {
          'endpoint': '/v1/products',
          'pageParam': 'p',
          'pageSize': 15,
        },
        'itemTemplate': {
          'id': 'prod_{{item.sku}}',
          'type': 'product_card',
        },
      });

      expect(repeater.isGrid, isTrue);
      expect(repeater.resolveCrossAxisCount(CmsBreakpoint.mobile), 2);
      expect(repeater.resolveCrossAxisCount(CmsBreakpoint.tablet), 2);
      expect(repeater.resolveCrossAxisCount(CmsBreakpoint.desktop), 4);

      final tabletFallbackRepeater = repeater.copyWith(
        crossAxisCount: const {'mobile': 1, 'tablet': 3},
      );
      expect(
        tabletFallbackRepeater.resolveCrossAxisCount(CmsBreakpoint.desktop),
        3,
      );

      final numericRepeater = repeater.copyWith(
        layoutMode: 'list',
        crossAxisCount: 3,
        itemsDataPath: 'data.items',
        pagination: repeater.pagination!.copyWith(
          endpoint: '/v2/products',
          pageParam: 'page',
          pageSize: 30,
        ),
        itemTemplate: const ModuleNode(id: 'item_1', type: 'row'),
      );
      expect(numericRepeater.isGrid, isFalse);
      expect(numericRepeater.resolveCrossAxisCount(CmsBreakpoint.mobile), 3);
      expect(
        numericRepeater.pagination?.copyWith(),
        equals(numericRepeater.pagination),
      );
      expect(numericRepeater.copyWith(), equals(numericRepeater));
      expect(RepeaterConfig.fromJson(repeater.toJson()), equals(repeater));
    });
  });
}
