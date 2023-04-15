import 'package:flutter/material.dart';
import 'package:platform_sdk/platform_sdk.dart';

abstract class EnvironmentApi {
  Environment getEnvironment();

  Widget buildEnvironmentBanner({required Widget child});
}
