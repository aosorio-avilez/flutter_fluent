import 'package:go_router/go_router.dart';

/// Interface defined to use the fluent navigation functionalities
abstract class InternalNavigationApi {
  /// Get all registered routes
  List<RouteBase> getRegisteredRoutes();
}
