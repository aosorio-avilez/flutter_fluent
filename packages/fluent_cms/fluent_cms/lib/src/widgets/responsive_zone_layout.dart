import 'package:fluent_cms/src/actions/cms_action_engine.dart';
import 'package:fluent_cms/src/cms_config.dart';
import 'package:fluent_cms/src/hydration/async_data_source_manager.dart';
import 'package:fluent_cms/src/hydration/mixed_hydration_engine.dart';
import 'package:fluent_cms/src/registry/cms_module_registry.dart';
import 'package:fluent_cms/src/theme/theme_token_resolver.dart';
import 'package:fluent_cms/src/widgets/cms_page_controller.dart';
import 'package:fluent_cms/src/widgets/module_wrapper_widget.dart';
import 'package:fluent_cms/src/widgets/repeater_module.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Renders a single [ContentZone] as a box widget (used inside `grid_12_cols`
/// columns, `pinned` headers, `stickyBottom` bars, and `modal_zone` sheets).
class CmsZoneBoxWidget extends StatelessWidget {
  /// Creates a [CmsZoneBoxWidget].
  const CmsZoneBoxWidget({
    required this.zoneId,
    required this.zone,
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
    this.availableWidth,
    this.debugZoneBordersListenable,
    this.platformOverride,
    super.key,
  });

  /// Identifier of the zone.
  final String zoneId;

  /// AST zone definition.
  final ContentZone zone;

  /// Active screen breakpoint.
  final CmsBreakpoint breakpoint;

  /// Module registry.
  final CmsModuleRegistry moduleRegistry;

  /// Active hydration engine.
  final HydrationEngine hydrationEngine;

  /// Base hydration scope.
  final HydrationScope baseScope;

  /// Page controller.
  final CmsPageController controller;

  /// Action engine.
  final CmsActionEngine actionEngine;

  /// Semantic design token resolver.
  final ThemeTokenResolver themeTokenResolver;

  /// Global CMS configuration.
  final CmsConfig config;

  /// Optional async data source manager.
  final AsyncDataSourceManager? asyncManager;

  /// Optional async data source for pagination.
  final AsyncDataSource? asyncDataSource;

  /// Optional logger.
  final LoggerApi? logger;

  /// Available horizontal width for this zone.
  final double? availableWidth;

  /// Optional listenable controlling diagnostic zone borders.
  final ValueListenable<bool>? debugZoneBordersListenable;

  /// Optional platform override.
  final String? platformOverride;

  Listenable? _buildZoneVisibilityListenable() {
    final expr = zone.visibleWhen;
    final engine = hydrationEngine;
    if (expr == null || expr.isEmpty || engine is! MixedHydrationEngine) {
      return null;
    }
    final keys = engine.extractStateKeys(
      const <String, dynamic>{},
      visibleWhen: expr,
    );
    if (keys.isEmpty) return null;
    final listenables = <Listenable>[];
    for (final key in keys) {
      listenables.add(controller.pageStore.listenKey(key));
    }
    return Listenable.merge(listenables);
  }

  @override
  Widget build(BuildContext context) {
    final visibilityListenable = _buildZoneVisibilityListenable();
    if (visibilityListenable != null) {
      return ListenableBuilder(
        listenable: visibilityListenable,
        builder: (context, _) => _buildZoneContent(context),
      );
    }
    return _buildZoneContent(context);
  }

