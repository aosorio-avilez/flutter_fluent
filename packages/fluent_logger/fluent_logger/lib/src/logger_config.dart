class LoggerConfig {
  /// Creates a configuration for the Logger module.
  ///
  /// [enableLog]: If true, logs will be printed to the console.
  /// usually controlled by `kDebugMode` in Flutter apps.
  /// [globalLogName]: The tag used for the logs (defaults to 'App').
  const LoggerConfig({
    this.enableLog = false,
    this.globalLogName = 'App',
  });

  /// If true, logs will be printed to the console.
  /// usually controlled by `kDebugMode` in Flutter apps.
  final bool enableLog;

  /// The tag used for the logs (defaults to 'App').
  final String globalLogName;
}
