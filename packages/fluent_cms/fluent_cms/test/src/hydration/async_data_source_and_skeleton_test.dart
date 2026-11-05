import 'dart:async';

import 'package:fluent_cms/fluent_cms.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/cms_mocks.dart';

class _SkeletonTestModule extends SduiModule {
  const _SkeletonTestModule();

  @override
  String get type => 'wallet_banner';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    return const Text('Wallet Loaded');
  }

  @override
  Widget? buildSkeleton(BuildContext context, ModuleNode node) {
    return const Text('Custom Wallet Skeleton');
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const CacheConfig());
  });

  group('NetworkingAsyncDataSource', () {
    late MockNetworkingApi networking;
    late MockLoggerApi logger;

    setUp(() {
      networking = MockNetworkingApi();
      logger = MockLoggerApi();
    });

    test(
      'enforces CmsConfig.isUriAllowed and returns fallback if present',
      () async {
        final dataSource = NetworkingAsyncDataSource(
          config: const CmsConfig(allowedHosts: <String>{'api.fluent.dev'}),
          networkingApi: networking,
          logger: logger,
        );

        const sourceWithFallback = AsyncSource(
          endpoint: 'javascript:alert(1)',
          fallback: <String, dynamic>{'balance': 0},
        );
        expect(
          await dataSource.fetch(sourceWithFallback),
          const <String, dynamic>{'balance': 0},
        );

        const sourceNoFallback = AsyncSource(endpoint: 'javascript:alert(1)');
        await expectLater(
          () => dataSource.fetch(sourceNoFallback),
          throwsArgumentError,
        );
      },
    );

    test('supports customFetcher and NetworkingApi GET / POST', () async {
      final customSource = NetworkingAsyncDataSource(
        customFetcher: (source, {forceRefresh = false, queryParameters}) async {
          return <String, dynamic>{'custom': source.endpoint};
        },
      );
      expect(
        await customSource.fetch(const AsyncSource(endpoint: '/v1/custom')),
        const <String, dynamic>{'custom': '/v1/custom'},
      );

      final netSource = NetworkingAsyncDataSource(
        networkingApi: networking,
        logger: logger,
      );

      when(
        () => networking.get<dynamic>(
          '/v1/get-json?page=1',
          cacheConfig: any<CacheConfig>(named: 'cacheConfig'),
        ),
      ).thenAnswer(
        (_) async => const Success<dynamic>('{"balance": 500}'),
      );

      expect(
        await netSource.fetch(
          const AsyncSource(endpoint: '/v1/get-json'),
          queryParameters: const <String, dynamic>{'page': 1},
        ),
        const <String, dynamic>{'balance': 500},
      );

      when(
        () => networking.post<dynamic>(
          '/v1/post-list',
          body: any<Object?>(named: 'body'),
          cacheConfig: any<CacheConfig>(named: 'cacheConfig'),
        ),
      ).thenAnswer(
        (_) async => const Success<dynamic>(<Object?>['item1', 'item2']),
      );

      expect(
        await netSource.fetch(
          const AsyncSource(endpoint: '/v1/post-list', method: 'POST'),
        ),
        const <String, dynamic>{
          'items': <Object?>['item1', 'item2'],
        },
      );

      // Failure with fallback
      when(
        () => networking.get<dynamic>(
          '/v1/fail',
          cacheConfig: any<CacheConfig>(named: 'cacheConfig'),
        ),
      ).thenAnswer(
        (_) async => Failure<dynamic>(
          HttpError(code: 500, message: 'Server error'),
        ),
      );

      expect(
        await netSource.fetch(
          const AsyncSource(
            endpoint: '/v1/fail',
            fallback: <String, dynamic>{'balance': 0},
          ),
        ),
        const <String, dynamic>{'balance': 0},
      );
    });
  });

  group('AsyncDataSourceManager & AutoSkeletonModuleWrapper', () {
    test(
      'deduplicates in-flight requests, caches TTL, and handles unknown',
      () async {
        var callCount = 0;
        final dataSource = NetworkingAsyncDataSource(
          customFetcher:
              (
                source, {
                forceRefresh = false,
                queryParameters,
              }) async {
                callCount++;
                await Future<void>.delayed(const Duration(milliseconds: 20));
                return <String, dynamic>{'balance': 100 * callCount};
              },
        );

        final manager = AsyncDataSourceManager(
          dataSource: dataSource,
          sources: const <String, AsyncSource>{
            'wallet': AsyncSource(endpoint: '/v1/wallet', ttlSeconds: 60),
          },
        );

        // Concurrent requests deduplicate
        final results = await Future.wait<Map<String, dynamic>?>([
          manager.resolveSource('async.wallet.balance'),
          manager.resolveSource('wallet'),
        ]);
        expect(callCount, 1);
        expect(results[0]?['balance'], 100);
        expect(results[1]?['balance'], 100);

        // Cached hit within TTL
        final cached = await manager.resolveSource('wallet');
        expect(callCount, 1);
        expect(cached?['balance'], 100);

        // Force refresh bypasses TTL
        final refreshed = await manager.resolveSource(
          'wallet',
          forceRefresh: true,
        );
        expect(callCount, 2);
        expect(refreshed?['balance'], 200);
        expect(manager.resolvedDataMap['wallet']?['balance'], 200);

        // Unknown source sets error state
        final unknown = await manager.resolveSource('unknown_source');
        expect(unknown, isNull);
        expect(
          manager.getSnapshot('unknown_source').status,
          AsyncSourceStatus.error,
        );

        await manager.prefetchAll();
        manager.dispose();
        expect(manager.isDisposed, isTrue);
      },
    );

    testWidgets(
      'AutoSkeletonModuleWrapper shows skeleton while loading and resolves',
      (tester) async {
        final completer = Completer<Map<String, dynamic>>();
        final dataSource = NetworkingAsyncDataSource(
          customFetcher: (source, {forceRefresh = false, queryParameters}) {
            if (source.endpoint == '/v1/fail') {
              return Future<Map<String, dynamic>>.error(
                StateError('Network down'),
              );
            }
            return completer.future;
          },
        );

        final manager = AsyncDataSourceManager(
          dataSource: dataSource,
          sources: const <String, AsyncSource>{
            'wallet': AsyncSource(endpoint: '/v1/wallet'),
            'broken': AsyncSource(endpoint: '/v1/fail'),
          },
        );

        const walletNode = ModuleNode(
          id: 'mod_wallet',
          type: 'wallet_banner',
          requiresData: <String>['async.wallet'],
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: Column(
                children: [
                  AutoSkeletonModuleWrapper(
                    node: walletNode,
                    asyncManager: manager,
                    childBuilder: (_) =>
                        const Text('Default Skeleton Resolved'),
                  ),
                  AutoSkeletonModuleWrapper(
                    node: walletNode,
                    module: const _SkeletonTestModule(),
                    asyncManager: manager,
                    childBuilder: (_) => const Text('Custom Skeleton Resolved'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(DefaultCmsSkeletonWidget), findsOneWidget);
        expect(find.text('Custom Wallet Skeleton'), findsOneWidget);

        completer.complete(const <String, dynamic>{'balance': 250});
        await tester.pumpAndSettle();

        expect(find.text('Default Skeleton Resolved'), findsOneWidget);
        expect(find.text('Custom Skeleton Resolved'), findsOneWidget);

        // Error collapsing when hideOnError is true
        const brokenNode = ModuleNode(
          id: 'mod_broken',
          type: 'wallet_banner',
          requiresData: <String>['async.broken'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AutoSkeletonModuleWrapper(
                node: brokenNode,
                asyncManager: manager,
                childBuilder: (_) => const Text('Should Hide'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Should Hide'), findsNothing);

        manager.dispose();
      },
    );
  });
}
