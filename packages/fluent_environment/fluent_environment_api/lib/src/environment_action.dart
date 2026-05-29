import 'package:flutter/widgets.dart';

/// Represents a custom action that can be executed from the environment
/// inspector.
class EnvironmentAction {
  /// Creates an [EnvironmentAction].
  const EnvironmentAction({
    required this.label,
    required this.onTap,
    this.icon,
  });

  /// The label displayed for the action.
  final String label;

  /// The icon displayed for the action.
  final IconData? icon;

  /// The callback to execute when the action is tapped.
  final void Function(BuildContext context) onTap;
}
