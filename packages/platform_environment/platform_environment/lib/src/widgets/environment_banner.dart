import 'package:flutter/material.dart';
import 'package:platform_environment_api/platform_environment_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class EnvironmentBanner extends StatelessWidget {
  const EnvironmentBanner({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final environment = getApi<EnvironmentApi>().getEnvironment();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Banner(
        color: environment.type.color,
        message: environment.type.description,
        location: BannerLocation.bottomEnd,
        textStyle: const TextStyle(
          fontSize: 12.0 * 0.85,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
        child: child,
      ),
    );
  }
}
