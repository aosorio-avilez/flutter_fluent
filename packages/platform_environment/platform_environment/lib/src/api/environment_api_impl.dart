import 'package:flutter/material.dart';
import 'package:platform_environment/src/widgets/environment_banner.dart';
import 'package:platform_environment_api/platform_environment_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class EnvironmentApiImpl extends EnvironmentApi {
  @override
  Environment getEnvironment() {
    return getApi<Environment>();
  }

  @override
  Widget buildEnvironmentBanner({required Widget child}) {
    return EnvironmentBanner(child: child);
  }
}
