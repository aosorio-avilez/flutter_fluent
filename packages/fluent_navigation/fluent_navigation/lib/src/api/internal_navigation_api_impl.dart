import 'package:fluent_navigation/src/api/internal_navigation_api.dart';
import 'package:go_router/go_router.dart';

class InternalNavigationApiImpl extends InternalNavigationApi {
  const InternalNavigationApiImpl(this._routes);

  final List<RouteBase> _routes;

  @override
  List<RouteBase> getRegisteredRoutes() {
    return _routes;
  }
}
