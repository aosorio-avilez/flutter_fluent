import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:loggy/loggy.dart';

class LoggerApiImpl extends LoggerApi {
  LoggerApiImpl(this._loggy);

  final Loggy _loggy;

  @override
  @pragma('vm:prefer-inline')
  void logDebug(dynamic message) {
    _loggy.log(LogLevel.debug, message);
  }

  @override
  @pragma('vm:prefer-inline')
  void logError(dynamic message, {StackTrace? stackTrace}) {
    _loggy.log(LogLevel.error, message, stackTrace);
  }

  @override
  @pragma('vm:prefer-inline')
  void logInfo(dynamic message) {
    _loggy.log(LogLevel.info, message);
  }

  @override
  @pragma('vm:prefer-inline')
  void logWarning(dynamic message, {StackTrace? stackTrace}) {
    _loggy.log(LogLevel.warning, message, stackTrace);
  }
}
