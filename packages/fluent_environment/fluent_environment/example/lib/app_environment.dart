import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';

class AppEnvironment extends Environment {
  @override
  final String name = "Development";

  @override
  final Color color = Colors.blue;

  @override
  Map<String, String> get values => {
    'url': const String.fromEnvironment('URL', defaultValue: 'https://api.example.com'),
    'api_key': 'abc-123-def-456',
    'debug_mode': 'true',
  };

  @override
  EnvironmentType get type => EnvironmentType.dev;
}
