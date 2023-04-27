import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:loggy/loggy.dart';

class LoggerApiImpl extends LoggerApi {
  @override
  void logDebug(dynamic message) {
    Fluent.get<Loggy>().log(LogLevel.debug, message);
  }

  @override
  void logError(dynamic message, {StackTrace? stackTrace}) {
    Fluent.get<Loggy>().log(LogLevel.error, message, stackTrace);
  }

  @override
  void logInfo(dynamic message) {
    Fluent.get<Loggy>().log(LogLevel.info, message);
  }

  @override
  void logWarning(dynamic message, {StackTrace? stackTrace}) {
    Fluent.get<Loggy>().log(LogLevel.warning, message, stackTrace);
  }
}
