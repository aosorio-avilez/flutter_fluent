import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:go_router/go_router.dart';

typedef FluentRoutes = List<RouteBase>;

extension RegistryExtension on Registry {
  /// Function that allows you to register
  /// A route that will be available
  /// to navigate later through the navigation api
  void registerRoute(RouteBase route) {
    if (!isRegistered<FluentRoutes>()) {
      registerSingleton<FluentRoutes>((_) => <RouteBase>[]);
    }
    get<FluentRoutes>().add(route);
  }
}
