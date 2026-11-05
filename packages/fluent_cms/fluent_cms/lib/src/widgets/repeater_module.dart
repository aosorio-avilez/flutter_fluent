import 'dart:async';

import 'package:fluent_cms/src/actions/cms_action_engine.dart';
import 'package:fluent_cms/src/cms_config.dart';
import 'package:fluent_cms/src/hydration/async_data_source_manager.dart';
import 'package:fluent_cms/src/hydration/condition_evaluator.dart';
import 'package:fluent_cms/src/registry/cms_module_registry.dart';
import 'package:fluent_cms/src/theme/theme_token_resolver.dart';
import 'package:fluent_cms/src/widgets/cms_page_controller.dart';
import 'package:fluent_cms/src/widgets/module_wrapper_widget.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter/material.dart';

/// Structural [SduiModule] registered under `'cms_repeater'` for rendering
/// lazy lists and grids from an `itemTemplate` and `itemsDataPath`.
class RepeaterModule extends SduiModule {
  /// Creates a [RepeaterModule].
  const RepeaterModule();

  /// Canonical module type key for the repeater.
  static const String moduleType = 'cms_repeater';

  @override
  String get type => moduleType;

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    // Fallback box representation when invoked via SduiModule.build directly.
    final rawConfig = moduleContext.props.raw;
    final config = RepeaterConfig.fromJson(rawConfig);
    return Text(
      'cms_repeater(${config.itemsDataPath})',
      key: ValueKey<String>('cms_repeater_fallback_${moduleContext.moduleId}'),
    );
  }
}

/// Renders a `cms_repeater` [ModuleNode] either as a native Sliver
/// (`SliverList.builder` / `SliverGrid.builder`) or as a shrink-wrapped box
/// (`ListView.builder` / `GridView.builder`) with incremental pagination.
class CmsRepeaterWidget extends StatefulWidget {
  /// Creates a [CmsRepeaterWidget].
  const CmsRepeaterWidget({
    required this.node,
    required this.zoneId,
    required this.breakpoint,
    required this.moduleRegistry,
    required this.hydrationEngine,
    required this.baseScope,
    required this.controller,
    required this.actionEngine,
    required this.themeTokenResolver,
    this.config = const CmsConfig(),
    this.asyncManager,
    this.asyncDataSource,
    this.logger,
    this.asSliver = false,
    this.availableWidth,
    this.platformOverride,
    super.key,
  });

  /// Repeater [ModuleNode].
  final ModuleNode node;

  /// Containing `ContentZone` identifier.
  final String zoneId;

  /// Active responsive breakpoint.
  final CmsBreakpoint breakpoint;

  /// Module registry.
  final CmsModuleRegistry moduleRegistry;

  /// Active hydration engine.
  final HydrationEngine hydrationEngine;

  /// Base hydration scope (`data.*`, `client.*`, `state.*`, `async.*`).
  final HydrationScope baseScope;

  /// Page controller.
  final CmsPageController controller;

  /// Action engine.
  final CmsActionEngine actionEngine;

  /// Semantic design token resolver.
  final ThemeTokenResolver themeTokenResolver;

  /// Global CMS configuration.
  final CmsConfig config;

  /// Optional page-scoped async source manager.
  final AsyncDataSourceManager? asyncManager;

  /// Optional [AsyncDataSource] used for incremental pagination requests.
  final AsyncDataSource? asyncDataSource;

  /// Optional logger.
  final LoggerApi? logger;

  /// Whether to return a Sliver (`SliverList.builder` / `SliverGrid.builder`)
  /// instead of a box widget.
  final bool asSliver;

  /// Available width in the zone.
  final double? availableWidth;

  /// Optional platform override.
  final String? platformOverride;

  @override
  State<CmsRepeaterWidget> createState() => _CmsRepeaterWidgetState();
}

class _CmsRepeaterWidgetState extends State<CmsRepeaterWidget> {
  late RepeaterConfig _repeaterConfig;
  final List<Map<String, dynamic>> _paginatedExtraItems =
      <Map<String, dynamic>>[];
  int _currentPage = 1;
  bool _isLoadingNextPage = false;
  bool _hasReachedEnd = false;
  Listenable? _stateListenable;

  @override
  void initState() {
    super.initState();
    _parseConfig();
  }

