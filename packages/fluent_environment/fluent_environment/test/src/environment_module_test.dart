import 'package:fluent_environment/fluent_environment.dart';
import 'package:fluent_environment/src/api/environment_api_impl.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widgets/environment_banner_test.dart';

void main() {
  test('environment module should register environment api implementation',
      () async {
    Fluent.build([EnvironmentModule(EnvironmentMock())]);

    final api = getApi<EnvironmentApi>();

    expect(api, isA<EnvironmentApiImpl>());
  });
}
