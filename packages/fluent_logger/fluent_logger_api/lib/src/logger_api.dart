abstract class LoggerApi {
  void logDebug(dynamic message);

  void logError(dynamic message, {StackTrace? stackTrace});

  void logInfo(dynamic message);

  void logWarning(dynamic message, {StackTrace? stackTrace});
}
