import 'package:fluent_logger/fluent_logger.dart';
import 'package:fluent_logger/src/api/logger_api_impl.dart';
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
