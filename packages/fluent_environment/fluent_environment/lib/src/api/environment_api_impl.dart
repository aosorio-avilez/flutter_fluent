import 'package:fluent_environment/src/widgets/environment_inspector.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:flutter/material.dart';

class EnvironmentApiImpl extends EnvironmentApi {
  EnvironmentApiImpl(this._environment);

  final Environment _environment;

  @override
  Environment get environment => _environment;

  @override
  Future<void> showInspector(
    BuildContext context, {
    String? configValuesLabel,
    String? noValuesLabel,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    final effectiveContext = navigatorKey?.currentContext ?? context;

    return showModalBottomSheet<void>(
      context: effectiveContext,
      isScrollControlled: true,
      builder: (context) {
        return EnvironmentInspector(
          environment: _environment,
          configValuesLabel: configValuesLabel ?? 'Configuration Values',
          noValuesLabel: noValuesLabel ?? 'No configuration values defined.',
        );
      },
    );
  }
}
