import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';

class AppEnvironment extends Environment {
  @override
  final String name = "Development";

  @override
  final Color color = Colors.blue;

  @override
  Map<String, String> get values => {
        'url': const String.fromEnvironment('URL'),
      };

  @override
  EnvironemntType get type => EnvironemntType.dev;
}
