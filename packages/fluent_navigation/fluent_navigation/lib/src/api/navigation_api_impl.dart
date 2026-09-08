import 'package:fluent_navigation/src/utils/fluent_navigator_observer.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class NavigationApiImpl extends NavigationApi {
  NavigationApiImpl(this._router, this._navigatorKey, this._observer);

  /// Internal reference to the registered [GoRouter].
  final GoRouter _router;

  final GlobalKey<NavigatorState> _navigatorKey;

  final FluentNavigatorObserver _observer;

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
  Future<void> replaceWith(
    String routeName, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) async {
    await _router.replaceNamed<void>(
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

  @override
  void popUntil(String routeName) {
    _navigatorKey.currentState?.popUntil((route) {
      return route.settings.name == routeName ||
          route.settings.name == '/$routeName' ||
          route.isFirst;
    });
  }

  @override
  String get currentPath => _observer.currentPath;

  @override
  String get currentLocation {
    final uri = _router.routerDelegate.currentConfiguration.uri;
    if (uri.path == _observer.currentPath ||
        uri.toString() == _observer.currentPath) {
      return uri.toString();
    }
    return _observer.currentPath;
  }

  @override
  Listenable get routeListenable => _observer;
}
