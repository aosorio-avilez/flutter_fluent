import 'package:collection/collection.dart';
import 'package:platform_navigation/src/api/internal_navigation_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class InternalNavigationApiImpl extends InternalNavigationApi {
  @override
  List<Route> getRegisteredRoutes() {
    return GetIt.instance<List<Route>>();
  }

  @override
  Route? getInitialRoute() {
    var routes = <Route>[];

    if (GetIt.instance.isRegistered<List<Route>>()) {
      routes = GetIt.instance<List<Route>>();
    }

    return routes.firstWhereOrNull((element) => element.initial);
  }
}
