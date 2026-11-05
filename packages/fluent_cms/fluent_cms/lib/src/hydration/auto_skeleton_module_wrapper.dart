import 'dart:async';

import 'package:fluent_cms/src/hydration/async_data_source_manager.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter/material.dart';

/// Default lightweight skeleton placeholder rendered while a module's
/// `requiresData` dependencies are still resolving.
class DefaultCmsSkeletonWidget extends StatelessWidget {
  /// Creates a [DefaultCmsSkeletonWidget].
  const DefaultCmsSkeletonWidget({
    required this.node,
    this.height = 88,
    super.key,
  });

  /// Module node awaiting async data.
  final ModuleNode node;

  /// Placeholder height in logical pixels.
  final double height;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final baseColor = brightness == Brightness.dark
        ? const Color(0xFF2A2E37)
        : const Color(0xFFE4E7EC);

    return Semantics(
      label: 'Loading ${node.type}',
      child: Container(
        key: ValueKey<String>('cms_skeleton_${node.id}'),
        height: height,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Wrapper widget that automatically displays a skeleton while a [ModuleNode]'s
/// `requiresData` dependencies (`async.*`) are loading, or collapses the module
/// when `hideOnError` is `true` and a dependency fails without fallback.
class AutoSkeletonModuleWrapper extends StatefulWidget {
  /// Creates an [AutoSkeletonModuleWrapper].
  const AutoSkeletonModuleWrapper({
    required this.node,
    required this.childBuilder,
    this.module,
    this.asyncManager,
    super.key,
  });

  /// AST node of the module.
  final ModuleNode node;

  /// Optional registered [SduiModule] providing custom `buildSkeleton`.
  final SduiModule? module;

  /// Optional page-scoped [AsyncDataSourceManager].
  final AsyncDataSourceManager? asyncManager;

  /// Builder invoked once all required data dependencies are available.
  final WidgetBuilder childBuilder;

  @override
  State<AutoSkeletonModuleWrapper> createState() =>
      _AutoSkeletonModuleWrapperState();
}

class _AutoSkeletonModuleWrapperState extends State<AutoSkeletonModuleWrapper> {
  Listenable? _mergedListenable;

  @override
  void initState() {
    super.initState();
    _bindDependencies();
  }

  @override
  void didUpdateWidget(covariant AutoSkeletonModuleWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asyncManager != widget.asyncManager ||
        oldWidget.node.requiresData != widget.node.requiresData) {
      _bindDependencies();
    }
  }

  void _bindDependencies() {
    final manager = widget.asyncManager;
    final requiredPaths = widget.node.requiresData;
    if (manager == null || requiredPaths == null || requiredPaths.isEmpty) {
      _mergedListenable = null;
      return;
    }

    final listenables = <Listenable>[];
    final len = requiredPaths.length;
    for (var i = 0; i < len; i++) {
      final path = requiredPaths[i];
      listenables.add(manager.listenSource(path));
      final snapshot = manager.getSnapshot(path);
      if (snapshot.status == AsyncSourceStatus.idle) {
        unawaited(manager.resolveSource(path));
      }
    }
    _mergedListenable = Listenable.merge(listenables);
  }

  @override
  Widget build(BuildContext context) {
    final manager = widget.asyncManager;
    final requiredPaths = widget.node.requiresData;
    final listenable = _mergedListenable;

    if (manager == null ||
        requiredPaths == null ||
        requiredPaths.isEmpty ||
        listenable == null) {
      return widget.childBuilder(context);
    }

    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        var isAnyLoading = false;
        var hasHardError = false;

        final len = requiredPaths.length;
        for (var i = 0; i < len; i++) {
          final snapshot = manager.getSnapshot(requiredPaths[i]);
          if (snapshot.status == AsyncSourceStatus.error && !snapshot.hasData) {
            hasHardError = true;
            break;
          }
          if (!snapshot.hasData &&
              (snapshot.status == AsyncSourceStatus.idle ||
                  snapshot.status == AsyncSourceStatus.loading)) {
            isAnyLoading = true;
          }
        }

        if (hasHardError) {
          if (widget.node.hideOnError) {
            return const SizedBox.shrink();
          }
          return widget.childBuilder(context);
        }

        if (isAnyLoading) {
          return widget.module?.buildSkeleton(context, widget.node) ??
              DefaultCmsSkeletonWidget(node: widget.node);
        }

        return widget.childBuilder(context);
      },
    );
  }
}
