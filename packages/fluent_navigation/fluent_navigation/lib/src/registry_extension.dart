import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:go_router/go_router.dart';

extension RegistryExtension on Registry {
  /// Function that allows you to register
  /// A route that will be available
  /// to navigate later through the navigation api
  void registerRoute(GoRoute route) {
    var routes = <GoRoute>[];
    if (isRegistered<List<GoRoute>>()) {
      routes = Fluent.get<List<GoRoute>>();
    }
    routes.add(route);
    allowReassignment(allow: true);
    registerSingleton<List<GoRoute>>((it) => routes);
    allowReassignment(allow: false);
  }
}
