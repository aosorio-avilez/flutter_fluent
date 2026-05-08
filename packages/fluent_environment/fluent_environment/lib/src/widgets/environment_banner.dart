import 'dart:async';

import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';

/// A widget that displays an environment banner if
/// the current environment is not production.
///
/// This widget wraps its [child] and, if the detected or provided [environment]
/// is not production, it overlays a [Banner]
/// with the environment's name and color.
/// The banner's [location] can be customized, defaulting to the bottom-end.
class EnvironmentBanner extends StatelessWidget {
  /// Creates an [EnvironmentBanner].
  ///
  /// The [child] widget is always required.
  /// The [environment] can be optionally provided; if null, it defaults to
  /// the environment retrieved from `Fluent.get<EnvironmentApi>()`.
  /// The [location] determines where the banner is displayed.
  const EnvironmentBanner({
    required this.child,
    this.environment,
    this.location = BannerLocation.bottomEnd,
    this.enableInspector = false,
    this.configValuesLabel,
    this.noValuesLabel,
    this.navigatorKey,
    this.textStyle,
    super.key,
  });

  /// The widget below this widget in the tree.
  ///
  /// This is the content that the environment banner will overlay.
  final Widget child;

  /// The environment to display.
  ///
  /// If `null`, the environment will be retrieved from the `Fluent` instance
  /// using `Fluent.get<EnvironmentApi>().environment`.
  final Environment? environment;

  /// The location of the banner.
  final BannerLocation location;

  /// Whether to enable the environment inspector on long press.
  final bool enableInspector;

  /// The label for the configuration values section in the inspector.
  final String? configValuesLabel;

  /// The message to display when no configuration values are defined.
  final String? noValuesLabel;

  /// The navigator key to use when showing the inspector.
  ///
  /// This is required if the banner is used in [MaterialApp.builder] or any
  /// context that is not a descendant of a [Navigator].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The text style of the banner.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final envApi = Fluent.get<EnvironmentApi>();

    return ValueListenableBuilder<Environment>(
      valueListenable: envApi.environmentNotifier,
      builder: (context, currentEnvironment, _) {
        final env = environment ?? currentEnvironment;

        if (env.isProduction) {
          return child;
        }

        Widget content = Banner(
          color: env.color,
          message: env.name,
          location: location,
          textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
          layoutDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
          textStyle: textStyle ??
              const TextStyle(
                fontSize: 10.2,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
          child: child,
        );

        if (enableInspector) {
          content = Stack(
            children: [
              content,
              Positioned.fill(
                child: Align(
                  alignment: _getAlignmentFromLocation(location),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () {
                      unawaited(
                        envApi.showInspector(
                          context,
                          configValuesLabel: configValuesLabel,
                          noValuesLabel: noValuesLabel,
                          navigatorKey: navigatorKey,
                        ),
                      );
                    },
                    child: const SizedBox(
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Semantics(
          label: 'Environment: ${env.name}',
          container: true,
          child: content,
        );
      },
    );
  }

  Alignment _getAlignmentFromLocation(BannerLocation location) {
    switch (location) {
      case BannerLocation.topStart:
        return Alignment.topLeft;
      case BannerLocation.topEnd:
        return Alignment.topRight;
      case BannerLocation.bottomStart:
        return Alignment.bottomLeft;
      case BannerLocation.bottomEnd:
        return Alignment.bottomRight;
    }
  }
}
