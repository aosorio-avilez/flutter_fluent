import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_fluent_logger/src/api/logger_api_impl.dart';
import 'package:loggy/loggy.dart';

/// Register and build all the fluent logger dependencies
class LoggerModule extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    registry
      ..registerSingleton<Loggy>(
        (it) => Loggy('loggy')..printer = const PrettyPrinter(),
      )
      ..registerSingleton<LoggerApi>((it) => LoggerApiImpl());
  }
}
