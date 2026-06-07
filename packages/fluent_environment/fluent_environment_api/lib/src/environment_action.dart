import 'package:flutter/widgets.dart';

/// Represents a custom developer action that can be registered with
/// the environment.
/// These actions are displayed in the Environment Inspector UI.
class EnvironmentAction {
  /// Creates a new [EnvironmentAction].
  const EnvironmentAction({
    required this.label,
    required this.onTap,
    this.icon,
  });

  /// The label to display for this action.
  final String label;

  /// An optional icon to display next to the label.
  final IconData? icon;

  /// The callback to execute when the action is tapped.
  /// The current [BuildContext] is provided.
  final void Function(BuildContext context) onTap;
}
