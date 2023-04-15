import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_environment/platform_environment.dart';
import 'package:platform_environment/src/widgets/environment_banner.dart';
import 'package:platform_environment_api/platform_environment_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

import '../widgets/environment_banner_test.dart';

void main() {
  setUpAll(
    () => Platform.build([
      EnvironmentModule(
        EnvironmentMock(),
      )
    ]),
  );

  test('verify getEnvironment should return environment', () async {
    final api = getApi<EnvironmentApi>();

    final environment = api.getEnvironment();

    expect(environment, isA<Environment>());
  });

  test('verify buildEnvironmentBanner should return environment', () async {
    final api = getApi<EnvironmentApi>();

    final banner = api.buildEnvironmentBanner(child: const Scaffold());

    expect(banner, isA<EnvironmentBanner>());
  });
}
