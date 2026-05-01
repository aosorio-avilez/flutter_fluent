import 'package:flutter/widgets.dart';

/// Interface defined to use the fluent navigation functionalities
abstract class NavigationApi {
  /// Navigate to a named route with optional parameters,
  /// query parameters and an extra object.
  void navigateTo(
    String routeName, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  });

  /// Push a named route onto the page stack with optional parameters,
  /// query parameters and an extra object
  ///
  /// And return a Future of of optional T generi type
  Future<T?> pushTo<T>(
    String routeName, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  });

  /// Replace the current route with a named route with optional parameters,
  /// query parameters and an extra object.
  Future<void> replaceWith(
    String routeName, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  });

  /// Checks if the current route can be popped.
  ///
  /// Returns `true` if there is a previous route to pop to, `false` otherwise.
  bool canPop();

  /// Pop the last route off the current screen
  /// And pass it an optional result.
  void pop<T>([T? result]);

  /// Get the router configuration
  RouterConfig<Object> get router;

  /// Get the navigator key
  GlobalKey<NavigatorState> get navigatorKey;
}
