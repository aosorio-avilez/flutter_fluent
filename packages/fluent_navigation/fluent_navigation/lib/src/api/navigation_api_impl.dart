import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class NavigationApiImpl extends NavigationApi {
  /// Internal reference to the registered [GoRouter].
  ///
  /// Lazily initialized on first access to avoid premature instantiation
  /// if [GoRouter] is registered as a lazy singleton.
  late final GoRouter _router = Fluent.get<GoRouter>();

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
