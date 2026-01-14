import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NavigationModule can be instantiated as const', () {
    const module = NavigationModule(
      initialLocation: '/home',
      optionURLReflectsImperativeAPIs: false,
    );
    expect(module, isA<NavigationModule>());
  });
}
