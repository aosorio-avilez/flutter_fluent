import 'package:flutter_test/flutter_test.dart';
import 'package:platform_sdk/platform_sdk.dart';

void main() {
  test('verify route instance', () async {
    const route = Route('test', '/test');

    expect(route.name, 'test');
    expect(route.path, '/test');
    expect(route.props, [
      'test',
      '/test',
      null,
      null,
      false,
    ]);
  });
}
