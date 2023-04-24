import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:flutter_fluent_logger/src/api/logger_api_impl.dart';
import 'package:flutter_loggy/flutter_loggy.dart';
import 'package:loggy/loggy.dart';

class LoggerModule extends Module {
  @override
  void build(Registry registry) {
    registry
      ..registerApi<Loggy>(
        (it) => Loggy('loggy')..printer = const PrettyDeveloperPrinter(),
      )
      ..registerApi<LoggerApi>((it) => LoggerApiImpl());
  }
}