  @override
  void didUpdateWidget(covariant CmsRepeaterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node != widget.node ||
        oldWidget.breakpoint != widget.breakpoint ||
        oldWidget.controller != widget.controller) {
      _parseConfig();
    }
  }

  void _parseConfig() {
    final rawProps = widget.node.resolvePropsForBreakpoint(widget.breakpoint);
    _repeaterConfig = RepeaterConfig.fromJson(rawProps);
    final path = _repeaterConfig.itemsDataPath.trim();
    if (path.startsWith('state.')) {
      final sub = path.substring(6);
      final dotIdx = sub.indexOf('.');
      final topKey = dotIdx == -1 ? sub : sub.substring(0, dotIdx);
      _stateListenable = widget.controller.pageStore.listenKey(topKey);
    } else {
      _stateListenable = null;
    }
  }

  HydrationScope _currentScope() {
    return widget.baseScope.copyWith(
      stateValues: widget.controller.pageStore.toMap(),
      asyncData:
          widget.asyncManager?.resolvedDataMap ?? widget.baseScope.asyncData,
    );
  }

  List<Map<String, dynamic>> _resolveItems(HydrationScope scope) {
    final rawList = ConditionEvaluator.resolvePath(
      _repeaterConfig.itemsDataPath,
      scope,
    );

    final result = <Map<String, dynamic>>[];
    if (rawList is List) {
      final len = rawList.length;
      for (var i = 0; i < len; i++) {
        final item = rawList[i];
        if (item is Map<String, dynamic>) {
          result.add(item);
        } else if (item is Map) {
          final normalized = <String, dynamic>{};
          for (final entry in item.entries) {
            if (entry.key != null) {
              normalized[entry.key.toString()] = entry.value;
            }
          }
          result.add(normalized);
        }
      }
    }

    final extraLen = _paginatedExtraItems.length;
    for (var i = 0; i < extraLen; i++) {
      result.add(_paginatedExtraItems[i]);
    }
    return result;
  }

  Future<void> _maybeTriggerPagination(int currentIndex, int totalCount) async {
    final pagination = _repeaterConfig.pagination;
    final dataSource = widget.asyncDataSource;
    if (pagination == null || dataSource == null) return;
    if (_isLoadingNextPage || _hasReachedEnd) return;
    if (currentIndex < totalCount - 2) return;

    _isLoadingNextPage = true;
    final nextPage = _currentPage + 1;

    try {
      final response = await dataSource.fetch(
        AsyncSource(endpoint: pagination.endpoint),
        queryParameters: <String, dynamic>{
          pagination.pageParam: nextPage,
          'pageSize': pagination.pageSize,
        },
      );
      if (!mounted) return;

      final rawItems = response['items'] ?? response['data'];
      final newItems = <Map<String, dynamic>>[];
      if (rawItems is List) {
        final len = rawItems.length;
        for (var i = 0; i < len; i++) {
          final item = rawItems[i];
          if (item is Map<String, dynamic>) {
            newItems.add(item);
          } else if (item is Map) {
            final map = <String, dynamic>{};
            for (final entry in item.entries) {
              if (entry.key != null) {
                map[entry.key.toString()] = entry.value;
              }
            }
            newItems.add(map);
          }
        }
      }

      setState(() {
        _currentPage = nextPage;
        if (newItems.isEmpty || newItems.length < pagination.pageSize) {
          _hasReachedEnd = true;
        }
        final len = newItems.length;
        for (var i = 0; i < len; i++) {
          _paginatedExtraItems.add(newItems[i]);
        }
      });
    } on Object catch (error) {
      widget.logger?.logWarning(
        '[fluent_cms] Repeater "${widget.node.id}" pagination failed on page '
        '$nextPage: $error',
      );
      if (mounted) {
        setState(() {
          _hasReachedEnd = true;
        });
      }
    } finally {
      _isLoadingNextPage = false;
    }
  }

  Widget _buildItemWidget(
    BuildContext context,
    List<Map<String, dynamic>> items,
    int index,
    HydrationScope parentScope,
  ) {
    unawaited(_maybeTriggerPagination(index, items.length));

    final itemData = items[index];
    final itemScope = parentScope.copyWith(
      itemData: itemData,
      itemIndex: index,
    );

    final template = _repeaterConfig.itemTemplate;
    final resolvedId = widget.hydrationEngine.resolveString(
      template.id,
      itemScope,
      context: context,
    );
    final effectiveId = resolvedId == template.id
        ? '${template.id}_$index'
        : resolvedId;
    final itemNode = template.copyWith(id: effectiveId);

    return ModuleWrapperWidget(
      key: ValueKey<String>('cms_rep_item_${widget.node.id}_$effectiveId'),
      node: itemNode,
      zoneId: widget.zoneId,
      breakpoint: widget.breakpoint,
      moduleRegistry: widget.moduleRegistry,
      hydrationEngine: widget.hydrationEngine,
      baseScope: itemScope,
      controller: widget.controller,
      actionEngine: widget.actionEngine,
      themeTokenResolver: widget.themeTokenResolver,
      config: widget.config,
      asyncManager: widget.asyncManager,
      logger: widget.logger,
      availableWidth: widget.availableWidth,
      platformOverride: widget.platformOverride,
    );
  }

  @override
  Widget build(BuildContext context) {
    final platformName = ModuleWrapperWidget.currentPlatformName(
      override: widget.platformOverride,
    );
    if (!widget.node.isSupportedOnPlatform(platformName)) {
      return widget.asSliver
          ? const SliverToBoxAdapter(child: SizedBox.shrink())
          : const SizedBox.shrink();
    }

    final listenable = _stateListenable;
    if (listenable != null) {
      return ListenableBuilder(
        listenable: listenable,
        builder: (context, _) => _buildRepeaterLayout(context),
      );
    }
    return _buildRepeaterLayout(context);
  }

  Widget _buildRepeaterLayout(BuildContext context) {
    final scope = _currentScope();
    if (!widget.hydrationEngine.evaluateCondition(
      widget.node.visibleWhen,
      scope,
    )) {
      return widget.asSliver
          ? const SliverToBoxAdapter(child: SizedBox.shrink())
          : const SizedBox.shrink();
    }

    final items = _resolveItems(scope);
    if (items.isEmpty) {
      return widget.asSliver
          ? const SliverToBoxAdapter(child: SizedBox.shrink())
          : const SizedBox.shrink();
    }

    final isGrid = _repeaterConfig.layoutMode.toLowerCase() == 'grid';
    final crossAxisCount = _repeaterConfig.resolveCrossAxisCount(
      widget.breakpoint,
      defaultCount: isGrid ? 2 : 1,
    );

    if (widget.asSliver) {
      if (isGrid && crossAxisCount > 1) {
        return SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _buildItemWidget(context, items, index, scope),
        );
      }

      return SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildItemWidget(context, items, index, scope),
      );
    }

    if (isGrid && crossAxisCount > 1) {
      return GridView.builder(
        key: widget.controller.keyForModule(widget.node.id),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildItemWidget(context, items, index, scope),
      );
    }

    return ListView.builder(
      key: widget.controller.keyForModule(widget.node.id),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) =>
          _buildItemWidget(context, items, index, scope),
    );
  }
}
