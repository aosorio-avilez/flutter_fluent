import 'dart:async';

import 'package:fluent_cms/src/actions/cms_action_engine.dart';
import 'package:fluent_cms/src/api/cms_api_impl.dart';
import 'package:fluent_cms/src/hydration/async_data_source_manager.dart';
import 'package:fluent_cms/src/widgets/cms_page_controller.dart';
import 'package:fluent_cms/src/widgets/responsive_zone_layout.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';

/// Primary omnichannel SDUI page renderer built on top of `CustomScrollView`
/// and `Slivers`.
///
/// Supports:
/// - Tier 1 (`NoOpHydrationEngine` — Zero Hydration) and Tier 2/3
///   (`MixedHydrationEngine`).
/// - Responsive `single_column` (Mobile) and `grid_12_cols` (Tablet/Desktop)
///   layouts from a single JSON contract.
/// - `pinned` header zones (`PinnedHeaderSliver`) and `stickyBottom` bars.
/// - Native `Pull-to-Refresh` (`RefreshIndicator`), `refreshOnAppResume`, and
///   `preserveStateOnRefresh`.
/// - Programmatic & declarative `scrollToModule` and `modal_zone` bottom
///   sheets.
class CmsPageView extends StatefulWidget {
  /// Creates a [CmsPageView] from an in-memory [page] or remote [pageEndpoint].
  const CmsPageView({
    this.page,
    this.pageEndpoint,
    this.cmsApi,
    this.controller,
    this.hydrate,
    this.clientContext = const <String, dynamic>{},
    this.featureFlagLookup,
    this.breakpointOverride,
    this.platformOverride,
    this.refreshOnAppResume = false,
    this.loadingWidget,
    this.errorBuilder,
    this.onRefresh,
    super.key,
  }) : assert(
         page != null || pageEndpoint != null,
         'Either page or pageEndpoint must be provided to CmsPageView.',
       );

  /// Pre-parsed [CmsPage] AST to render immediately.
  final CmsPage? page;

  /// Optional endpoint or page identifier fetched via `CmsApi.fetchPage`.
  final String? pageEndpoint;

  /// Optional explicit [CmsApiImpl] instance (falls back to
  /// `Fluent.get<CmsApi>()` when registered).
  final CmsApiImpl? cmsApi;

  /// Optional controller for programmatic scroll, state access, and refresh.
  final CmsPageController? controller;

  /// Optional per-page hydration override (`false` -> `NoOpHydrationEngine`,
  /// `true` -> `MixedHydrationEngine`).
  final bool? hydrate;

  /// Client-side context map exposed under `{{client.*}}`.
  final Map<String, dynamic> clientContext;

  /// Optional feature flag lookup callback exposed under `{{env.features.*}}`.
  final FeatureFlagLookup? featureFlagLookup;

  /// Optional responsive breakpoint override (useful for omnichannel preview).
  final CmsBreakpoint? breakpointOverride;

  /// Optional platform name override (`'android'`, `'ios'`, `'web'`, etc.).
  final String? platformOverride;

  /// Whether to automatically refresh the page when the app returns to the
  /// foreground (`AppLifecycleState.resumed`).
  final bool refreshOnAppResume;

  /// Optional widget displayed while [pageEndpoint] is loading initially.
  final Widget? loadingWidget;

  /// Optional builder displayed when [pageEndpoint] fails to load.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Optional callback invoked during Pull-to-Refresh.
  final Future<void> Function()? onRefresh;

  @override
  State<CmsPageView> createState() => _CmsPageViewState();
}

class _CmsPageViewState extends State<CmsPageView> with WidgetsBindingObserver {
  late CmsApiImpl _cmsApi;
  late CmsPageController _controller;
  late bool _ownsController;
  CmsActionEngine? _actionEngine;
  AsyncDataSourceManager? _asyncManager;

  CmsPage? _activePage;
  Object? _loadError;
  bool _isLoadingPage = false;

  @override
  void initState() {
    super.initState();
    if (widget.refreshOnAppResume) {
      WidgetsBinding.instance.addObserver(this);
    }
    _resolveDependencies();
    _initializePage();
  }

  @override
  void didUpdateWidget(covariant CmsPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshOnAppResume != widget.refreshOnAppResume) {
      if (widget.refreshOnAppResume) {
        WidgetsBinding.instance.addObserver(this);
      } else {
        WidgetsBinding.instance.removeObserver(this);
      }
    }

