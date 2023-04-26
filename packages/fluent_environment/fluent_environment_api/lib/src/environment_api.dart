import 'package:fluent_environment_api/src/environment.dart';
import 'package:flutter/material.dart';

/// Interface defined to use the fluent environment functionalities
abstract class EnvironmentApi {
  /// Get the current registered Environment
  ///
  /// A [AssertionError] maybe thrown if there is no any registered environment
  Environment getEnvironment();

  /// Build and return the  environment banner widget
  /// And wrap the child widget with it
  Widget buildEnvironmentBanner({required Widget child});
}
