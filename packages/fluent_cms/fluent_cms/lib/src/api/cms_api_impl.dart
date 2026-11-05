import 'dart:convert';

import 'package:fluent_cms/src/cms_config.dart';
import 'package:fluent_cms/src/parser/hybrid_cms_json_parser.dart';
import 'package:fluent_cms/src/registry/cms_module_registry.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:flutter/foundation.dart';

class _CachedPageEntry {
  const _CachedPageEntry({
    required this.page,
    required this.cachedAt,
  });

  final CmsPage page;
  final DateTime cachedAt;

  bool isExpired(DateTime now) {
    final ttl = page.cacheTtlSeconds;
    if (ttl == null || ttl <= 0) return false;
    return now.difference(cachedAt).inSeconds >= ttl;
  }
}

/// Concrete implementation of [CmsApi].
class CmsApiImpl implements CmsApi {
  /// Creates a [CmsApiImpl].
  CmsApiImpl({
    this.config = const CmsConfig(),
    this.parser = const HybridCmsJsonParser(),
    LoggerApi? logger,
    NetworkingApi? networkingApi,
  }) : _logger = logger,
       _networkingApi = networkingApi,
       _moduleRegistry = CmsModuleRegistry(
         logger: logger,
         initialModules: config.initialModules,
       ),
       _debugBordersNotifier = ValueNotifier<bool>(
         !const bool.fromEnvironment('dart.vm.product') &&
             config.enableDebugOverlay,
       ) {
    for (final pipe in config.initialPipes) {
      _pipes[pipe.name] = pipe;
    }
    for (final entry in config.initialCommandHandlers.entries) {
      _commandHandlers[entry.key] = entry.value;
    }
  }

  /// Global CMS configuration.
  final CmsConfig config;

  /// Hybrid JSON parser (`< 50KB` sync, `>= 50KB` Isolate).
  final HybridCmsJsonParser parser;

  final LoggerApi? _logger;
  final NetworkingApi? _networkingApi;
  final CmsModuleRegistry _moduleRegistry;
  final Map<String, PipeTransformer> _pipes = <String, PipeTransformer>{};
  final Map<String, CmsCommandHandler> _commandHandlers =
      <String, CmsCommandHandler>{};
  final List<CmsActionObserver> _actionObservers = <CmsActionObserver>[];
  final Map<String, _CachedPageEntry> _pageCache = <String, _CachedPageEntry>{};
  final ValueNotifier<bool> _debugBordersNotifier;

  /// Exposes the underlying [CmsModuleRegistry] for the layout engine.
  CmsModuleRegistry get moduleRegistry => _moduleRegistry;

  /// Unmodifiable view of registered custom command handlers.
  Map<String, CmsCommandHandler> get commandHandlers =>
      Map<String, CmsCommandHandler>.unmodifiable(_commandHandlers);

  /// Unmodifiable view of registered action observers.
  List<CmsActionObserver> get actionObservers =>
      List<CmsActionObserver>.unmodifiable(_actionObservers);

  @override
  void registerModule(SduiModule module) {
    _moduleRegistry.register(module);
  }

  @override
  SduiModule? getModule(String type) => _moduleRegistry.getModule(type);

  @override
  List<SduiModule> get registeredModules => _moduleRegistry.registeredModules;

  @override
  void registerPipe(PipeTransformer pipe) {
    _pipes[pipe.name] = pipe;
  }

  @override
  PipeTransformer? getPipe(String name) => _pipes[name];

  @override
  void registerCommandHandler(String commandName, CmsCommandHandler handler) {
    _commandHandlers[commandName] = handler;
  }

  @override
  void addActionObserver(CmsActionObserver observer) {
    _actionObservers.add(observer);
  }

  @override
  void removeActionObserver(CmsActionObserver observer) {
    _actionObservers.remove(observer);
  }

  @override
  Future<CmsPage> parsePage(String rawJson) => parser.parse(rawJson);

  @override
  Future<CmsPage> fetchPage(
    String pageIdOrEndpoint, {
    bool forceRefresh = false,
  }) async {
    if (!config.isUriAllowed(pageIdOrEndpoint)) {
      throw ArgumentError.value(
        pageIdOrEndpoint,
        'pageIdOrEndpoint',
        'Blocked by CmsConfig.isUriAllowed policy.',
      );
    }

    if (!forceRefresh) {
      final cached = _pageCache[pageIdOrEndpoint];
      if (cached != null && !cached.isExpired(DateTime.now())) {
        return cached.page;
      }
    }

    final customFetcher = config.pageJsonFetcher;
    if (customFetcher != null) {
      final rawJson = await customFetcher(
        pageIdOrEndpoint,
        forceRefresh: forceRefresh,
      );
      final page = await parsePage(rawJson);
      _cachePage(pageIdOrEndpoint, page);
      return page;
    }

    final networking = _networkingApi;
    if (networking == null) {
      throw StateError(
        'Cannot fetchPage("$pageIdOrEndpoint"): neither '
        'CmsConfig.pageJsonFetcher nor NetworkingApi is registered in Fluent.',
      );
    }

    final result = await networking.get<dynamic>(
      pageIdOrEndpoint,
      cacheConfig: CacheConfig(forceRefresh: forceRefresh),
    );

    switch (result) {
      case Success<dynamic>(:final data):
        final CmsPage page;
        if (data is String) {
          page = await parsePage(data);
        } else if (data is Map<String, dynamic>) {
          page = CmsPage.fromJson(data);
        } else if (data is Map) {
          final normalized = <String, dynamic>{};
          for (final entry in data.entries) {
            if (entry.key != null) {
              normalized[entry.key.toString()] = entry.value;
            }
          }
          page = CmsPage.fromJson(normalized);
        } else {
          page = await parsePage(jsonEncode(data));
        }
        _cachePage(pageIdOrEndpoint, page);
        return page;

      case Failure<dynamic>(:final error):
        _logger?.logError(
          '[fluent_cms] Failed to fetch page "$pageIdOrEndpoint": '
          '${error.message} (code=${error.code})',
        );
        throw StateError(
          'Failed to fetch CMS page "$pageIdOrEndpoint": ${error.message}',
        );
    }
  }

  void _cachePage(String key, CmsPage page) {
    final now = DateTime.now();
    _pageCache[key] = _CachedPageEntry(page: page, cachedAt: now);
    if (page.pageId.isNotEmpty) {
      _pageCache[page.pageId] = _CachedPageEntry(page: page, cachedAt: now);
    }
  }

  @override
  void clearCache() {
    _pageCache.clear();
  }

  @override
  ValueListenable<bool> get debugZoneBordersEnabled => _debugBordersNotifier;

  @override
  void toggleDebugZoneBorders() {
    if (!const bool.fromEnvironment('dart.vm.product')) {
      _debugBordersNotifier.value = !_debugBordersNotifier.value;
    }
  }

  @override
  Map<String, dynamic> exportJsonSchema() {
    return CmsJsonSchemaGenerator.generate(
      modules: _moduleRegistry.registeredModules,
    );
  }
}
