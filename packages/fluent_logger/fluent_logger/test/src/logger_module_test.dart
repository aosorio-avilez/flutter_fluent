import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter_fluent_logger/src/api/logger_api_impl.dart';
import 'package:flutter_fluent_logger/src/logger_module.dart';
import 'package:loggy/loggy.dart';
import 'package:test/test.dart';

void main() {
  test('verify logger module', () async {
    await Fluent.build([LoggerModule()]);

    final loggy = Fluent.get<Loggy>();
    final loggerApi = Fluent.get<LoggerApi>();

    expect(loggy, isA<Loggy>());
    expect(loggerApi, isA<LoggerApiImpl>());
  });
}
