import 'package:equatable/equatable.dart';
import 'package:fluent_cms_api/src/models/a11y_config.dart';
import 'package:fluent_cms_api/src/models/action_node.dart';
import 'package:fluent_cms_api/src/models/responsive_layout_config.dart';
import 'package:flutter/foundation.dart';

/// Atomic functional unit mapped to `CmsModuleRegistry`.
@immutable
class ModuleNode {
  /// Creates a [ModuleNode].
  const ModuleNode({
    required this.id,
    required this.type,
    this.platforms,
    this.visibleWhen,
    this.requiresData,
    this.hideOnError = true,
    this.keepAlive = false,
    this.a11y,
    this.props = const <String, dynamic>{},
    this.responsiveProps,
    this.actions,
  });

  /// Deserializes a [ModuleNode] from a JSON map.
  factory ModuleNode.fromJson(Map<String, dynamic> json) {
    List<String>? parsedPlatforms;
    final rawPlatforms = json['platforms'];
    if (rawPlatforms is List) {
      parsedPlatforms = <String>[];
      for (var i = 0; i < rawPlatforms.length; i++) {
        final item = rawPlatforms[i];
        if (item is String) {
          parsedPlatforms.add(item);
        }
      }
    }

    List<String>? parsedRequiresData;
    final rawRequiresData = json['requiresData'];
    if (rawRequiresData is List) {
      parsedRequiresData = <String>[];
      for (var i = 0; i < rawRequiresData.length; i++) {
        final item = rawRequiresData[i];
        if (item is String) {
          parsedRequiresData.add(item);
        }
      }
    }

    A11yConfig? parsedA11y;
    final rawA11y = json['a11y'];
    if (rawA11y is Map<String, dynamic>) {
      parsedA11y = A11yConfig.fromJson(rawA11y);
    }

    final parsedProps = <String, dynamic>{};
    final rawProps = json['props'];
    if (rawProps is Map) {
      for (final entry in rawProps.entries) {
        if (entry.key != null) {
          parsedProps[entry.key.toString()] = entry.value;
        }
      }
    }

    Map<String, Map<String, dynamic>>? parsedResponsiveProps;
    final rawResponsiveProps = json['responsiveProps'];
    if (rawResponsiveProps is Map) {
      parsedResponsiveProps = <String, Map<String, dynamic>>{};
      for (final outerEntry in rawResponsiveProps.entries) {
        final outerKey = outerEntry.key?.toString();
        final outerValue = outerEntry.value;
        if (outerKey != null && outerValue is Map) {
          final innerMap = <String, dynamic>{};
          for (final innerEntry in outerValue.entries) {
            if (innerEntry.key != null) {
              innerMap[innerEntry.key.toString()] = innerEntry.value;
            }
          }
          parsedResponsiveProps[outerKey] = innerMap;
        }
      }
    }

    Map<String, ActionNode>? parsedActions;
    final rawActions = json['actions'];
    if (rawActions is Map) {
      parsedActions = <String, ActionNode>{};
      for (final entry in rawActions.entries) {
        final key = entry.key?.toString();
        final value = entry.value;
        if (key != null && value is Map<String, dynamic>) {
          parsedActions[key] = ActionNode.fromJson(value);
        }
      }
    }

    return ModuleNode(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      platforms: parsedPlatforms,
      visibleWhen: json['visibleWhen'] as String?,
      requiresData: parsedRequiresData,
      hideOnError: json['hideOnError'] as bool? ?? true,
      keepAlive: json['keepAlive'] as bool? ?? false,
      a11y: parsedA11y,
      props: parsedProps,
      responsiveProps: parsedResponsiveProps,
      actions: parsedActions,
    );
  }

  /// Unique instance identifier within the page.
  final String id;

  /// Module type key registered in `CmsModuleRegistry`.
  final String type;

  /// Optional list of allowed platforms (`android`, `ios`, `web`, `desktop`,
  /// `macos`, `windows`, `linux`). If `null`, renders on all platforms.
  final List<String>? platforms;

  /// Conditional boolean expression evaluated against `data`, `client`,
  /// `state`, or `env.features`.
  final String? visibleWhen;

  /// List of async data paths (e.g. `['async.wallet']`) that must resolve
  /// before rendering the module.
  final List<String>? requiresData;

  /// Whether to collapse the module to `SizedBox.shrink()` if an async source
  /// in [requiresData] fails without a fallback.
  final bool hideOnError;

  /// Wraps the module in `AutomaticKeepAlive` to preserve state when scrolled
  /// out of the Sliver viewport.
  final bool keepAlive;

