import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter_fluent_logger/src/api/logger_api_impl.dart';
import 'package:loggy/loggy.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock directo de la librería externa
class MockLoggy extends Mock implements Loggy {}

void main() {
  late MockLoggy mockLoggy;
  late LoggerApi loggerApi;

  setUp(() {
    mockLoggy = MockLoggy();
    // Inyección manual para el test. Simple y directo.
    loggerApi = LoggerApiImpl(mockLoggy);
  });

  test('verify logDebug delegation', () {
    loggerApi.logDebug('debug message');
    verify(() => mockLoggy.log(LogLevel.debug, 'debug message')).called(1);
  });

  test('verify logError delegation', () {
    loggerApi.logError('error message');
    verify(() => mockLoggy.log(LogLevel.error, 'error message')).called(1);
  });

  test('verify logInfo delegation', () {
    loggerApi.logInfo('info message');
    verify(() => mockLoggy.log(LogLevel.info, 'info message')).called(1);
  });

  test('verify logWarning delegation', () {
    loggerApi.logWarning('warning message');
    verify(() => mockLoggy.log(LogLevel.warning, 'warning message')).called(1);
  });
}
