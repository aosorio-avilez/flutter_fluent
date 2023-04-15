import 'package:flutter_test/flutter_test.dart';
import 'package:loggy/loggy.dart';
import 'package:platform_logger/platform_logger.dart';
import 'package:platform_logger/src/api/logger_api_impl.dart';
import 'package:platform_logger_api/platform_logger_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

void main() {
  test('verify logger module', () async {
    Platform.build([LoggerModule()]);

    final loggy = getApi<Loggy>();
    final loggerApi = getApi<LoggerApi>();

    expect(loggy, isA<Loggy>());
    expect(loggerApi, isA<LoggerApiImpl>());
  });
}
