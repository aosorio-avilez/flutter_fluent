// import 'package:loggy/loggy.dart' as loggy;
import 'package:fluent_logger/src/api/loggy_mock.dart';
import 'package:fluent_logger/src/logger_module.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loggy/loggy.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  setUpAll(
    () {
      Fluent.build([LoggerModule()]);
      mockApi<Loggy>(LoggyMock());
    },
  );

  test('verify logDebug', () async {
    final loggy = getApi<Loggy>();

    getApi<LoggerApi>().logDebug('debug message');

    verify(() => loggy.log(LogLevel.debug, 'debug message')).called(1);
  });

  test('verify logError', () async {
    final loggy = getApi<Loggy>();

    getApi<LoggerApi>().logError('error message');

    verify(() => loggy.log(LogLevel.error, 'error message')).called(1);
  });

  test('verify logInfo', () async {
    final loggy = getApi<Loggy>();

    getApi<LoggerApi>().logInfo('info message');

    verify(() => loggy.log(LogLevel.info, 'info message')).called(1);
  });

  test('verify logWarning', () async {
    final loggy = getApi<Loggy>();

    getApi<LoggerApi>().logWarning('warning message');

    verify(() => loggy.log(LogLevel.warning, 'warning message')).called(1);
  });
}
