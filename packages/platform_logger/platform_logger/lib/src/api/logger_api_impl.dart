import 'package:loggy/loggy.dart';
import 'package:platform_logger_api/platform_logger_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class LoggerApiImpl extends LoggerApi {
  @override
  void logDebug(dynamic message) {
    getApi<Loggy>().log(LogLevel.debug, message);
  }

  @override
  void logError(dynamic message, {StackTrace? stackTrace}) {
    getApi<Loggy>().log(LogLevel.error, message, stackTrace);
  }

  @override
  void logInfo(dynamic message) {
    getApi<Loggy>().log(LogLevel.info, message);
  }

  @override
  void logWarning(dynamic message, {StackTrace? stackTrace}) {
    getApi<Loggy>().log(LogLevel.warning, message, stackTrace);
  }
}
