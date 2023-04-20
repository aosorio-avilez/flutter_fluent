import 'package:fluent_navigation_api/fluent_navigation_api.dart';

abstract class InternalNavigationApi {
  List<Route> getRegisteredRoutes();

  Route? getInitialRoute();
}
