import 'package:flutter/material.dart';

/// Environment base clase
abstract class Environment {
  Color get color;

  String get name;

  Map<String, String> get values;
}
