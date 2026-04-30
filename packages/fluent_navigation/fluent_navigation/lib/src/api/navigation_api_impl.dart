import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class NavigationApiImpl extends NavigationApi {
  NavigationApiImpl(this._router, this._navigatorKey);

  /// Internal reference to the registered [GoRouter].
  final GoRouter _router;

  final GlobalKey<NavigatorState> _navigatorKey;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  void navigateTo(
    String routeName, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    _router.goNamed(
      routeName,
      extra: extra,
      pathParameters: params,
      queryParameters: queryParams,
    );
  }

  @override
  Future<T?> pushTo<T>(
    String routeName, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    return _router.pushNamed<T>(
      routeName,
      extra: extra,
      pathParameters: params,
      queryParameters: queryParams,
    );
  }

  @override
  RouterConfig<Object> get router => _router;

  @override
  bool canPop() {
    return _router.canPop();
  }

  @override
  void pop<T>([T? result]) {
    if (_router.canPop()) {
      _router.pop(result);
    }
  }
}
