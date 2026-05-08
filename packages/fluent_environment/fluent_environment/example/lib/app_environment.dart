import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter/material.dart';

class DevEnvironment extends Environment {
  @override
  String get name => "Development";

  @override
  Color get color => Colors.blue;

  @override
  Map<String, String> get values => {
    'url': 'https://dev-api.example.com',
    'api_key': 'dev-key-123',
    'debug_mode': 'true',
  };

  @override
  EnvironmentType get type => EnvironmentType.dev;
}

class StagingEnvironment extends Environment {
  @override
  String get name => "Staging";

  @override
  Color get color => Colors.orange;

  @override
  Map<String, String> get values => {
    'url': 'https://stg-api.example.com',
    'api_key': 'stg-key-456',
    'debug_mode': 'true',
  };

  @override
  EnvironmentType get type => EnvironmentType.stg;
}

class ProdEnvironment extends Environment {
  @override
  String get name => "Production";

  @override
  Color get color => Colors.green;

  @override
  Map<String, String> get values => {
    'url': 'https://api.example.com',
    'api_key': 'prod-key-789',
    'debug_mode': 'false',
  };

  @override
  EnvironmentType get type => EnvironmentType.prod;
}
