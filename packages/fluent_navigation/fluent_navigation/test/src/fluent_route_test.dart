import 'package:fluent_navigation/src/fluent_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('verify route instance', () async {
    const route = FluentRoute('test', '/test');

    expect(route.name, 'test');
    expect(route.path, '/test');
  });
}
