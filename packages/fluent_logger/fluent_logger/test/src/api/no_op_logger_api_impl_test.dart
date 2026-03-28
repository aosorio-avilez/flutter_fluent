import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter_fluent_logger/src/api/no_op_logger_api_impl.dart';
import 'package:test/test.dart';

void main() {
  late LoggerApi loggerApi;

  setUp(() {
    loggerApi = const NoOpLoggerApiImpl();
  });

  test('verify logDebug does nothing', () {
    expect(() => loggerApi.logDebug('debug message'), returnsNormally);
  });

  test('verify logError does nothing', () {
    expect(() => loggerApi.logError('error message'), returnsNormally);
  });

  test('verify logInfo does nothing', () {
    expect(() => loggerApi.logInfo('info message'), returnsNormally);
  });

  test('verify logWarning does nothing', () {
    expect(() => loggerApi.logWarning('warning message'), returnsNormally);
  });
}
