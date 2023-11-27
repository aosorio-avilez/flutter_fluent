import 'package:fluent_environment_api/src/environment.dart';

/// Interface defined to use the fluent environment functionalities
abstract class EnvironmentApi {
  /// Get the current registered Environment
  ///
  /// A [AssertionError] maybe thrown if there is no any registered environment
  Environment get environment;
}
