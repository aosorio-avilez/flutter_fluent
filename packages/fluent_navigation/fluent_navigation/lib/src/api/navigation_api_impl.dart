import 'package:fluent_navigation_api/fluent_navigation_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class NavigationApiImpl extends NavigationApi {
  @override
  void navigateTo(
    String routeName, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    Fluent.get<GoRouter>().goNamed(
      routeName,
      extra: extra,
      params: params,
      queryParams: queryParams,
    );
  }

  @override
  Future<T?> pushTo<T>(
    String routeName, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    return Fluent.get<GoRouter>().pushNamed<T>(
      routeName,
      extra: extra,
      params: params,
      queryParams: queryParams,
    );
  }

  @override
  RouterConfig<Object> getConfig() {
    return Fluent.get<GoRouter>();
  }

  @override
  void pop<T>(T? result) {
    if (Fluent.get<GoRouter>().canPop()) {
      Fluent.get<GoRouter>().pop(result);
    }
  }
}
