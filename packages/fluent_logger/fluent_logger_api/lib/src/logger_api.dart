/// Interface defined to use the fluent logger functionalities
abstract class LoggerApi {
  /// Print a debug level message
  void logDebug(dynamic message);

  /// Print a error level message
  void logError(dynamic message, {StackTrace? stackTrace});

  /// Print a info level message
  void logInfo(dynamic message);

  /// Print a warning level message
  void logWarning(dynamic message, {StackTrace? stackTrace});
}
