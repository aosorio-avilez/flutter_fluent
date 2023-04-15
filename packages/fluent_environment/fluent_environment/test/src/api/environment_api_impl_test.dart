import 'package:fluent_environment/fluent_environment.dart';
import 'package:fluent_environment/src/widgets/environment_banner.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widgets/environment_banner_test.dart';

void main() {
  setUpAll(
    () => Fluent.build([
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