  /// Optional accessibility configuration.
  final A11yConfig? a11y;

  /// Business and styling properties passed to the module.
  final Map<String, dynamic> props;

  /// Partial overrides of [props] by breakpoint (`mobile`, `tablet`,
  /// `desktop`).
  final Map<String, Map<String, dynamic>>? responsiveProps;

  /// Map of declarative action triggers (`onTap`, `onChanged`,
  /// `onImpression`).
  final Map<String, ActionNode>? actions;

  /// Resolves the effective properties for [breakpoint] using a shallow merge
  /// over [props] without closure allocations.
  Map<String, dynamic> resolvePropsForBreakpoint(CmsBreakpoint breakpoint) {
    final overridesMap = responsiveProps;
    if (overridesMap == null || overridesMap.isEmpty) {
      return props;
    }

    final override = overridesMap[breakpoint.name];
    if (override == null || override.isEmpty) {
      return props;
    }

    final merged = <String, dynamic>{};
    for (final entry in props.entries) {
      merged[entry.key] = entry.value;
    }
    for (final entry in override.entries) {
      merged[entry.key] = entry.value;
    }
    return merged;
  }

  /// Checks whether this module is allowed on [platform] (and optional
  /// `'desktop'` alias for `macos`, `windows`, `linux`) using a standard loop.
  bool isSupportedOnPlatform(String platform) {
    final allowed = platforms;
    if (allowed == null || allowed.isEmpty) {
      return true;
    }
    final normalized = platform.toLowerCase();
    final isDesktopOs =
        normalized == 'macos' ||
        normalized == 'windows' ||
        normalized == 'linux';

    for (var i = 0; i < allowed.length; i++) {
      final candidate = allowed[i].toLowerCase();
      if (candidate == normalized) {
        return true;
      }
      if (isDesktopOs && candidate == 'desktop') {
        return true;
      }
    }
    return false;
  }

  /// Serializes this [ModuleNode] to a JSON map.
  Map<String, dynamic> toJson() {
    Map<String, dynamic>? serializedActions;
    final currentActions = actions;
    if (currentActions != null) {
      serializedActions = <String, dynamic>{};
      for (final entry in currentActions.entries) {
        serializedActions[entry.key] = entry.value.toJson();
      }
    }

    return <String, dynamic>{
      'id': id,
      'type': type,
      if (platforms != null) 'platforms': platforms,
      if (visibleWhen != null) 'visibleWhen': visibleWhen,
      if (requiresData != null) 'requiresData': requiresData,
      'hideOnError': hideOnError,
      'keepAlive': keepAlive,
      if (a11y != null) 'a11y': a11y!.toJson(),
      'props': props,
      if (responsiveProps != null) 'responsiveProps': responsiveProps,
      'actions': ?serializedActions,
    };
  }

  /// Returns a copy of this [ModuleNode] with the given fields replaced.
  ModuleNode copyWith({
    String? id,
    String? type,
    List<String>? platforms,
    String? visibleWhen,
    List<String>? requiresData,
    bool? hideOnError,
    bool? keepAlive,
    A11yConfig? a11y,
    Map<String, dynamic>? props,
    Map<String, Map<String, dynamic>>? responsiveProps,
    Map<String, ActionNode>? actions,
  }) {
    return ModuleNode(
      id: id ?? this.id,
      type: type ?? this.type,
      platforms: platforms ?? this.platforms,
      visibleWhen: visibleWhen ?? this.visibleWhen,
      requiresData: requiresData ?? this.requiresData,
      hideOnError: hideOnError ?? this.hideOnError,
      keepAlive: keepAlive ?? this.keepAlive,
      a11y: a11y ?? this.a11y,
      props: props ?? this.props,
      responsiveProps: responsiveProps ?? this.responsiveProps,
      actions: actions ?? this.actions,
    );
  }

  _ModuleNodeEquatable get _equatable => _ModuleNodeEquatable(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModuleNode && _equatable == other._equatable);

  @override
  int get hashCode => _equatable.hashCode;
}

class _ModuleNodeEquatable extends Equatable {
  const _ModuleNodeEquatable(this.node);

  final ModuleNode node;

  @override
  List<Object?> get props => [
    node.id,
    node.type,
    node.platforms,
    node.visibleWhen,
    node.requiresData,
    node.hideOnError,
    node.keepAlive,
    node.a11y,
    node.props,
    node.responsiveProps,
    node.actions,
  ];
}
