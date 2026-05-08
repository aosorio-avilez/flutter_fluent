import 'package:fluent_environment/src/widgets/environment_inspector.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EnvironmentApiImpl extends EnvironmentApi {
  EnvironmentApiImpl(
    Environment environment,
    this.availableEnvironments,
    this.registry,
  ) : _environmentNotifier = ValueNotifier(environment);

  final ValueNotifier<Environment> _environmentNotifier;
  final Registry registry;
  final List<void Function()> _resetters = [];

  @override
  final List<Environment> availableEnvironments;

  @override
  Environment get environment => _environmentNotifier.value;

  @override
  ValueListenable<Environment> get environmentNotifier => _environmentNotifier;

  @override
  void updateEnvironment(Environment environment) {
    _environmentNotifier.value = environment;
    for (final reset in _resetters) {
      reset();
    }
  }

  @override
  void registerResetService<T extends Object>() {
    _resetters.add(() => registry.resetLazySingleton<T>());
  }

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
      showDragHandle: true,
      builder: (context) {
        return EnvironmentInspector(
          environmentApi: this,
          configValuesLabel: configValuesLabel ?? 'Configuration Values',
          noValuesLabel: noValuesLabel ?? 'No configuration values defined.',
        );
      },
    );
  }
}
