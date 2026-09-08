import 'package:fluent_navigation/src/utils/fluent_navigator_observer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FluentNavigatorObserver observer;

  setUp(() {
    observer = FluentNavigatorObserver();
  });

  PageRouteBuilder<void> buildRoute({String? name}) {
    return PageRouteBuilder<void>(
      settings: RouteSettings(name: name),
      pageBuilder: (_, _, _) => const SizedBox(),
    );
  }

  test('initial state has empty stack and root currentPath', () {
    expect(observer.currentRoute, isNull);
    expect(observer.currentPath, equals('/'));
  });

  test('didPush adds route and notifies listeners', () {
    var notifications = 0;
    observer.addListener(() => notifications++);

    final route = buildRoute(name: '/home');

    observer.didPush(route, null);

    expect(observer.currentRoute, equals(route));
    expect(observer.currentPath, equals('/home'));
    expect(notifications, equals(1));
  });

  test('currentPath prepends leading slash if missing', () {
    final route = buildRoute(name: 'dashboard');

    observer.didPush(route, null);

    expect(observer.currentPath, equals('/dashboard'));
  });

  test(
    'currentPath maintains underlying page path when unnamed dialog is pushed',
    () {
      final pageRoute = buildRoute(name: '/connect-vehicle');
      final dialogRoute = buildRoute(); // no name

      observer
        ..didPush(pageRoute, null)
        ..didPush(dialogRoute, pageRoute);

      expect(observer.currentRoute, equals(dialogRoute));
      expect(observer.currentPath, equals('/connect-vehicle'));
    },
  );

  test('didPop removes route and notifies listeners', () {
    var notifications = 0;
    observer.addListener(() => notifications++);

    final route1 = buildRoute(name: '/first');
    final route2 = buildRoute(name: '/second');

    observer
      ..didPush(route1, null)
      ..didPush(route2, route1);

    expect(observer.currentPath, equals('/second'));
    expect(notifications, equals(2));

    observer.didPop(route2, route1);

    expect(observer.currentRoute, equals(route1));
    expect(observer.currentPath, equals('/first'));
    expect(notifications, equals(3));
  });

  test('didRemove removes route and notifies listeners', () {
    var notifications = 0;
    observer.addListener(() => notifications++);

    final route1 = buildRoute(name: '/first');
    final route2 = buildRoute(name: '/second');

    observer
      ..didPush(route1, null)
      ..didPush(route2, route1)
      ..didRemove(route1, null);

    expect(observer.currentRoute, equals(route2));
    expect(observer.currentPath, equals('/second'));
    expect(notifications, equals(3));
  });

  test('didReplace replaces oldRoute with newRoute and notifies listeners', () {
    var notifications = 0;
    observer.addListener(() => notifications++);

    final route1 = buildRoute(name: '/first');
    final route2 = buildRoute(name: '/replaced');

    observer
      ..didPush(route1, null)
      ..didReplace(newRoute: route2, oldRoute: route1);

    expect(observer.currentRoute, equals(route2));
    expect(observer.currentPath, equals('/replaced'));
    expect(notifications, equals(2));
  });

  test('didReplace handles oldRoute not in stack or null oldRoute', () {
    final route1 = buildRoute(name: '/first');
    final notInStack = buildRoute(name: '/ghost');
    final route2 = buildRoute(name: '/added');
    final route3 = buildRoute(name: '/added3');

    observer
      ..didPush(route1, null)
      ..didReplace(newRoute: route2, oldRoute: notInStack);

    expect(observer.currentRoute, equals(route2));
    expect(observer.currentPath, equals('/added'));

    observer.didReplace(newRoute: route3);
    expect(observer.currentRoute, equals(route3));
  });
}
