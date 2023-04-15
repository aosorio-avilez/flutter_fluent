import 'package:collection/collection.dart';
import 'package:platform_navigation/src/api/internal_navigation_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class InternalNavigationApiImpl extends InternalNavigationApi {
  @override
  List<Route> getRegisteredRoutes() {
    return getApi<List<Route>>();
  }

  @override
  Route? getInitialRoute() {
    final routes = getRegisteredRoutes();
    return routes.firstWhereOrNull((element) => element.initial);
  }
}
