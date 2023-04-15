import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_navigation_api/platform_navigation_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class NavigationApiImpl extends NavigationApi {
  @override
  void navigateTo(
    String routeName, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) {
    getApi<GoRouter>().goNamed(
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
    return getApi<GoRouter>().pushNamed<T>(
      routeName,
      extra: extra,
      params: params,
      queryParams: queryParams,
    );
  }

  @override
  RouterConfig<Object> getConfig() {
    return getApi<GoRouter>();
  }
}
