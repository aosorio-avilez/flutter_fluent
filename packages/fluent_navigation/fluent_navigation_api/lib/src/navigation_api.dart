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

  /// Get the router configuration
  RouterConfig<Object> getConfig();
}
