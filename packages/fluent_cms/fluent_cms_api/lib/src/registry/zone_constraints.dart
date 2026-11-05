import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Spatial and structural constraints declared by an `SduiModule`.
@immutable
class ZoneConstraints extends Equatable {
  /// Creates a [ZoneConstraints].
  const ZoneConstraints({
    this.minWidth,
    this.maxWidth,
    this.allowInPinnedZone = true,
    this.allowInStickyBottom = true,
  });

  /// Minimum width in logical pixels required by the module.
  final double? minWidth;

  /// Maximum width in logical pixels supported by the module.
  final double? maxWidth;

  /// Whether the module can be placed inside a pinned header zone.
  final bool allowInPinnedZone;

  /// Whether the module can be placed inside a sticky-bottom zone.
  final bool allowInStickyBottom;

  /// Evaluates whether the zone environment satisfies these constraints.
  bool isSatisfiedBy({
    double? availableWidth,
    bool isPinned = false,
    bool isStickyBottom = false,
  }) {
    if (isPinned && !allowInPinnedZone) {
      return false;
    }
    if (isStickyBottom && !allowInStickyBottom) {
      return false;
    }
    if (availableWidth != null) {
      final min = minWidth;
      if (min != null && availableWidth < min) {
        return false;
      }
      final max = maxWidth;
      if (max != null && availableWidth > max) {
        return false;
      }
    }
    return true;
  }

  @override
  List<Object?> get props => [
    minWidth,
    maxWidth,
    allowInPinnedZone,
    allowInStickyBottom,
  ];
}
