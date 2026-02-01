import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_fluent_logger/src/api/logger_api_impl.dart';
import 'package:flutter_fluent_logger/src/api/noop_logger_api_impl.dart';
import 'package:flutter_fluent_logger/src/logger_config.dart';
import 'package:flutter_fluent_logger/src/logger_module.dart';
import 'package:loggy/loggy.dart';
import 'package:test/test.dart';

void main() {
  test('verify logger module registration', () async {
    // Arrange
    const config = LoggerConfig(enableLog: true);

    // Act
    await Fluent.build([const LoggerModule(config: config)]);
    addTearDown(Fluent.reset);

    // Assert
    expect(Fluent.get<Loggy>(), isA<Loggy>());
    expect(Fluent.get<LoggerApi>(), isA<LoggerApiImpl>());
  });

  test('verify logger module registration without config', () async {
    // Act
    await Fluent.build([const LoggerModule()]);
    addTearDown(Fluent.reset);

    // Assert
    expect(Fluent.get<Loggy>(), isA<Loggy>());
    expect(Fluent.get<LoggerApi>(), isA<NoOpLoggerApiImpl>());
  });
}
