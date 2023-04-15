import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:get_it/get_it.dart';

class AppRegistry extends Registry {
  @override
  void registerApi<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
    bool lazy = false,
  }) {
    if (lazy) {
      GetIt.instance.registerLazySingleton<T>(
        () => factoryFunction(GetIt.instance),
        instanceName: instanceName,
      );
    } else {
      GetIt.instance.registerSingleton<T>(
        factoryFunction(GetIt.instance),
        instanceName: instanceName,
      );
    }
  }

  @override
  void registerEnvironment(
    Environment environment, {
    String? instanceName,
  }) {
    GetIt.instance.registerSingleton<Environment>(
      environment,
      instanceName: instanceName,
    );
  }

  @override
  void registerRoute(Route route) {
    var routes = <Route>[];
    if (GetIt.instance.isRegistered<List<Route>>()) {
      routes = GetIt.instance<List<Route>>();
    }
    routes.add(route);
    GetIt.instance.registerSingleton<List<Route>>(routes);
  }
}
