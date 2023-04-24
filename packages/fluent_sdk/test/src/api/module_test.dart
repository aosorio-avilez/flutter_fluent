import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/test_module.dart';

void main() {
  testWidgets('verify module', (tester) async {
    final module = TestModule();

    expect(module, isA<Module>());
  });
}