    if (oldWidget.controller != widget.controller ||
        oldWidget.cmsApi != widget.cmsApi) {
      _cleanupEngines();
      if (_ownsController) {
        _controller.dispose();
      }
      _resolveDependencies();
      _initializePage();
      return;
    }

    if (oldWidget.page != widget.page ||
        oldWidget.pageEndpoint != widget.pageEndpoint ||
        oldWidget.hydrate != widget.hydrate) {
      _initializePage();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.refreshOnAppResume && state == AppLifecycleState.resumed) {
      unawaited(handleRefresh());
    }
  }

  void _resolveDependencies() {
    if (widget.cmsApi != null) {
      _cmsApi = widget.cmsApi!;
    } else {
      try {
        final registered = Fluent.get<CmsApi>();
        _cmsApi = registered is CmsApiImpl ? registered : CmsApiImpl();
      } on Object {
        _cmsApi = CmsApiImpl();
      }
    }

    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = CmsPageController();
      _ownsController = true;
    }
    _controller.attachRefreshHandler(handleRefresh);
  }

  void _initializePage() {
    if (widget.page != null) {
      _activePage = widget.page;
      _loadError = null;
      _isLoadingPage = false;
      _configurePageEngines(widget.page!);
      return;
    }

    final endpoint = widget.pageEndpoint;
    if (endpoint != null) {
      _activePage = null;
      _isLoadingPage = true;
      _loadError = null;
      unawaited(_fetchRemotePage(endpoint, forceRefresh: false));
    }
  }

  Future<void> _fetchRemotePage(
    String endpoint, {
    required bool forceRefresh,
  }) async {
    try {
      final loaded = await _cmsApi.fetchPage(
        endpoint,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _activePage = loaded;
        _isLoadingPage = false;
        _loadError = null;
        _configurePageEngines(loaded);
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoadingPage = false;
      });
    }
  }

  HydrationEngine _selectHydrationEngine(CmsPage page) {
    final explicit = widget.hydrate;
    if (explicit != null) {
      return explicit
          ? _cmsApi.mixedHydrationEngine
          : const NoOpHydrationEngine();
    }
    if (_cmsApi.config.hydrationEngine != null || _cmsApi.config.hydrate) {
      return _cmsApi.hydrationEngine;
    }
    if ((page.dataContext != null && page.dataContext!.isNotEmpty) ||
        (page.asyncSources != null && page.asyncSources!.isNotEmpty)) {
      return _cmsApi.mixedHydrationEngine;
    }
    return const NoOpHydrationEngine();
  }

  void _configurePageEngines(CmsPage page) {
    _actionEngine?.dispose();
    _asyncManager?.dispose();

    final hydrationEngine = _selectHydrationEngine(page);
    _asyncManager = _cmsApi.createAsyncManager(page.asyncSources);
    if (page.asyncSources != null && page.asyncSources!.isNotEmpty) {
      unawaited(_asyncManager!.prefetchAll());
    }

    _actionEngine = CmsActionEngine(
      pageId: page.pageId,
      pageStore: _controller.pageStore,
      config: _cmsApi.config,
      hydrationEngine: hydrationEngine,
      commandHandlers: _cmsApi.commandHandlers,
      observers: _cmsApi.actionObservers,
      onScrollToModule: (targetId, payload) {
        return _controller.scrollToModule(targetId);
      },
      onShowModalZone: (targetZoneId, payload) async {
        if (!mounted) return false;
        final modalZone = _activePage?.zones[targetZoneId];
        if (modalZone == null) return false;

        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (sheetCtx) {
            return SafeArea(
              child: SingleChildScrollView(
                child: CmsZoneBoxWidget(
                  zoneId: targetZoneId,
                  zone: modalZone,
                  breakpoint: widget.breakpointOverride ?? CmsBreakpoint.mobile,
                  moduleRegistry: _cmsApi.moduleRegistry,
                  hydrationEngine: hydrationEngine,
                  baseScope: _buildBaseScope(page),
                  controller: _controller,
                  actionEngine: _actionEngine!,
                  themeTokenResolver: _cmsApi.themeTokenResolver,
                  config: _cmsApi.config,
                  asyncManager: _asyncManager,
                  asyncDataSource: _cmsApi.asyncDataSource,
                  debugZoneBordersListenable: _cmsApi.debugZoneBordersEnabled,
                  platformOverride: widget.platformOverride,
                ),
              ),
            );
          },
        );
        return true;
      },
    );
  }

  /// Refreshes the page and its `asyncSources`, preserving user-mutated keys in
  /// `PageScopedReactiveStore` when `preserveStateOnRefresh` is `true`.
  Future<void> handleRefresh() async {
    if (!mounted) return;
    final currentPage = _activePage;
    if (currentPage != null) {
      _controller.pageStore.clear(
        preserveUserState: currentPage.preserveStateOnRefresh,
      );
    }

    if (widget.onRefresh != null) {
      await widget.onRefresh!();
      if (!mounted) return;
    }

    final endpoint = widget.pageEndpoint;
    if (endpoint != null) {
      await _fetchRemotePage(endpoint, forceRefresh: true);
      if (!mounted) return;
    } else if (_asyncManager != null) {
      await _asyncManager!.prefetchAll(forceRefresh: true);
    }
  }

  FeatureFlagLookup _resolveFeatureFlagLookup() {
    if (widget.featureFlagLookup != null) {
      return widget.featureFlagLookup!;
    }
    return (flagKey) {
      try {
        return Fluent.get<EnvironmentApi>().isFeatureEnabled(flagKey);
      } on Object {
        return false;
      }
    };
  }

  HydrationScope _buildBaseScope(CmsPage page) {
    return HydrationScope(
      dataContext: page.dataContext ?? const <String, dynamic>{},
      clientContext: widget.clientContext,
      asyncData:
          _asyncManager?.resolvedDataMap ??
          const <String, Map<String, dynamic>>{},
      featureFlagLookup: _resolveFeatureFlagLookup(),
    );
  }

  void _cleanupEngines() {
    _actionEngine?.dispose();
    _actionEngine = null;
    _asyncManager?.dispose();
    _asyncManager = null;
  }

  @override
  void dispose() {
    if (widget.refreshOnAppResume) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _controller.attachRefreshHandler(null);
    _cleanupEngines();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPage && _activePage == null) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator.adaptive());
    }

    final error = _loadError;
    if (error != null && _activePage == null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, error);
      }
      return const SizedBox.shrink();
    }

    final page = _activePage;
    final actionEngine = _actionEngine;
    if (page == null || actionEngine == null) {
      return const SizedBox.shrink();
    }

    final hydrationEngine = _selectHydrationEngine(page);
    final baseScope = _buildBaseScope(page);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final breakpoint =
            widget.breakpointOverride ??
            ResponsiveZoneLayout.resolveBreakpoint(maxWidth, _cmsApi.config);

        final slivers = ResponsiveZoneLayout.buildSlivers(
          context: context,
          page: page,
          breakpoint: breakpoint,
          viewportWidth: maxWidth,
          moduleRegistry: _cmsApi.moduleRegistry,
          hydrationEngine: hydrationEngine,
          baseScope: baseScope,
          controller: _controller,
          actionEngine: actionEngine,
          themeTokenResolver: _cmsApi.themeTokenResolver,
          config: _cmsApi.config,
          asyncManager: _asyncManager,
          asyncDataSource: _cmsApi.asyncDataSource,
          debugZoneBordersListenable: _cmsApi.debugZoneBordersEnabled,
          platformOverride: widget.platformOverride,
        );

        Widget scrollView = CustomScrollView(
          controller: _controller.scrollController,
          physics: page.refreshable
              ? const AlwaysScrollableScrollPhysics()
              : null,
          slivers: slivers,
        );

        if (page.refreshable) {
          scrollView = RefreshIndicator(
            onRefresh: handleRefresh,
            child: scrollView,
          );
        }

        final stickyBottomEntries =
            ResponsiveZoneLayout.collectStickyBottomZones(page);
        if (stickyBottomEntries.isEmpty) {
          return scrollView;
        }

        final stickyChildren = <Widget>[];
        for (var i = 0; i < stickyBottomEntries.length; i++) {
          final entry = stickyBottomEntries[i];
          stickyChildren.add(
            CmsZoneBoxWidget(
              zoneId: entry.key,
              zone: entry.value,
              breakpoint: breakpoint,
              moduleRegistry: _cmsApi.moduleRegistry,
              hydrationEngine: hydrationEngine,
              baseScope: baseScope,
              controller: _controller,
              actionEngine: actionEngine,
              themeTokenResolver: _cmsApi.themeTokenResolver,
              config: _cmsApi.config,
              asyncManager: _asyncManager,
              asyncDataSource: _cmsApi.asyncDataSource,
              availableWidth: maxWidth,
              debugZoneBordersListenable: _cmsApi.debugZoneBordersEnabled,
              platformOverride: widget.platformOverride,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: scrollView),
            Material(
              elevation: 4,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: stickyChildren,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
