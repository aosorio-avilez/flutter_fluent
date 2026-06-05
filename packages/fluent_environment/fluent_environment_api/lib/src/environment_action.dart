import 'package:flutter/widgets.dart';

/// A class representing a custom action that can be performed
/// within the environment toolkit.
class EnvironmentAction {
  /// Creates an [EnvironmentAction].
  const EnvironmentAction({
    required this.label,
    required this.onTap,
    this.icon,
  });

  /// The text label for the action.
  final String label;

  /// The callback to execute when the action is triggered.
  final void Function(BuildContext context) onTap;

  /// An optional icon for the action.
  final IconData? icon;
}
