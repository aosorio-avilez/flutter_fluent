import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  test('Exported classes are available', () {
    // This test simply verifies that these classes can be referenced
    // and thus are exported by the package.
    expect(GoRoute, isNotNull);
    expect(ShellRoute, isNotNull);
    expect(RouteBase, isNotNull);
    expect(CustomTransitionPage, isNotNull);
    expect(GoRouterState, isNotNull);
  });

  test('Can instantiate GoRoute', () {
     final route = GoRoute(path: '/', builder: (_, __) => const SizedBox());
     expect(route, isA<GoRoute>());
  });
}
