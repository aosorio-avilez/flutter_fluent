import 'package:collection/collection.dart';
import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:fluent_navigation/src/fluent_route.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

class InternalNavigationApiImpl extends InternalNavigationApi {
  @override
  List<FluentRoute> getRegisteredRoutes() {
    return Fluent.get<List<FluentRoute>>();
  }

  @override
  FluentRoute? getInitialRoute() {
    final routes = getRegisteredRoutes();
    return routes.firstWhereOrNull((element) => element.initial);
  }
}
