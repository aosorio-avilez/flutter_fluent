import 'dart:async';

import 'package:flutter_fluent_logger/src/logger_config.dart';
import 'package:flutter_fluent_logger/src/logger_module.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:loggy/loggy.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() async {
    await Fluent.reset();
  });

  group('LoggerModule Security', () {
    test('respects dart.vm.product flag for logging', () async {
      final config = const LoggerConfig(enableLog: true);
      final module = LoggerModule(config: config);

      await Fluent.build([module]);

      final loggy = Fluent.get<Loggy>();

      bool printCalled = false;

      runZoned(() {
        loggy.info('test message');
      }, zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          printCalled = true;
          // output suppressed to keep test output clean
        },
      ));

      const isProduct = bool.fromEnvironment('dart.vm.product');
      expect(printCalled, !isProduct, reason: 'Logging should be disabled in production');
    });
  });
}
