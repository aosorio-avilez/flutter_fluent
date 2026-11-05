import 'dart:async';

import 'package:fluent_cms/src/api/cms_api_impl.dart';
import 'package:fluent_cms/src/cms_config.dart';
import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';

/// [FluentModule] that registers [CmsApi] lazily and integrates with
/// `fluent_environment_api`, `fluent_networking_api`, and `fluent_logger_api`
/// when present in the [Registry].
class CmsModule extends FluentModule {
  /// Creates a [CmsModule] with an optional [config].
  const CmsModule({
    this.config = const CmsConfig(),
  });

  /// Global configuration for the CMS engine.
  final CmsConfig config;

  @override
  FutureOr<void> onCreate(Registry registry) {
    registry.registerLazySingleton<CmsApi>(
      (it) {
        final logger = it.isRegistered<LoggerApi>()
            ? it.get<LoggerApi>()
            : null;
        final networking = it.isRegistered<NetworkingApi>()
            ? it.get<NetworkingApi>()
            : null;

        return CmsApiImpl(
          config: config,
          logger: logger,
          networkingApi: networking,
        );
      },
    );

    if (registry.isRegistered<EnvironmentApi>()) {
      final envApi = registry.get<EnvironmentApi>()
        ..registerResetService<CmsApi>();

      if (!const bool.fromEnvironment('dart.vm.product')) {
        envApi
          ..registerAction(
            EnvironmentAction(
              label: 'Toggle CMS Zone Debug Borders',
              icon: Icons.grid_on,
              onTap: (_) {
                if (registry.isRegistered<CmsApi>()) {
                  registry.get<CmsApi>().toggleDebugZoneBorders();
                }
              },
            ),
          )
          ..registerAction(
            EnvironmentAction(
              label: 'Flush CMS Page Cache',
              icon: Icons.delete_sweep,
              onTap: (_) {
                if (registry.isRegistered<CmsApi>()) {
                  registry.get<CmsApi>().clearCache();
                }
              },
            ),
          );
      }
    }
  }
}
