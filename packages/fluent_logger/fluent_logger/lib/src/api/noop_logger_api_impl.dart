import 'package:fluent_logger_api/fluent_logger_api.dart';

/// A no-op implementation of [LoggerApi] that does nothing.
/// Used when logging is disabled to avoid runtime overhead.
class NoOpLoggerApiImpl implements LoggerApi {
  /// Creates a [NoOpLoggerApiImpl].
  const NoOpLoggerApiImpl();

  @override
  @pragma('vm:prefer-inline')
  void logDebug(dynamic message) {}

  @override
  @pragma('vm:prefer-inline')
  void logError(dynamic message, {StackTrace? stackTrace}) {}

  @override
  @pragma('vm:prefer-inline')
  void logInfo(dynamic message) {}

  @override
  @pragma('vm:prefer-inline')
  void logWarning(dynamic message, {StackTrace? stackTrace}) {}
}
