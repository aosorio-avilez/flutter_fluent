import 'package:flutter/widgets.dart';

abstract class NavigationApi {
  void navigateTo(
    String routeName, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  });

  Future<T?> pushTo<T>(
    String routeName, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  });

  RouterConfig<Object> getConfig();
}
