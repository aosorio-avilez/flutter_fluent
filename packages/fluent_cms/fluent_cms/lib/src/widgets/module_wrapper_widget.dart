import 'dart:async';

import 'package:fluent_cms/src/actions/cms_action_engine.dart';
import 'package:fluent_cms/src/cms_config.dart';
import 'package:fluent_cms/src/hydration/async_data_source_manager.dart';
import 'package:fluent_cms/src/hydration/auto_skeleton_module_wrapper.dart';
import 'package:fluent_cms/src/hydration/mixed_hydration_engine.dart';
import 'package:fluent_cms/src/registry/cms_module_registry.dart';
import 'package:fluent_cms/src/registry/fallback_module_widget.dart';
import 'package:fluent_cms/src/theme/theme_token_resolver.dart';
import 'package:fluent_cms/src/widgets/cms_page_controller.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Concrete implementation of [CmsModuleContext] passed to `SduiModule.build`.
class CmsModuleContextImpl extends CmsModuleContext {
  /// Creates a [CmsModuleContextImpl].
  CmsModuleContextImpl({
    required this.moduleId,
    required this.moduleType,
    required this.zoneId,
    required this.breakpoint,
    required this.props,
    required this.pageStore,
    required CmsActionEngine actionEngine,
    required Map<String, ActionNode>? actions,
    required HydrationScope Function() scopeProvider,
  }) : _actionEngine = actionEngine,
       _actions = actions,
       _scopeProvider = scopeProvider;

  @override
  final String moduleId;

  @override
  final String moduleType;

  @override
  final String zoneId;

  @override
  final CmsBreakpoint breakpoint;

  @override
  final CmsProps props;

  @override
  final CmsPageStore pageStore;

  final CmsActionEngine _actionEngine;
  final Map<String, ActionNode>? _actions;
  final HydrationScope Function() _scopeProvider;

  @override
  bool get isActionRunning => _actionEngine.isModuleActionRunning(moduleId);

  @override
  ValueListenable<bool> get actionRunningListenable =>
      _actionEngine.moduleRunningListenable(moduleId);

  @override
  Future<void> triggerAction(
    String trigger, {
    Map<String, dynamic>? extraPayload,
  }) async {
    final actionMap = _actions;
    if (actionMap == null) return;
    final action = actionMap[trigger];
    if (action == null) return;

    await _actionEngine.execute(
      moduleId: moduleId,
      trigger: trigger,
      action: action,
      scope: _scopeProvider(),
      extraPayload: extraPayload,
    );
  }
}

/// Wraps an individual [ModuleNode] with platform filtering, surgical reactive
/// `state.*` subscriptions, `visibleWhen`, `AutoSkeletonModuleWrapper`,
/// `responsiveProps`, error boundary (`try-catch`), declarative `Semantics`
/// (`a11y`), `keepAlive`, and real viewport `onImpression` detection.
class ModuleWrapperWidget extends StatefulWidget {
  /// Creates a [ModuleWrapperWidget].
  const ModuleWrapperWidget({
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
    this.logger,
    this.availableWidth,
    this.isPinnedZone = false,
    this.isStickyBottomZone = false,
    this.platformOverride,
    super.key,
  });

  /// AST node for this module.
  final ModuleNode node;

  /// Containing `ContentZone` identifier.
  final String zoneId;

  /// Active responsive breakpoint.
  final CmsBreakpoint breakpoint;

  /// Module registry used to look up the `SduiModule`.
  final CmsModuleRegistry moduleRegistry;

  /// Active hydration engine (`NoOpHydrationEngine` or `MixedHydrationEngine`).
  final HydrationEngine hydrationEngine;

  /// Base hydration scope (`data.*`, `client.*`, `item.*`, `index`).
  final HydrationScope baseScope;

  /// Page controller holding `pageStore`, `scrollController`, and keys.
  final CmsPageController controller;

  /// Action engine for executing declarative module actions.
  final CmsActionEngine actionEngine;

  /// Semantic design token resolver.
  final ThemeTokenResolver themeTokenResolver;

  /// Global CMS configuration.
  final CmsConfig config;

  /// Optional page-scoped async source manager.
  final AsyncDataSourceManager? asyncManager;

  /// Optional logger.
  final LoggerApi? logger;

  /// Available horizontal width in the containing zone/column.
  final double? availableWidth;

  /// Whether the containing zone is `pinned`.
  final bool isPinnedZone;

  /// Whether the containing zone is `stickyBottom`.
  final bool isStickyBottomZone;

  /// Optional platform name override (`'android'`, `'ios'`, `'web'`, etc.).
  final String? platformOverride;

  /// Resolves the active platform name string without closures.
  static String currentPlatformName({String? override}) {
    if (override != null && override.isNotEmpty) {
      return override.toLowerCase();
    }
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }

  @override
  State<ModuleWrapperWidget> createState() => _ModuleWrapperWidgetState();
}

