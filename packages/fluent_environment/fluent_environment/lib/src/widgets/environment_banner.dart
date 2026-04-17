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

  @override
  Widget build(BuildContext context) {
    final envApi = Fluent.get<EnvironmentApi>();
    final env = environment ?? envApi.environment;

    if (env.isProduction) {
      return child;
    }

    Widget content = Banner(
      color: env.color,
      message: env.name,
      location: location,
      textStyle: const TextStyle(
        fontSize: 10.2,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
      child: child,
    );

    if (enableInspector) {
      content = GestureDetector(
        onLongPress: () => envApi.showInspector(context),
        child: content,
      );
    }

    return Semantics(
      label: 'Environment: ${env.name}',
      container: true,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: content,
      ),
    );
  }
}
