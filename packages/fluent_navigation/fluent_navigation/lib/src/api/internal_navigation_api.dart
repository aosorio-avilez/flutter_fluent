import 'package:fluent_navigation/src/fluent_route.dart';

abstract class InternalNavigationApi {
  List<FluentRoute> getRegisteredRoutes();

  FluentRoute? getInitialRoute();
}
