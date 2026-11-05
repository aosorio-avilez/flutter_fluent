import 'package:fluent_cms_api/src/models/module_node.dart';
import 'package:fluent_cms_api/src/registry/cms_module_context.dart';
import 'package:fluent_cms_api/src/registry/zone_constraints.dart';
import 'package:flutter/widgets.dart';

/// Contract for a semantic business module registered in `fluent_cms`.
abstract class SduiModule {
  /// Creates an [SduiModule].
  const SduiModule();

  /// Unique type identifier matched against `ModuleNode.type`.
  String get type;

  /// Spatial and structural constraints for this module.
  ZoneConstraints get constraints => const ZoneConstraints();

  /// Optional JSON Schema fragment describing this module's `props`.
  Map<String, dynamic> get propsSchema => const <String, dynamic>{};

  /// Builds the Flutter widget for this module given its [moduleContext].
  Widget build(BuildContext context, CmsModuleContext moduleContext);

  /// Optional custom skeleton widget displayed while `requiresData` resolves.
  Widget? buildSkeleton(BuildContext context, ModuleNode node) => null;
}