  Widget _buildZoneContent(BuildContext context) {
    final currentScope = baseScope.copyWith(
      stateValues: controller.pageStore.toMap(),
      asyncData: asyncManager?.resolvedDataMap ?? baseScope.asyncData,
    );
    if (!hydrationEngine.evaluateCondition(zone.visibleWhen, currentScope)) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    final modules = zone.modules;
    final len = modules.length;
    for (var i = 0; i < len; i++) {
      final moduleNode = modules[i];
      if (moduleNode.type == RepeaterModule.moduleType) {
        children.add(
          CmsRepeaterWidget(
            key: ValueKey<String>('cms_zone_${zoneId}_rep_${moduleNode.id}'),
            node: moduleNode,
            zoneId: zoneId,
            breakpoint: breakpoint,
            moduleRegistry: moduleRegistry,
            hydrationEngine: hydrationEngine,
            baseScope: baseScope,
            controller: controller,
            actionEngine: actionEngine,
            themeTokenResolver: themeTokenResolver,
            config: config,
            asyncManager: asyncManager,
            asyncDataSource: asyncDataSource,
            logger: logger,
            availableWidth: availableWidth,
            platformOverride: platformOverride,
          ),
        );
      } else {
        children.add(
          ModuleWrapperWidget(
            key: ValueKey<String>('cms_zone_${zoneId}_mod_${moduleNode.id}'),
            node: moduleNode,
            zoneId: zoneId,
            breakpoint: breakpoint,
            moduleRegistry: moduleRegistry,
            hydrationEngine: hydrationEngine,
            baseScope: baseScope,
            controller: controller,
            actionEngine: actionEngine,
            themeTokenResolver: themeTokenResolver,
            config: config,
            asyncManager: asyncManager,
            logger: logger,
            availableWidth: availableWidth,
            isPinnedZone: zone.pinned,
            isStickyBottomZone: zone.stickyBottom,
            platformOverride: platformOverride,
          ),
        );
      }
    }

    final padding = themeTokenResolver.resolveEdgeInsets(
      zone.padding,
      context: context,
    );

    Widget content = Column(
      key: controller.keyForZone(zoneId),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    if (padding != null && padding != EdgeInsets.zero) {
      content = Padding(padding: padding, child: content);
    }

    final debugListenable = debugZoneBordersListenable;
    if (!const bool.fromEnvironment('dart.vm.product') &&
        debugListenable != null) {
      return ValueListenableBuilder<bool>(
        valueListenable: debugListenable,
        builder: (context, showBorders, child) {
          if (!showBorders) return child!;
          return _DebugZoneBorder(zoneId: zoneId, child: child!);
        },
        child: content,
      );
    }

    return content;
  }
}

/// Builds the Sliver list for a `CmsPage` according to the active
/// [CmsBreakpoint] (`single_column` Slivers on Mobile vs `grid_12_cols`
/// multi-column layout on Tablet/Desktop).
class ResponsiveZoneLayout {
  /// Creates a [ResponsiveZoneLayout].
  const ResponsiveZoneLayout._();

  /// Resolves the active [CmsBreakpoint] for [maxWidth] using [config].
  static CmsBreakpoint resolveBreakpoint(
    double maxWidth,
    CmsConfig config,
  ) {
    return CmsBreakpoint.fromWidth(
      maxWidth,
      mobileMaxWidth: config.mobileMaxWidth,
      tabletMaxWidth: config.tabletMaxWidth,
    );
  }

  /// Collects all `stickyBottom: true` zones that should be anchored at the
  /// bottom of the viewport outside the scroll view.
  static List<MapEntry<String, ContentZone>> collectStickyBottomZones(
    CmsPage page,
  ) {
    final result = <MapEntry<String, ContentZone>>[];
    for (final entry in page.zones.entries) {
      if (entry.value.stickyBottom) {
        result.add(entry);
      }
    }
    return result;
  }

