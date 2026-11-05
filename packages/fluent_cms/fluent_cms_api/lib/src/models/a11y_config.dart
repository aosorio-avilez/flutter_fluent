import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Declarative accessibility configuration for a `ModuleNode`.
@immutable
class A11yConfig extends Equatable {
  /// Creates an [A11yConfig].
  const A11yConfig({
    this.label,
    this.hint,
    this.isButton = false,
    this.isHeader = false,
    this.excludeSemantics = false,
  });

  /// Deserializes an [A11yConfig] from a JSON map.
  factory A11yConfig.fromJson(Map<String, dynamic> json) {
    return A11yConfig(
      label: json['label'] as String?,
      hint: json['hint'] as String?,
      isButton: json['isButton'] as bool? ?? false,
      isHeader: json['isHeader'] as bool? ?? false,
      excludeSemantics: json['excludeSemantics'] as bool? ?? false,
    );
  }

  /// Semantic label read by screen readers (supports `{{...}}` placeholders).
  final String? label;

  /// Semantic hint read by screen readers.
  final String? hint;

  /// Marks the wrapped module as a button in the semantics tree.
  final bool isButton;

  /// Marks the wrapped module as a header in the semantics tree.
  final bool isHeader;

  /// Excludes child semantics when true.
  final bool excludeSemantics;

  /// Serializes this [A11yConfig] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (label != null) 'label': label,
      if (hint != null) 'hint': hint,
      if (isButton) 'isButton': isButton,
      if (isHeader) 'isHeader': isHeader,
      if (excludeSemantics) 'excludeSemantics': excludeSemantics,
    };
  }

  /// Returns a copy of this [A11yConfig] with the given fields replaced.
  A11yConfig copyWith({
    String? label,
    String? hint,
    bool? isButton,
    bool? isHeader,
    bool? excludeSemantics,
  }) {
    return A11yConfig(
      label: label ?? this.label,
      hint: hint ?? this.hint,
      isButton: isButton ?? this.isButton,
      isHeader: isHeader ?? this.isHeader,
      excludeSemantics: excludeSemantics ?? this.excludeSemantics,
    );
  }

  @override
  List<Object?> get props => [
    label,
    hint,
    isButton,
    isHeader,
    excludeSemantics,
  ];
}
