import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter_fluent_logger/src/api/logger_api_impl.dart';
import 'package:loggy/loggy.dart';

/// Register and build all the fluent logger dependencies
class LoggerModule extends FluentModule {
  @override
  void build(Registry registry) {
    registry
      ..registerSingleton<Loggy>(
        (it) => Loggy('loggy')..printer = const PrettyPrinter(),
      )
      ..registerSingleton<LoggerApi>((it) => LoggerApiImpl());
  }
}
