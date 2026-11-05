import 'package:fluent_cms_api/src/models/async_source.dart';

/// Contract for resolving deferred [AsyncSource] requests.
abstract class AsyncDataSource {
  /// Fetches a JSON payload for [source], optionally forcing a cache refresh
  /// or passing extra [queryParameters] (e.g. for repeater pagination).
  Future<Map<String, dynamic>> fetch(
    AsyncSource source, {
    bool forceRefresh = false,
    Map<String, dynamic>? queryParameters,
  });
}
