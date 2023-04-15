import 'package:flutter_test/flutter_test.dart';
import 'package:platform_environment/platform_environment.dart';
import 'package:platform_environment/src/api/environment_api_impl.dart';
import 'package:platform_environment_api/platform_environment_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

import 'widgets/environment_banner_test.dart';

void main() {
  test('environment module should register environment api implementation',
      () async {
    Platform.build([EnvironmentModule(EnvironmentMock())]);

    final api = getApi<EnvironmentApi>();

    expect(api, isA<EnvironmentApiImpl>());
  });
}
