import 'package:fluent_cms/fluent_cms.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/cms_mocks.dart';

class _TestModule extends SduiModule {
  const _TestModule();

  @override
  String get type => 'test_banner';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    return const SizedBox.shrink();
  }
}

class _TestPipe extends PipeTransformer {
  @override
  String get name => 'upper';

  @override
  Object? transform(
    Object? value, {
    String? argument,
    BuildContext? context,
  }) => value?.toString().toUpperCase();
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      EnvironmentAction(label: 'dummy', onTap: (_) {}),
    );
  });

  group('CmsApiImpl', () {
    late MockLoggerApi logger;
    late MockNetworkingApi networking;

    setUp(() {
      logger = MockLoggerApi();
      networking = MockNetworkingApi();
    });

    test(
      'registers modules, pipes, commands, observers, and exports schema',
      () {
        final api =
            CmsApiImpl(
                logger: logger,
                networkingApi: networking,
                config: CmsConfig(
                  initialModules: const [_TestModule()],
                  initialPipes: [_TestPipe()],
                  initialCommandHandlers: <String, CmsCommandHandler>{
                    'ping': (target, payload) async => true,
                  },
                ),
              )
              ..registerModule(const _TestModule())
              ..registerPipe(_TestPipe())
              ..registerCommandHandler('pong', (target, payload) async => true);

        expect(api.moduleRegistry.getModule('test_banner'), isNotNull);
        expect(api.getModule('test_banner'), isNotNull);
        expect(api.registeredModules.length, 1);
        expect(api.getPipe('upper')?.transform('abc'), 'ABC');
        expect(api.commandHandlers.containsKey('ping'), isTrue);
        expect(api.commandHandlers.containsKey('pong'), isTrue);

        void observer(CmsActionEvent event) {}
        api.addActionObserver(observer);
        expect(api.actionObservers.length, 1);
        api.removeActionObserver(observer);
        expect(api.actionObservers, isEmpty);

        expect(api.debugZoneBordersEnabled.value, isFalse);
        api.toggleDebugZoneBorders();
        expect(api.debugZoneBordersEnabled.value, isTrue);

        final schema = api.exportJsonSchema();
        expect(schema[r'$schema'], CmsJsonSchemaGenerator.draft202012Uri);
      },
    );

    test(
      'fetches and caches page via NetworkingApi and handles Failure',
      () async {
        final api = CmsApiImpl(
          logger: logger,
          networkingApi: networking,
          config: const CmsConfig(
            allowedHosts: {'api.fluent.mx'},
          ),
        );

        when(
          () => networking.get<dynamic>(
            any(),
            cacheConfig: any(named: 'cacheConfig'),
          ),
        ).thenAnswer(
          (_) async => const Success<dynamic>(<String, dynamic>{
            'schemaVersion': '1.0.0',
            'pageId': 'home',
            'cacheTtlSeconds': 300,
            'layout': {
              'mobile': {'type': 'single_column', 'zonesOrder': <String>[]},
            },
            'zones': <String, dynamic>{},
          }),
        );

        final page1 = await api.fetchPage(
          'https://api.fluent.mx/v1/pages/home',
        );
        final page2 = await api.fetchPage(
          'https://api.fluent.mx/v1/pages/home',
        );
        expect(page1.pageId, 'home');
        expect(identical(page1, page2), isTrue);
        verify(
          () => networking.get<dynamic>(
            any(),
            cacheConfig: any(named: 'cacheConfig'),
          ),
        ).called(1);

        api.clearCache();

        // String response from NetworkingApi
        when(
          () => networking.get<dynamic>(
            any(),
            cacheConfig: any(named: 'cacheConfig'),
          ),
        ).thenAnswer(
          (_) async => const Success<dynamic>(
            '{"schemaVersion":"1.0.0","pageId":"str_page",'
            '"layout":{"mobile":{"type":"single_column"}},"zones":{}}',
          ),
        );

        final strPage = await api.fetchPage(
          'https://api.fluent.mx/v1/pages/str',
        );
        expect(strPage.pageId, 'str_page');

        when(
          () => networking.get<dynamic>(
            any(),
            cacheConfig: any(named: 'cacheConfig'),
          ),
        ).thenAnswer(
          (_) async => Failure<dynamic>(
            HttpError(message: 'Server Error', code: 500),
          ),
        );

        await expectLater(
          () => api.fetchPage('https://api.fluent.mx/v1/pages/fail'),
          throwsStateError,
        );
        verify(() => logger.logError(any<dynamic>())).called(1);

        await expectLater(
          () => api.fetchPage('javascript:evil()'),
          throwsArgumentError,
        );

        final apiWithoutNetworking = CmsApiImpl();
        await expectLater(
          () => apiWithoutNetworking.fetchPage('/v1/pages/home'),
          throwsStateError,
        );
      },
    );

    test('fetches page via custom pageJsonFetcher', () async {
      final api = CmsApiImpl(
        config: CmsConfig(
          pageJsonFetcher: (endpoint, {forceRefresh = false}) async {
            return '''
{
  "schemaVersion": "1.0.0",
  "pageId": "custom_fetched",
  "layout": { "mobile": { "type": "single_column" } },
  "zones": {}
}
''';
          },
        ),
      );

      final page = await api.fetchPage('/pages/custom');
      expect(page.pageId, 'custom_fetched');
    });
  });

  group('CmsModule', () {
    test(
      'registers CmsApi lazily and integrates with EnvironmentApi',
      () async {
        final registry = MockRegistry();
        final envApi = MockEnvironmentApi();
        final logger = MockLoggerApi();
        final networking = MockNetworkingApi();
        final cmsApi = MockCmsApi();
        final capturedActions = <EnvironmentAction>[];

        Registry Function(Registry)? capturedFactory;

        when(
          () => registry.registerLazySingleton<CmsApi>(any()),
        ).thenAnswer((invocation) {
          final fn =
              invocation.positionalArguments.first as CmsApi Function(Registry);
          capturedFactory = (reg) {
            fn(reg);
            return reg;
          };
        });

        when(() => registry.isRegistered<EnvironmentApi>()).thenReturn(true);
        when(() => registry.get<EnvironmentApi>()).thenReturn(envApi);
        when(() => envApi.registerResetService<CmsApi>()).thenReturn(null);
        when(() => envApi.registerAction(any())).thenAnswer((inv) {
          capturedActions.add(
            inv.positionalArguments.first as EnvironmentAction,
          );
        });

        when(() => registry.isRegistered<LoggerApi>()).thenReturn(true);
        when(() => registry.get<LoggerApi>()).thenReturn(logger);
        when(() => registry.isRegistered<NetworkingApi>()).thenReturn(true);
        when(() => registry.get<NetworkingApi>()).thenReturn(networking);
        when(() => registry.isRegistered<CmsApi>()).thenReturn(true);
        when(() => registry.get<CmsApi>()).thenReturn(cmsApi);

        const module = CmsModule();
        await module.onCreate(registry);

        verify(() => registry.registerLazySingleton<CmsApi>(any())).called(1);
        verify(() => envApi.registerResetService<CmsApi>()).called(1);
        expect(capturedActions.length, 2);

        capturedFactory?.call(registry);

        capturedActions[0].onTap(_FakeBuildContext());
        verify(cmsApi.toggleDebugZoneBorders).called(1);

        capturedActions[1].onTap(_FakeBuildContext());
        verify(cmsApi.clearCache).called(1);
      },
    );
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}