  /// Builds the list of Slivers for `CustomScrollView.slivers` without closure
  /// allocations.
  static List<Widget> buildSlivers({
    required BuildContext context,
    required CmsPage page,
    required CmsBreakpoint breakpoint,
    required double viewportWidth,
    required CmsModuleRegistry moduleRegistry,
    required HydrationEngine hydrationEngine,
    required HydrationScope baseScope,
    required CmsPageController controller,
    required CmsActionEngine actionEngine,
    required ThemeTokenResolver themeTokenResolver,
    CmsConfig config = const CmsConfig(),
    AsyncDataSourceManager? asyncManager,
    AsyncDataSource? asyncDataSource,
    LoggerApi? logger,
    ValueListenable<bool>? debugZoneBordersListenable,
    String? platformOverride,
  }) {
    final breakpointLayout = page.layout.resolveForBreakpoint(breakpoint);
    final layoutType = breakpointLayout.type.toLowerCase();
    final gridColumns = breakpointLayout.columns;

    if (layoutType == 'grid_12_cols' &&
        gridColumns != null &&
        gridColumns.isNotEmpty) {
      return _buildGrid12ColsSlivers(
        context: context,
        page: page,
        columns: gridColumns,
        breakpoint: breakpoint,
        viewportWidth: viewportWidth,
        moduleRegistry: moduleRegistry,
        hydrationEngine: hydrationEngine,
        baseScope: baseScope,
        controller: controller,
        actionEngine: actionEngine,
        themeTokenResolver: themeTokenResolver,
        config: config,
        asyncManager: asyncManager,
        asyncDataSource: asyncDataSource,
        logger: logger,
        debugZoneBordersListenable: debugZoneBordersListenable,
        platformOverride: platformOverride,
      );
    }

    final orderedZoneIds = <String>[];
    final explicitOrder = breakpointLayout.zonesOrder;
    if (explicitOrder != null && explicitOrder.isNotEmpty) {
      for (var i = 0; i < explicitOrder.length; i++) {
        orderedZoneIds.add(explicitOrder[i]);
      }
    } else {
      orderedZoneIds.addAll(page.zones.keys);
    }

    final slivers = <Widget>[];
    for (var i = 0; i < orderedZoneIds.length; i++) {
      final zoneId = orderedZoneIds[i];
      final zone = page.zones[zoneId];
      if (zone == null || zone.stickyBottom) continue;

      if (zone.pinned) {
        slivers.add(
          PinnedHeaderSliver(
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: CmsZoneBoxWidget(
                zoneId: zoneId,
                zone: zone,
                breakpoint: breakpoint,
                moduleRegistry: moduleRegistry,
                hydrationEngine: hydrationEngine,
                baseScope: baseScope,
                controller: controller,
                actionEngine: actionEngine,
                themeTokenResolver: themeTokenResolver,
                config: config,
                asyncManager: asyncManager,
                asyncDataSource: asyncDataSource,
                logger: logger,
                availableWidth: viewportWidth,
                debugZoneBordersListenable: debugZoneBordersListenable,
                platformOverride: platformOverride,
              ),
            ),
          ),
        );
        continue;
      }

      // Single-column Sliver zone
      final hasSingleRepeaterOnly =
          zone.modules.length == 1 &&
          zone.modules[0].type == RepeaterModule.moduleType &&
          zone.visibleWhen == null;

      if (hasSingleRepeaterOnly) {
        final padding = themeTokenResolver.resolveEdgeInsets(
          zone.padding,
          context: context,
        );
        Widget repeaterSliver = CmsRepeaterWidget(
          key: ValueKey<String>(
            'cms_sliver_rep_${zoneId}_${zone.modules[0].id}',
          ),
          node: zone.modules[0],
          zoneId: zoneId,
          breakpoint: breakpoint,
          moduleRegistry: moduleRegistry,
          hydrationEngine: hydrationEngine,
          baseScope: baseScope,
          controller: controller,
          actionEngine: actionEngine,
          themeTokenResolver: themeTokenResolver,
          config: config,
          asyncManager: asyncManager,
          asyncDataSource: asyncDataSource,
          logger: logger,
          asSliver: true,
          availableWidth: viewportWidth,
          platformOverride: platformOverride,
        );
        if (padding != null && padding != EdgeInsets.zero) {
          repeaterSliver = SliverPadding(
            padding: padding,
            sliver: repeaterSliver,
          );
        }
        slivers.add(repeaterSliver);
      } else {
        slivers.add(
          SliverToBoxAdapter(
            child: CmsZoneBoxWidget(
              zoneId: zoneId,
              zone: zone,
              breakpoint: breakpoint,
              moduleRegistry: moduleRegistry,
              hydrationEngine: hydrationEngine,
              baseScope: baseScope,
              controller: controller,
              actionEngine: actionEngine,
              themeTokenResolver: themeTokenResolver,
              config: config,
              asyncManager: asyncManager,
              asyncDataSource: asyncDataSource,
              logger: logger,
              availableWidth: viewportWidth,
              debugZoneBordersListenable: debugZoneBordersListenable,
              platformOverride: platformOverride,
            ),
          ),
        );
      }
    }

    return slivers;
  }

