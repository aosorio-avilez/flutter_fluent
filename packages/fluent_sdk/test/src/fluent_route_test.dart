import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('verify route instance', () async {
    const route = FluentRoute('test', '/test');

    expect(route.name, 'test');
    expect(route.path, '/test');
  });
}
