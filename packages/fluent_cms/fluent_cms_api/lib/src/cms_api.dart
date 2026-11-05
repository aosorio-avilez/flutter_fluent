import 'package:equatable/equatable.dart';
import 'package:fluent_cms_api/src/hydration/pipe_transformer.dart';
import 'package:fluent_cms_api/src/models/action_node.dart';
import 'package:fluent_cms_api/src/models/cms_page.dart';
import 'package:fluent_cms_api/src/registry/sdui_module.dart';
import 'package:flutter/foundation.dart';

/// Callback signature for custom commands (`actionType: 'custom_command'`).
/// Returns `true` on success, or `false` to trigger rollback/onError.
typedef CmsCommandHandler =
    Future<bool> Function(
      String target,
      Map<String, dynamic>? payload,
    );

/// Telemetry and diagnostics event emitted when an [ActionNode] is triggered.
@immutable
class CmsActionEvent extends Equatable {
  /// Creates a [CmsActionEvent].
  const CmsActionEvent({
    required this.pageId,
    required this.moduleId,
    required this.trigger,
    required this.action,
    this.resolvedPayload,
    this.resolvedAnalytics,
  });

  /// Identifier of the page where the action originated.
  final String pageId;

  /// Identifier of the module that triggered the action.
  final String moduleId;

  /// Trigger key (e.g. `'onTap'`, `'onImpression'`, `'onChanged'`).
  final String trigger;

  /// Underlying [ActionNode] definition.
  final ActionNode action;

  /// Hydrated action payload map, if any.
  final Map<String, dynamic>? resolvedPayload;

  /// Hydrated analytics metadata map, if any.
  final Map<String, dynamic>? resolvedAnalytics;

  @override
  List<Object?> get props => [
    pageId,
    moduleId,
    trigger,
    action,
    resolvedPayload,
    resolvedAnalytics,
  ];
}

/// Observer callback notified whenever a declarative action or impression
/// fires.
typedef CmsActionObserver = void Function(CmsActionEvent event);

/// Primary public contract registered in `Fluent.get<CmsApi>()`.
abstract class CmsApi {
  /// Creates a [CmsApi].
  const CmsApi();

  /// Registers a semantic [SduiModule] in the CMS module registry.
  void registerModule(SduiModule module);

  /// Retrieves a registered [SduiModule] by its [type], or `null` if unknown.
  SduiModule? getModule(String type);

  /// Unmodifiable list of all currently registered [SduiModule]s.
  List<SduiModule> get registeredModules;

  /// Registers a custom [PipeTransformer] for `{{expr | pipe:arg}}`
  /// expressions.
  void registerPipe(PipeTransformer pipe);

  /// Retrieves a registered [PipeTransformer] by [name], or `null` if unknown.
  PipeTransformer? getPipe(String name);

  /// Registers a [handler] for custom commands targeting [commandName].
  void registerCommandHandler(String commandName, CmsCommandHandler handler);

  /// Subscribes an [observer] to receive action and impression events.
  void addActionObserver(CmsActionObserver observer);

  /// Unsubscribes a previously registered [observer].
  void removeActionObserver(CmsActionObserver observer);

  /// Parses a raw JSON string into a [CmsPage] using the hybrid parser
  /// (`< 50KB` synchronous on main thread, `>= 50KB` via `Isolate.run`).
  Future<CmsPage> parsePage(String rawJson);

  /// Fetches and parses a [CmsPage] by [pageIdOrEndpoint], leveraging cache
  /// unless [forceRefresh] is `true`.
  Future<CmsPage> fetchPage(
    String pageIdOrEndpoint, {
    bool forceRefresh = false,
  });

  /// Flushes the in-memory page template cache.
  void clearCache();

  /// Reactive flag indicating whether diagnostic zone borders are enabled.
  ValueListenable<bool> get debugZoneBordersEnabled;

  /// Toggles diagnostic zone borders overlay in non-production builds.
  void toggleDebugZoneBorders();

  /// Exports the JSON Schema (Draft 2020-12) including all [registeredModules].
  Map<String, dynamic> exportJsonSchema();
}