  static List<Widget> _buildGrid12ColsSlivers({
    required BuildContext context,
    required CmsPage page,
    required List<ColumnSpanConfig> columns,
    required CmsBreakpoint breakpoint,
    required double viewportWidth,
    required CmsModuleRegistry moduleRegistry,
    required HydrationEngine hydrationEngine,
    required HydrationScope baseScope,
    required CmsPageController controller,
    required CmsActionEngine actionEngine,
    required ThemeTokenResolver themeTokenResolver,
    required CmsConfig config,
    AsyncDataSourceManager? asyncManager,
    AsyncDataSource? asyncDataSource,
    LoggerApi? logger,
    ValueListenable<bool>? debugZoneBordersListenable,
    String? platformOverride,
  }) {
    // Group columns into rows of up to 12 spans.
    final rows = <List<ColumnSpanConfig>>[];
    var currentRow = <ColumnSpanConfig>[];
    var currentSpanSum = 0;

    for (var i = 0; i < columns.length; i++) {
      final col = columns[i];
      final clampedSpan = col.span.clamp(1, 12);
      if (currentSpanSum + clampedSpan > 12 && currentRow.isNotEmpty) {
        rows.add(currentRow);
        currentRow = <ColumnSpanConfig>[];
        currentSpanSum = 0;
      }
      currentRow.add(col);
      currentSpanSum += clampedSpan;
    }
    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    final slivers = <Widget>[];
    for (var r = 0; r < rows.length; r++) {
      final rowCols = rows[r];

      // If a full-width (span 12) single column contains a single pinned zone,
      // preserve PinnedHeaderSliver behavior even in grid_12_cols!
      if (rowCols.length == 1 &&
          rowCols[0].span >= 12 &&
          rowCols[0].zones.length == 1) {
        final singleZoneId = rowCols[0].zones[0];
        final singleZone = page.zones[singleZoneId];
        if (singleZone != null &&
            singleZone.pinned &&
            !singleZone.stickyBottom) {
          slivers.add(
            PinnedHeaderSliver(
              child: Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: CmsZoneBoxWidget(
                  zoneId: singleZoneId,
                  zone: singleZone,
                  breakpoint: breakpoint,
                  moduleRegistry: moduleRegistry,
                  hydrationEngine: hydrationEngine,
                  baseScope: baseScope,
                  controller: controller,
                  actionEngine: actionEngine,
                  themeTokenResolver: themeTokenResolver,
                  config: config,
                  asyncManager: asyncManager,
                  asyncDataSource: asyncDataSource,
                  logger: logger,
                  availableWidth: viewportWidth,
                  debugZoneBordersListenable: debugZoneBordersListenable,
                  platformOverride: platformOverride,
                ),
              ),
            ),
          );
          continue;
        }
      }

      final rowChildren = <Widget>[];
      for (var c = 0; c < rowCols.length; c++) {
        final col = rowCols[c];
        final span = col.span.clamp(1, 12);
        final colWidth = viewportWidth * (span / 12.0);
        final zoneWidgets = <Widget>[];

        for (var z = 0; z < col.zones.length; z++) {
          final zoneId = col.zones[z];
          final zone = page.zones[zoneId];
          if (zone == null || zone.stickyBottom) continue;

          zoneWidgets.add(
            CmsZoneBoxWidget(
              zoneId: zoneId,
              zone: zone,
              breakpoint: breakpoint,
              moduleRegistry: moduleRegistry,
              hydrationEngine: hydrationEngine,
              baseScope: baseScope,
              controller: controller,
              actionEngine: actionEngine,
              themeTokenResolver: themeTokenResolver,
              config: config,
              asyncManager: asyncManager,
              asyncDataSource: asyncDataSource,
              logger: logger,
              availableWidth: colWidth,
              debugZoneBordersListenable: debugZoneBordersListenable,
              platformOverride: platformOverride,
            ),
          );
        }

        if (c > 0) {
          rowChildren.add(const SizedBox(width: 16));
        }
        rowChildren.add(
          Expanded(
            flex: span,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: zoneWidgets,
            ),
          ),
        );
      }

      slivers.add(
        SliverToBoxAdapter(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
    }

    return slivers;
  }
}

class _DebugZoneBorder extends StatelessWidget {
  const _DebugZoneBorder({
    required this.zoneId,
    required this.child,
  });

  final String zoneId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF7B61FF),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          child,
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                color: const Color(0xCC7B61FF),
                child: Text(
                  'zone:$zoneId',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
