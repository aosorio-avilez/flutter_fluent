import 'package:fluent_environment/fluent_environment.dart';

class AppEnvironment extends Environment {
  AppEnvironment({this.type = EnvironmentType.prod});

  @override
  final EnvironmentType type;

  @override
  Map<String, String> get values => {
        'url': const String.fromEnvironment('URL'),
      };
}
