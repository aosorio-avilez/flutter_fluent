import 'package:flutter_loggy/flutter_loggy.dart';
import 'package:loggy/loggy.dart';
import 'package:platform_logger/src/api/logger_api_impl.dart';
import 'package:platform_logger_api/platform_logger_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class LoggerModule extends Module {
  LoggerModule({super.testMode = false});

  @override
  void build(Registry registry) {
    registry
      ..registerApi<Loggy>(
        (it) => Loggy('loggy')..printer = const PrettyDeveloperPrinter(),
      )
      ..registerApi<LoggerApi>((it) => LoggerApiImpl());
  }
}
