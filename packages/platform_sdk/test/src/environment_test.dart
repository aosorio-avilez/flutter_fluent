import 'package:flutter_test/flutter_test.dart';
import 'package:platform_sdk/platform_sdk.dart';

import 'mocks/test_environment.dart';

void main() {
  test('verify environment instance', () async {
    final environment = TestEnvironment();

    expect(environment, isA<Environment>());
  });
}
