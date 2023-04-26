import 'package:fluent_navigation/fluent_navigation.dart';

abstract class InternalNavigationApi {
  List<FluentRoute> getRegisteredRoutes();

  FluentRoute? getInitialRoute();
}
