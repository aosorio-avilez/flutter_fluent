import 'dart:async';

import 'package:fluent_cms/fluent_cms.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/cms_mocks.dart';

void main() {
  group('CmsActionEngine', () {
    late PageScopedReactiveStore store;
    late MockLoggerApi logger;

    setUp(() {
      store = PageScopedReactiveStore();
      logger = MockLoggerApi();
    });

    tearDown(() {
      store.dispose();
    });

    test(
      'enforces dropIfBusy concurrency and updates moduleRunningListenable',
      () async {
        final completer = Completer<bool>();
        var executionCount = 0;

        final engine = CmsActionEngine(
          pageId: 'home',
          pageStore: store,
          logger: logger,
          commandHandlers: <String, CmsCommandHandler>{
            'slow_cmd': (target, payload) {
              executionCount++;
              return completer.future;
            },
          },
        );

        final runningListenable = engine.moduleRunningListenable('mod_1');
        expect(runningListenable.value, isFalse);

        const action = ActionNode(
          actionType: 'custom_command',
          target: 'slow_cmd',
        );

        final firstFuture = engine.execute(
          moduleId: 'mod_1',
          trigger: 'onTap',
          action: action,
        );
        expect(runningListenable.value, isTrue);

        final droppedResult = await engine.execute(
          moduleId: 'mod_1',
          trigger: 'onTap',
          action: action,
        );
        expect(droppedResult, isFalse);
        expect(executionCount, 1);

        completer.complete(true);
        expect(await firstFuture, isTrue);
        expect(runningListenable.value, isFalse);

        engine.dispose();
      },
    );

    test('supports debounce and throttle concurrency policies', () async {
      var debounceCount = 0;
      var throttleCount = 0;

      final engine = CmsActionEngine(
        pageId: 'home',
        pageStore: store,
        commandHandlers: <String, CmsCommandHandler>{
          'debounced_cmd': (target, payload) async {
            debounceCount++;
            return true;
          },
          'throttled_cmd': (target, payload) async {
            throttleCount++;
            return true;
          },
        },
      );

      const debounceAction = ActionNode(
        actionType: 'custom_command',
        target: 'debounced_cmd',
        concurrency: 'debounce',
        debounceMs: 40,
      );

      final f1 = engine.execute(
        moduleId: 'search',
        trigger: 'onChanged',
        action: debounceAction,
      );
      final f2 = engine.execute(
        moduleId: 'search',
        trigger: 'onChanged',
        action: debounceAction,
      );

      expect(await f1, isFalse);
      expect(await f2, isTrue);
      expect(debounceCount, 1);

      const throttleAction = ActionNode(
        actionType: 'custom_command',
        target: 'throttled_cmd',
        concurrency: 'throttle',
        debounceMs: 50,
      );

      expect(
        await engine.execute(
          moduleId: 'btn',
          trigger: 'onTap',
          action: throttleAction,
        ),
        isTrue,
      );
      expect(
        await engine.execute(
          moduleId: 'btn',
          trigger: 'onTap',
          action: throttleAction,
        ),
        isFalse,
      );
      expect(throttleCount, 1);

      await Future<void>.delayed(const Duration(milliseconds: 65));
      expect(
        await engine.execute(
          moduleId: 'btn',
          trigger: 'onTap',
          action: throttleAction,
        ),
        isTrue,
      );
      expect(throttleCount, 2);

      engine.dispose();
    });

    test('applies optimisticState in 0ms and rolls back on failure', () async {
      store.setValue('isFavorite', false);

      final engine = CmsActionEngine(
        pageId: 'home',
        pageStore: store,
        logger: logger,
        commandHandlers: <String, CmsCommandHandler>{
          'fail_fav': (target, payload) async {
            expect(store.getValue<bool>('isFavorite'), isTrue);
            return false;
          },
        },
      );

      var errorChainCalled = false;
      engine.registerCommandHandler('notify_error', (target, payload) async {
        errorChainCalled = true;
        return true;
      });

      const action = ActionNode(
        actionType: 'custom_command',
        target: 'fail_fav',
        optimisticState: OptimisticMutation(
          key: 'isFavorite',
          value: true,
        ),
        onError: ActionNode(
          actionType: 'custom_command',
          target: 'notify_error',
        ),
      );

      final success = await engine.execute(
        moduleId: 'fav_btn',
        trigger: 'onTap',
        action: action,
      );

      expect(success, isFalse);
      expect(store.getValue<bool>('isFavorite'), isFalse);
      expect(errorChainCalled, isTrue);

      engine.dispose();
    });

    test(
      'dispatches navigation, external_url, scroll_to, modal_zone, and '
      'state_mutation',
      () async {
        String? navigatedTo;
        Uri? openedUrl;
        String? scrolledTo;
        String? modalZone;
        final observedEvents = <CmsActionEvent>[];

        final engine = CmsActionEngine(
          pageId: 'home',
          pageStore: store,
          logger: logger,
          config: const CmsConfig(
            allowedHosts: {'trusted.fluent.mx'},
          ),
          onNavigate: (target, payload) async {
            navigatedTo = target;
            return true;
          },
          onExternalUrl: (uri, payload) async {
            openedUrl = uri;
            return true;
          },
          onScrollToModule: (target, payload) async {
            scrolledTo = target;
            return true;
          },
          onShowModalZone: (target, payload) async {
            modalZone = target;
            return true;
          },
        )..addObserver(observedEvents.add);

        expect(
          await engine.execute(
            moduleId: 'm1',
            trigger: 'onTap',
            action: const ActionNode(
              actionType: 'navigation',
              target: '/wallet',
              onSuccess: ActionNode(
                actionType: 'scroll_to',
                target: 'terms_mod',
              ),
            ),
          ),
          isTrue,
        );
        expect(navigatedTo, '/wallet');
        expect(scrolledTo, 'terms_mod');

        expect(
          await engine.execute(
            moduleId: 'm1',
            trigger: 'onTap',
            action: const ActionNode(
              actionType: 'external_url',
              target: 'https://trusted.fluent.mx/promo',
            ),
          ),
          isTrue,
        );
        expect(openedUrl?.host, 'trusted.fluent.mx');

        // Blocked untrusted external URL
        expect(
          await engine.execute(
            moduleId: 'm1',
            trigger: 'onTap',
            action: const ActionNode(
              actionType: 'external_url',
              target: 'javascript:alert(1)',
            ),
          ),
          isFalse,
        );
        verify(() => logger.logWarning(any<dynamic>())).called(1);

        expect(
          await engine.execute(
            moduleId: 'm1',
            trigger: 'onTap',
            action: const ActionNode(
              actionType: 'modal_zone',
              target: 'checkout_modal',
            ),
          ),
          isTrue,
        );
        expect(modalZone, 'checkout_modal');

        expect(
          await engine.execute(
            moduleId: 'm1',
            trigger: 'onTap',
            action: const ActionNode(
              actionType: 'state_mutation',
              target: 'selectedTab',
              payload: {'value': 'offers'},
            ),
          ),
          isTrue,
        );
        expect(store.getValue<String>('selectedTab'), 'offers');

        expect(
          await engine.execute(
            moduleId: 'm1',
            trigger: 'onImpression',
            action: const ActionNode(
              actionType: 'analytics_only',
              analytics: {'event': 'viewed'},
            ),
          ),
          isTrue,
        );
        expect(observedEvents, isNotEmpty);

        engine
          ..removeObserver(observedEvents.add)
          ..dispose();
        expect(engine.isDisposed, isTrue);
      },
    );
  });
}
