import 'package:fluent_navigation/src/fluent_route.dart';
import 'package:fluent_navigation_api/fluent_navigation_api.dart';

extension RegistryExtension on Registry {
  void registerRoute(FluentRoute route) {
    var routes = <FluentRoute>[];
    if (isRegistered<List<FluentRoute>>()) {
      routes = Fluent.get<List<FluentRoute>>();
    }
    routes.add(route);
    allowReassignment(allow: true);
    registerSingleton<List<FluentRoute>>((it) => routes);
    allowReassignment(allow: false);
  }
}
