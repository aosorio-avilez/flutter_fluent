import 'package:platform_sdk/platform_sdk.dart';

abstract class InternalNavigationApi {
  List<Route> getRegisteredRoutes();

  Route? getInitialRoute();
}
