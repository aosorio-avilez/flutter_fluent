import 'package:fluent_sdk/src/api/fluent_module.dart';
import 'package:test/test.dart';

import '../mocks/test_module.dart';

void main() {
  test('verify module', () async {
    final module = TestModule();

    expect(module, isA<FluentModule>());
  });
}
