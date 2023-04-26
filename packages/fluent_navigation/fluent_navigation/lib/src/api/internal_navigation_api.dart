import 'package:fluent_navigation/src/fluent_route.dart';

/// Interface defined to use the fluent navigation functionalities
abstract class InternalNavigationApi {
  /// Get all registered routes
  List<FluentRoute> getRegisteredRoutes();

  /// Get the initial route if exists or null if not
  FluentRoute? getInitialRoute();
}
