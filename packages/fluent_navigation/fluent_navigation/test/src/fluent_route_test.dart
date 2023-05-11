import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('verify route instance', () async {
    final route = GoRoute(
      name: 'test',
      path: '/test',
      builder: (context, state) => const Scaffold(),
    );

    expect(route.name, 'test');
    expect(route.path, '/test');
  });
}
