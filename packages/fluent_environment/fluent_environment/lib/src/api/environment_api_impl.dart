import 'package:fluent_environment/src/widgets/environment_banner.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';

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
