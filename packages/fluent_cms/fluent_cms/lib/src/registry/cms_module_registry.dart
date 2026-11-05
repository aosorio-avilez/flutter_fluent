import 'package:fluent_cms/src/registry/fallback_module_widget.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter/widgets.dart';

/// Result of resolving and validating a [ModuleNode] against
/// [CmsModuleRegistry].
class ModuleResolutionResult {
  /// Creates a [ModuleResolutionResult].
  const ModuleResolutionResult({
    this.module,
    this.failureReason,
  });

  /// Resolved [SduiModule], or `null` when unknown or invalid.
  final SduiModule? module;

  /// Diagnostic message when resolution or constraint validation fails.
  final String? failureReason;

  /// Whether the module resolved and satisfied all zone constraints.
  bool get isValid => module != null && failureReason == null;
}

/// Registry of semantic [SduiModule] implementations with `ZoneConstraints`
/// validation and optional `LoggerApi` reporting.
class CmsModuleRegistry {
  /// Creates a [CmsModuleRegistry].
  CmsModuleRegistry({
    LoggerApi? logger,
    Iterable<SduiModule> initialModules = const <SduiModule>[],
  }) : _logger = logger {
    for (final module in initialModules) {
      _modules[module.type] = module;
    }
  }

  final LoggerApi? _logger;
  final Map<String, SduiModule> _modules = <String, SduiModule>{};

  /// Registers [module] under its `module.type` key.
  void register(SduiModule module) {
    _modules[module.type] = module;
  }

  /// Retrieves a registered [SduiModule] by [type], or `null` if not found.
  SduiModule? getModule(String type) => _modules[type];

  /// Returns an unmodifiable list of all registered [SduiModule]s using a
  /// standard loop without closures.
  List<SduiModule> get registeredModules {
    final list = <SduiModule>[];
    for (final entry in _modules.entries) {
      list.add(entry.value);
    }
    return List<SduiModule>.unmodifiable(list);
  }

  /// Resolves [node] and validates its [ZoneConstraints] against the target
  /// zone context, logging a warning via `LoggerApi` if validation fails.
  ModuleResolutionResult resolveForZone(
    ModuleNode node, {
    double? availableWidth,
    bool isPinned = false,
    bool isStickyBottom = false,
  }) {
    final module = _modules[node.type];
    if (module == null) {
      final reason = 'Unregistered module type "${node.type}".';
      _logger?.logWarning(
        '[fluent_cms] Module "${node.id}" skipped: $reason',
      );
      return ModuleResolutionResult(failureReason: reason);
    }

    final satisfied = module.constraints.isSatisfiedBy(
      availableWidth: availableWidth,
      isPinned: isPinned,
      isStickyBottom: isStickyBottom,
    );
    if (!satisfied) {
      final reason =
          'Module "${node.id}" (${node.type}) violates ZoneConstraints '
          '(width=$availableWidth, pinned=$isPinned, '
          'stickyBottom=$isStickyBottom).';
      _logger?.logWarning('[fluent_cms] $reason');
      return ModuleResolutionResult(
        module: module,
        failureReason: reason,
      );
    }

    return ModuleResolutionResult(module: module);
  }

  /// Resolves [node] and builds its widget, returning a [FallbackModuleWidget]
  /// when unregistered or violating [ZoneConstraints].
  Widget resolveModuleWidget({
    required BuildContext context,
    required ModuleNode node,
    required CmsModuleContext moduleContext,
    double? availableWidth,
    bool isPinned = false,
    bool isStickyBottom = false,
    bool showDiagnostics = false,
  }) {
    final resolution = resolveForZone(
      node,
      availableWidth: availableWidth,
      isPinned: isPinned,
      isStickyBottom: isStickyBottom,
    );
    if (!resolution.isValid) {
      return FallbackModuleWidget(
        moduleId: node.id,
        moduleType: node.type,
        reason: resolution.failureReason ?? 'Invalid module resolution.',
        showDiagnostics: showDiagnostics,
      );
    }
    return resolution.module!.build(context, moduleContext);
  }
}
