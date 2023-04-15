import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';

abstract class EnvironmentApi {
  Environment getEnvironment();

  Widget buildEnvironmentBanner({required Widget child});
}
