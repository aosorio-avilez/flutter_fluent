import 'package:fluent_cms/src/state/page_scoped_reactive_store.dart';
import 'package:flutter/widgets.dart';

/// Controller for `CmsPageView` providing programmatic access to the
/// [PageScopedReactiveStore], [ScrollController], [scrollToModule],
/// `onImpression` deduplication, and page refresh.
class CmsPageController {
  /// Creates a [CmsPageController].
  CmsPageController({
    ScrollController? scrollController,
    PageScopedReactiveStore? pageStore,
  }) : _ownsScrollController = scrollController == null,
       _ownsPageStore = pageStore == null,
       scrollController = scrollController ?? ScrollController(),
       pageStore = pageStore ?? PageScopedReactiveStore();

  final bool _ownsScrollController;
  final bool _ownsPageStore;

  /// Scroll controller attached to the primary `CustomScrollView` of the page.
  final ScrollController scrollController;

  /// Reactive store scoped to the active page.
  final PageScopedReactiveStore pageStore;

  final Map<String, GlobalObjectKey> _moduleKeys = <String, GlobalObjectKey>{};
  final Map<String, GlobalObjectKey> _zoneKeys = <String, GlobalObjectKey>{};
  final Set<String> _firedImpressions = <String>{};

  Future<void> Function()? _refreshHandler;
  bool _isDisposed = false;

  /// Whether this controller has been disposed.
  bool get isDisposed => _isDisposed;

  /// Attaches an internal refresh callback managed by `CmsPageView`.
  // ignore: use_setters_to_change_properties
  void attachRefreshHandler(Future<void> Function()? handler) {
    _refreshHandler = handler;
  }

  /// Returns a deterministic [GlobalObjectKey] for [moduleId] used for
  /// [scrollToModule] and viewport impression tracking.
  GlobalObjectKey keyForModule(String moduleId) {
    return _moduleKeys.putIfAbsent(
      moduleId,
      () => GlobalObjectKey('cms_mod_${identityHashCode(this)}_$moduleId'),
    );
  }

  /// Returns a deterministic [GlobalObjectKey] for [zoneId].
  GlobalObjectKey keyForZone(String zoneId) {
    return _zoneKeys.putIfAbsent(
      zoneId,
      () => GlobalObjectKey('cms_zone_${identityHashCode(this)}_$zoneId'),
    );
  }

  /// Scrolls smoothly to the module (or zone) identified by [targetId].
  ///
  /// Returns `true` if the target context is mounted in the widget tree and the
  /// scroll animation completed.
  Future<bool> scrollToModule(
    String targetId, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double alignment = 0,
  }) async {
    if (_isDisposed || targetId.trim().isEmpty) return false;
    final trimmed = targetId.trim();

    final key = _moduleKeys[trimmed] ?? _zoneKeys[trimmed];
    final targetContext = key?.currentContext;
    if (targetContext == null || !targetContext.mounted) {
      return false;
    }

    await Scrollable.ensureVisible(
      targetContext,
      duration: duration,
      curve: curve,
      alignment: alignment,
    );
    return true;
  }

  /// Triggers a page refresh (equivalent to Pull-to-Refresh).
  Future<void> refresh() async {
    if (_isDisposed) return;
    final handler = _refreshHandler;
    if (handler != null) {
      await handler();
    }
  }

  /// Returns `true` if `onImpression` has already been emitted for [moduleId]
  /// during the current page lifecycle.
  bool hasFiredImpression(String moduleId) =>
      _firedImpressions.contains(moduleId);

  /// Marks [moduleId] as having emitted its `onImpression` event.
  void markImpressionFired(String moduleId) {
    if (_isDisposed) return;
    _firedImpressions.add(moduleId);
  }

  /// Resets all recorded module impressions (e.g. on full page refresh if
  /// desired).
  void resetImpressions() {
    _firedImpressions.clear();
  }

  /// Releases owned resources ([scrollController] and [pageStore]).
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _refreshHandler = null;
    _moduleKeys.clear();
    _zoneKeys.clear();
    _firedImpressions.clear();
    if (_ownsScrollController) {
      scrollController.dispose();
    }
    if (_ownsPageStore) {
      pageStore.dispose();
    }
  }
}
