import 'package:equatable/equatable.dart';
import 'package:fluent_cms_api/src/models/module_node.dart';
import 'package:flutter/foundation.dart';

/// Logical container that groups [ModuleNode]s and defines spatial rules.
@immutable
class ContentZone extends Equatable {
  /// Creates a [ContentZone].
  const ContentZone({
    this.pinned = false,
    this.stickyBottom = false,
    this.visibleWhen,
    this.padding,
    this.modules = const <ModuleNode>[],
  });

  /// Deserializes a [ContentZone] from a JSON map.
  factory ContentZone.fromJson(Map<String, dynamic> json) {
    final parsedModules = <ModuleNode>[];
    final rawModules = json['modules'];
    if (rawModules is List) {
      for (var i = 0; i < rawModules.length; i++) {
        final item = rawModules[i];
        if (item is Map<String, dynamic>) {
          parsedModules.add(ModuleNode.fromJson(item));
        } else if (item is Map) {
          final map = <String, dynamic>{};
          for (final entry in item.entries) {
            if (entry.key != null) {
              map[entry.key.toString()] = entry.value;
            }
          }
          parsedModules.add(ModuleNode.fromJson(map));
        }
      }
    }

    return ContentZone(
      pinned: json['pinned'] as bool? ?? false,
      stickyBottom: json['stickyBottom'] as bool? ?? false,
      visibleWhen: json['visibleWhen'] as String?,
      padding: json['padding'],
      modules: parsedModules,
    );
  }

  /// Whether the zone stays pinned at the top of the scroll view.
  final bool pinned;

  /// Whether the zone is anchored to the bottom of the screen outside the
  /// scroll view.
  final bool stickyBottom;

  /// Reactive boolean expression; if `false`, hides the entire zone in 0ms.
  final String? visibleWhen;

  /// Semantic token (`'$spacingMd'`), number, or `{top, bottom, left, right}`
  /// map.
  final Object? padding;

  /// Ordered list of modules rendered inside this zone.
  final List<ModuleNode> modules;

  /// Serializes this [ContentZone] to a JSON map.
  Map<String, dynamic> toJson() {
    final serializedModules = <Map<String, dynamic>>[];
    for (var i = 0; i < modules.length; i++) {
      serializedModules.add(modules[i].toJson());
    }

    return <String, dynamic>{
      'pinned': pinned,
      'stickyBottom': stickyBottom,
      if (visibleWhen != null) 'visibleWhen': visibleWhen,
      if (padding != null) 'padding': padding,
      'modules': serializedModules,
    };
  }

  /// Returns a copy of this [ContentZone] with the given fields replaced.
  ContentZone copyWith({
    bool? pinned,
    bool? stickyBottom,
    String? visibleWhen,
    Object? padding,
    List<ModuleNode>? modules,
  }) {
    return ContentZone(
      pinned: pinned ?? this.pinned,
      stickyBottom: stickyBottom ?? this.stickyBottom,
      visibleWhen: visibleWhen ?? this.visibleWhen,
      padding: padding ?? this.padding,
      modules: modules ?? this.modules,
    );
  }

  @override
  List<Object?> get props => [
    pinned,
    stickyBottom,
    visibleWhen,
    padding,
    modules,
  ];
}
