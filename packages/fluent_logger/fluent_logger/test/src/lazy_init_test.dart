import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_fluent_logger/flutter_fluent_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loggy/loggy.dart';
import 'package:mocktail/mocktail.dart';

class MockRegistry extends Mock implements Registry {}

void main() {
  test('LoggerModule registers dependencies lazily', () {
    final registry = MockRegistry();
    final module = const LoggerModule(config: LoggerConfig(enableLog: true));

    module.onCreate(registry);

    verify(() => registry.registerLazySingleton<Loggy>(any())).called(1);
    verify(() => registry.registerLazySingleton<LoggerApi>(any())).called(1);

    verifyNever(() => registry.registerSingleton<Loggy>(any()));
    verifyNever(() => registry.registerSingleton<LoggerApi>(any()));
  });
}
