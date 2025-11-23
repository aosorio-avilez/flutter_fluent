import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:loggy/loggy.dart';

class LoggerApiImpl extends LoggerApi {
  LoggerApiImpl(this._loggy);

  final Loggy _loggy;

  @override
  void logDebug(dynamic message) {
    _loggy.log(LogLevel.debug, message);
  }

  @override
  void logError(dynamic message, {StackTrace? stackTrace}) {
    _loggy.log(LogLevel.error, message, stackTrace);
  }

  @override
  void logInfo(dynamic message) {
    _loggy.log(LogLevel.info, message);
  }

  @override
  void logWarning(dynamic message, {StackTrace? stackTrace}) {
    _loggy.log(LogLevel.warning, message, stackTrace);
  }
}
