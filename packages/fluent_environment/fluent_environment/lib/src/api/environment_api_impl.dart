import 'package:fluent_environment/src/widgets/environment_inspector.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:flutter/material.dart';

class EnvironmentApiImpl extends EnvironmentApi {
  EnvironmentApiImpl(this._environment);

  final Environment _environment;

  @override
  Environment get environment => _environment;

  @override
  Future<void> showInspector(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EnvironmentInspector(environment: _environment);
      },
    );
  }
}