class _ModuleWrapperWidgetState extends State<ModuleWrapperWidget>
    with AutomaticKeepAliveClientMixin<ModuleWrapperWidget> {
  Listenable? _stateSubscription;
  Timer? _impressionTimer;
  bool _hasTriggeredOnAppear = false;
  bool _isListeningToScroll = false;

  @override
  bool get wantKeepAlive => widget.node.keepAlive;

  @override
  void initState() {
    super.initState();
    _setupStateSubscriptions();
    _scheduleLifecycleChecks();
  }

  @override
  void didUpdateWidget(covariant ModuleWrapperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node != widget.node ||
        oldWidget.hydrationEngine != widget.hydrationEngine ||
        oldWidget.controller != widget.controller) {
      _setupStateSubscriptions();
    }
    if (oldWidget.node.keepAlive != widget.node.keepAlive) {
      updateKeepAlive();
    }
    _scheduleLifecycleChecks();
  }

  void _setupStateSubscriptions() {
    final engine = widget.hydrationEngine;
    if (engine is! MixedHydrationEngine) {
      _stateSubscription = null;
      return;
    }

    final mergedProps = widget.node.resolvePropsForBreakpoint(
      widget.breakpoint,
    );
    final keys = engine.extractStateKeys(
      mergedProps,
      visibleWhen: widget.node.visibleWhen,
    );

    if (keys.isEmpty) {
      _stateSubscription = null;
      return;
    }

    final listenables = <Listenable>[];
    for (final key in keys) {
      listenables.add(widget.controller.pageStore.listenKey(key));
    }
    _stateSubscription = Listenable.merge(listenables);
  }

  void _scheduleLifecycleChecks() {
    final actions = widget.node.actions;
    if (actions == null || actions.isEmpty) return;

    final hasOnAppear = actions.containsKey('onAppear');
    final hasOnImpression = actions.containsKey('onImpression');

    if (hasOnImpression && !_isListeningToScroll) {
      widget.controller.scrollController.addListener(_onScrollChanged);
      _isListeningToScroll = true;
    }

    if (hasOnAppear || hasOnImpression) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (hasOnAppear && !_hasTriggeredOnAppear) {
          _hasTriggeredOnAppear = true;
          final appearAction = actions['onAppear'];
          if (appearAction != null) {
            unawaited(
              widget.actionEngine.execute(
                moduleId: widget.node.id,
                trigger: 'onAppear',
                action: appearAction,
                scope: _buildCurrentScope(),
              ),
            );
          }
        }
        if (hasOnImpression) {
          _evaluateImpressionVisibility();
        }
      });
    }
  }

  void _onScrollChanged() {
    if (!mounted) return;
    _evaluateImpressionVisibility();
  }

  void _evaluateImpressionVisibility() {
    if (!mounted) return;
    final moduleId = widget.node.id;
    if (widget.controller.hasFiredImpression(moduleId)) {
      _cancelImpressionTimer();
      return;
    }

    final fraction = _calculateVisibleFraction();
    if (fraction >= widget.config.defaultImpressionThreshold) {
      if (_impressionTimer == null || !_impressionTimer!.isActive) {
        final duration = widget.config.defaultImpressionDuration;
        if (duration <= Duration.zero) {
          _fireImpression();
        } else {
          _impressionTimer = Timer(duration, () {
            if (!mounted || widget.controller.isDisposed) return;
            final latestFraction = _calculateVisibleFraction();
            if (latestFraction >= widget.config.defaultImpressionThreshold) {
              _fireImpression();
            }
          });
        }
      }
    } else {
      _cancelImpressionTimer();
    }
  }

  void _fireImpression() {
    if (!mounted || widget.controller.isDisposed) return;
    final moduleId = widget.node.id;
    if (widget.controller.hasFiredImpression(moduleId)) return;

    final impressionAction = widget.node.actions?['onImpression'];
    if (impressionAction == null) return;

    widget.controller.markImpressionFired(moduleId);
    unawaited(
      widget.actionEngine.execute(
        moduleId: moduleId,
        trigger: 'onImpression',
        action: impressionAction,
        scope: _buildCurrentScope(),
      ),
    );
  }

  double _calculateVisibleFraction() {
    final keyContext =
        widget.controller.keyForModule(widget.node.id).currentContext ??
        context;
    final renderObject = keyContext.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.hasSize ||
        !renderObject.attached) {
      return 0;
    }

    final size = renderObject.size;
    if (size.width <= 0 || size.height <= 0) return 0;

    final topLeft = renderObject.localToGlobal(Offset.zero);
    final bottomRight = renderObject.localToGlobal(
      Offset(size.width, size.height),
    );
    final moduleRect = Rect.fromPoints(topLeft, bottomRight);

    final mediaSize = MediaQuery.maybeSizeOf(context);
    if (mediaSize == null) return 1;
    final viewportRect = Offset.zero & mediaSize;

    final intersection = moduleRect.intersect(viewportRect);
    if (intersection.isEmpty ||
        intersection.width <= 0 ||
        intersection.height <= 0) {
      return 0;
    }

    final visibleArea = intersection.width * intersection.height;
    final totalArea = size.width * size.height;
    return (visibleArea / totalArea).clamp(0.0, 1.0);
  }

  void _cancelImpressionTimer() {
    _impressionTimer?.cancel();
    _impressionTimer = null;
  }

  HydrationScope _buildCurrentScope() {
    final storeSnapshot = widget.controller.pageStore.toMap();
    final asyncMap = widget.asyncManager?.resolvedDataMap;
    return widget.baseScope.copyWith(
      stateValues: storeSnapshot,
      asyncData: asyncMap ?? widget.baseScope.asyncData,
    );
  }

  @override
  void dispose() {
    _cancelImpressionTimer();
    if (_isListeningToScroll && !widget.controller.isDisposed) {
      widget.controller.scrollController.removeListener(_onScrollChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final platformName = ModuleWrapperWidget.currentPlatformName(
      override: widget.platformOverride,
    );
    if (!widget.node.isSupportedOnPlatform(platformName)) {
      return const SizedBox.shrink();
    }

    final listenable = _stateSubscription;
    if (listenable != null) {
      return ListenableBuilder(
        listenable: listenable,
        builder: (context, _) => _buildConditionalAndSkeleton(context),
      );
    }

    return _buildConditionalAndSkeleton(context);
  }

  Widget _buildConditionalAndSkeleton(BuildContext context) {
    final currentScope = _buildCurrentScope();
    if (!widget.hydrationEngine.evaluateCondition(
      widget.node.visibleWhen,
      currentScope,
    )) {
      return const SizedBox.shrink();
    }

    final registeredModule = widget.moduleRegistry.getModule(widget.node.type);

    return AutoSkeletonModuleWrapper(
      node: widget.node,
      module: registeredModule,
      asyncManager: widget.asyncManager,
      childBuilder: _buildModuleContent,
    );
  }

  Widget _buildModuleContent(BuildContext context) {
    final currentScope = _buildCurrentScope();
    final breakpointProps = widget.node.resolvePropsForBreakpoint(
      widget.breakpoint,
    );
    final hydratedProps = widget.hydrationEngine.resolveProps(
      breakpointProps,
      currentScope,
      context: context,
    );

    final cmsProps = CmsProps(
      hydratedProps,
      tokenLookup: widget.themeTokenResolver.resolveToken,
    );

    final moduleContext = CmsModuleContextImpl(
      moduleId: widget.node.id,
      moduleType: widget.node.type,
      zoneId: widget.zoneId,
      breakpoint: widget.breakpoint,
      props: cmsProps,
      pageStore: widget.controller.pageStore,
      actionEngine: widget.actionEngine,
      actions: widget.node.actions,
      scopeProvider: _buildCurrentScope,
    );

    Widget builtChild;
    try {
      builtChild = widget.moduleRegistry.resolveModuleWidget(
        context: context,
        node: widget.node,
        moduleContext: moduleContext,
        availableWidth: widget.availableWidth,
        isPinned: widget.isPinnedZone,
        isStickyBottom: widget.isStickyBottomZone,
      );
    } on Object catch (error, stackTrace) {
      widget.logger?.logError(
        '[fluent_cms] Module "${widget.node.id}" (type="${widget.node.type}") '
        'threw an exception during build: $error',
        stackTrace: stackTrace,
      );
      builtChild = FallbackModuleWidget(
        moduleId: widget.node.id,
        moduleType: widget.node.type,
        reason: 'Render exception: $error',
      );
    }

    builtChild = _wrapWithSemantics(context, builtChild, currentScope);

    final moduleGlobalKey = widget.controller.keyForModule(widget.node.id);
    if (widget.node.keepAlive) {
      return KeyedSubtree(
        key: PageStorageKey<String>('cms_keep_alive_${widget.node.id}'),
        child: KeyedSubtree(
          key: moduleGlobalKey,
          child: builtChild,
        ),
      );
    }

    return KeyedSubtree(
      key: moduleGlobalKey,
      child: builtChild,
    );
  }

  Widget _wrapWithSemantics(
    BuildContext context,
    Widget child,
    HydrationScope scope,
  ) {
    final a11y = widget.node.a11y;
    if (a11y == null) return child;

    if (a11y.excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    final resolvedLabel = a11y.label != null
        ? widget.hydrationEngine.resolveString(
            a11y.label!,
            scope,
            context: context,
          )
        : null;
    final resolvedHint = a11y.hint != null
        ? widget.hydrationEngine.resolveString(
            a11y.hint!,
            scope,
            context: context,
          )
        : null;

    return Semantics(
      label: resolvedLabel,
      hint: resolvedHint,
      button: a11y.isButton ? true : null,
      header: a11y.isHeader ? true : null,
      child: child,
    );
  }
}
