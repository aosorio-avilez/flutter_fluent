import 'package:fluent_environment/fluent_environment.dart';
import 'package:fluent_environment/src/api/environment_api_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widgets/environment_banner_test.dart';

void main() {
  test('environment module should register environment api implementation',
      () async {
    await Fluent.build([EnvironmentModule(environment: EnvironmentMock())]);
    addTearDown(Fluent.reset);

    final api = Fluent.get<EnvironmentApi>();

    expect(api, isA<EnvironmentApiImpl>());
  });
}
