import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_fluent_logger/src/api/logger_api_impl.dart';
import 'package:flutter_fluent_logger/src/logger_config.dart'; // Importar config
import 'package:loggy/loggy.dart';

/// {@template logger_module}
/// A FluentModule that provides logging capabilities using `loggy`.
///
/// It initializes `loggy` with a `PrettyPrinter` if logging is enabled,
/// or a `DisabledPrinter` otherwise. It also registers `Loggy` and
/// `LoggerApi` as singletons in the registry.
/// {@endtemplate}
class LoggerModule extends FluentModule {
  /// {@macro logger_module}
  LoggerModule({
    LoggerConfig? config,
  }) : config = config ?? LoggerConfig();

  /// The configuration for the logger module.
  final LoggerConfig config;

  @override
  Future<void> build(Registry registry) async {
    Loggy.initLoggy(
      logPrinter: config.enableLog
          ? const PrettyPrinter()
          : const DisabledPrinter(),
    );

    registry
      ..registerSingleton<Loggy>((_) {
        return Loggy(config.globalLogName);
      })
      ..registerSingleton<LoggerApi>((it) {
        return LoggerApiImpl(it<Loggy>());
      });
  }
}

/// A [LoggyPrinter] that does nothing, effectively disabling logging output.
class DisabledPrinter extends LoggyPrinter {
  /// Creates a [DisabledPrinter].
  const DisabledPrinter();

  @override
  void onLog(LogRecord record) {
    // Do nothing
  }
}
