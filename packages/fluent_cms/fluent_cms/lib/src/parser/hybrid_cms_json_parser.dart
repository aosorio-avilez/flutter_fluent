import 'dart:convert';
import 'dart:isolate';

import 'package:fluent_cms_api/fluent_cms_api.dart';

/// Hybrid JSON parser that parses payloads `< 50KB` synchronously on the
/// calling thread and offloads payloads `>= 50KB` to [Isolate.run].
class HybridCmsJsonParser {
  /// Creates a `const` [HybridCmsJsonParser].
  const HybridCmsJsonParser();

  /// Payload length threshold in characters (`50,000`) for switching to
  /// [Isolate.run].
  static const int isolateThreshold = 50000;

  /// Parses [rawJson] into a [CmsPage] using the hybrid 50KB threshold.
  Future<CmsPage> parse(String rawJson) {
    if (rawJson.length < isolateThreshold) {
      return Future<CmsPage>.value(parseSync(rawJson));
    }
    return Isolate.run<CmsPage>(() => parseSync(rawJson));
  }

  /// Synchronously parses [rawJson] into a [CmsPage].
  static CmsPage parseSync(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid CmsPage JSON: root value must be a JSON object.',
      );
    }
    return CmsPage.fromJson(decoded);
  }
}
