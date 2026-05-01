import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:fluent_navigation/src/api/internal_navigation_api.dart';

class InternalNavigationApiImpl extends InternalNavigationApi {
  const InternalNavigationApiImpl();

  @override
  List<RouteBase> getRegisteredRoutes() {
    return Fluent.get<List<RouteBase>>();
  }
}
