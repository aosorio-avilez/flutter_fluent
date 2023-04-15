import 'package:fluent_sdk/fluent_sdk.dart';

abstract class InternalNavigationApi {
  List<Route> getRegisteredRoutes();

  Route? getInitialRoute();
}
