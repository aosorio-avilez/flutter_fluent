import 'package:fluent_logger_api/fluent_logger_api.dart';

/// A [LoggerApi] implementation that does nothing.
///
/// Used to eliminate all runtime overhead from logging calls when logging
/// is disabled (via configuration or production environment).
class NoOpLoggerApiImpl extends LoggerApi {
  /// Creates a [NoOpLoggerApiImpl].
  const NoOpLoggerApiImpl();

  @override
  @pragma('vm:prefer-inline')
  void logDebug(dynamic message) {
    // Do nothing
  }

  @override
  @pragma('vm:prefer-inline')
  void logError(dynamic message, {StackTrace? stackTrace}) {
    // Do nothing
  }

  @override
  @pragma('vm:prefer-inline')
  void logInfo(dynamic message) {
    // Do nothing
  }

  @override
  @pragma('vm:prefer-inline')
  void logWarning(dynamic message, {StackTrace? stackTrace}) {
    // Do nothing
  }
}
