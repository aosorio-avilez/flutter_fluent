import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() async {
    await Fluent.reset();
  });

  group('NetworkingModule Security', () {
    test('respects dart.vm.product flag for logging', () async {
      final config = NetworkingConfig(enableLog: true);
      final module = NetworkingModule(config: config);

      await Fluent.build([module]);

      final dio = Fluent.get<Dio>();
      final hasPrettyLogger = dio.interceptors.any((i) => i is PrettyDioLogger);

      const isProduct = bool.fromEnvironment('dart.vm.product');
      expect(hasPrettyLogger, !isProduct);
    });
  });
}
