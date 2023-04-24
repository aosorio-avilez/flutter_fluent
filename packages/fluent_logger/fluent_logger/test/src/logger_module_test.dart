import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter_fluent_logger/src/api/logger_api_impl.dart';
import 'package:flutter_fluent_logger/src/logger_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loggy/loggy.dart';

void main() {
  test('verify logger module', () async {
    Fluent.build([LoggerModule()]);

    final loggy = getApi<Loggy>();
    final loggerApi = getApi<LoggerApi>();

    expect(loggy, isA<Loggy>());
    expect(loggerApi, isA<LoggerApiImpl>());
  });
}
