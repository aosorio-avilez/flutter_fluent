import 'package:flutter/material.dart';

/// Forward-compatible fallback widget rendered when a module is unknown,
/// violates `ZoneConstraints`, or throws an error during build.
///
/// Collapses to [SizedBox.shrink] in production builds (`dart.vm.product`)
/// or when [showDiagnostics] is `false`.
class FallbackModuleWidget extends StatelessWidget {
  /// Creates a [FallbackModuleWidget].
  const FallbackModuleWidget({
    required this.moduleId,
    required this.moduleType,
    required this.reason,
    this.showDiagnostics = false,
    super.key,
  });

  /// Identifier of the affected module.
  final String moduleId;

  /// Type key of the affected module.
  final String moduleType;

  /// Diagnostic reason describing why the fallback was rendered.
  final String reason;

  /// Whether visual diagnostic cards are enabled in non-production builds.
  final bool showDiagnostics;

  @override
  Widget build(BuildContext context) {
    if (!const bool.fromEnvironment('dart.vm.product') && showDiagnostics) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          border: Border.all(color: const Color(0xFFE65100)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '[CMS Fallback] id="$moduleId" type="$moduleType": $reason',
          style: const TextStyle(
            color: Color(0xFFBF360C),
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
