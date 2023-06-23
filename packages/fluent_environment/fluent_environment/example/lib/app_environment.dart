import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';

part 'app_environment.g.dart';

@FluentEnvironment(valueNames: [
  'url',
  'name',
  'debug',
])
class AppEnvironment extends Environment {
  @override
  final String name = "Development";

  @override
  final Color color = Colors.blue;

  @override
  Map<String, String> get values => {
        'url': const String.fromEnvironment('URL'),
        'name': const String.fromEnvironment('URL'),
        'debug': const String.fromEnvironment('URL'),
      };

  @override
  EnvironemntType get type => EnvironemntType.dev;
}
