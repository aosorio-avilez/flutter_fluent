import 'package:fluent_environment_api/src/environment.dart';
import 'package:flutter/material.dart';

abstract class EnvironmentApi {
  Environment getEnvironment();

  Widget buildEnvironmentBanner({required Widget child});
}
