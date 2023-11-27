import 'package:fluent_environment/fluent_environment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widgets/environment_banner_test.dart';

void main() {
  setUpAll(
    () async {
      await Fluent.build([
        EnvironmentModule(
          environment: EnvironmentMock(),
        ),
      ]);
      addTearDown(Fluent.reset);
    },
  );

  test('verify getEnvironment should return environment', () async {
    final api = Fluent.get<EnvironmentApi>();

    final environment = api.environment;

    expect(environment, isA<Environment>());
  });
}
