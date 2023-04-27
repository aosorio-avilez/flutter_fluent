import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter_fluent_logger/src/logger_module.dart';
import 'package:loggy/loggy.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import '../../mocks/loggy_mock.dart';

void main() {
  setUpAll(
    () async {
      await Fluent.build([LoggerModule()]);
      Fluent.mock<Loggy>(LoggyMock());
      addTearDown(Fluent.reset);
    },
  );

  test('verify logDebug', () async {
    final loggy = Fluent.get<Loggy>();

    Fluent.get<LoggerApi>().logDebug('debug message');

    verify(() => loggy.log(LogLevel.debug, 'debug message')).called(1);
  });

  test('verify logError', () async {
    final loggy = Fluent.get<Loggy>();

    Fluent.get<LoggerApi>().logError('error message');

    verify(() => loggy.log(LogLevel.error, 'error message')).called(1);
  });

  test('verify logInfo', () async {
    final loggy = Fluent.get<Loggy>();

    Fluent.get<LoggerApi>().logInfo('info message');

    verify(() => loggy.log(LogLevel.info, 'info message')).called(1);
  });

  test('verify logWarning', () async {
    final loggy = Fluent.get<Loggy>();

    Fluent.get<LoggerApi>().logWarning('warning message');

    verify(() => loggy.log(LogLevel.warning, 'warning message')).called(1);
  });
}
