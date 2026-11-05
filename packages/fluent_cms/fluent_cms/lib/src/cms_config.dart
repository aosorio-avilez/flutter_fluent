import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter/foundation.dart';

/// Global configuration for `CmsModule` and the `fluent_cms` engine.
@immutable
class CmsConfig {
  /// Creates a [CmsConfig].
  const CmsConfig({
    this.mobileMaxWidth = 600,
    this.tabletMaxWidth = 1024,
    this.allowedHosts,
    this.enableDebugOverlay = false,
    this.defaultImpressionThreshold = 0.5,
    this.defaultImpressionDuration = const Duration(milliseconds: 800),
    this.initialModules = const <SduiModule>[],
    this.initialPipes = const <PipeTransformer>[],
  });

  /// Maximum viewport width in logical pixels considered `mobile`.
  final double mobileMaxWidth;

  /// Maximum viewport width in logical pixels considered `tablet`.
  final double tabletMaxWidth;

  /// Optional allowlist of hosts permitted for `asyncSources` and
  /// `external_url` actions (Sentinel security guard).
  final Set<String>? allowedHosts;

  /// Whether diagnostic zone borders can be enabled in non-production builds.
  final bool enableDebugOverlay;

  /// Minimum visible fraction (`0.0` to `1.0`) required to trigger
  /// `onImpression`.
  final double defaultImpressionThreshold;

  /// Minimum continuous visibility duration required to trigger `onImpression`.
  final Duration defaultImpressionDuration;

  /// Semantic [SduiModule]s registered during `CmsModule.onCreate`.
  final List<SduiModule> initialModules;

  /// Custom [PipeTransformer]s registered during `CmsModule.onCreate`.
  final List<PipeTransformer> initialPipes;

  /// Validates whether [uriString] uses an allowed HTTP/HTTPS scheme and
  /// belongs to [allowedHosts] (when configured).
  bool isUriAllowed(String uriString) {
    final trimmed = uriString.trim();
    if (trimmed.isEmpty) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;

    if (!uri.hasScheme) {
      return trimmed.startsWith('/');
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return false;
    }

    final hosts = allowedHosts;
    if (hosts == null || hosts.isEmpty) {
      return uri.host.isNotEmpty;
    }

    final host = uri.host.toLowerCase();
    for (final allowed in hosts) {
      if (allowed.toLowerCase() == host) {
        return true;
      }
    }
    return false;
  }
}
