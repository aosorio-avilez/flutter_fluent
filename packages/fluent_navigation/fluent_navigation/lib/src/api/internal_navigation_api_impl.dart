import 'package:fluent_navigation/src/api/internal_navigation_api.dart';

import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:go_router/go_router.dart';

class InternalNavigationApiImpl extends InternalNavigationApi {
  @override
  List<RouteBase> getRegisteredRoutes() {
    return Fluent.get<List<RouteBase>>();
  }
}
