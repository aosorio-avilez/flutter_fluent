import 'package:fluent_environment_api/src/environment_type.dart';
import 'package:flutter/material.dart';

/// Environment base clase
abstract class Environment {
  Color get color;

  String get name;

  EnvironemntType get type;

  Map<String, String> get values => {};
}
