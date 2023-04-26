import 'package:flutter/material.dart';

abstract class Environment {
  Color get color;

  String get name;

  Map<String, String> get values;
}
