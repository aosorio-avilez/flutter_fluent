import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:get_it/get_it.dart';

class FluentRegistry extends Registry {
  @override
  void registerLazySingleton<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  }) {
    GetIt.instance.registerLazySingleton<T>(
      () => factoryFunction(GetIt.instance),
      instanceName: instanceName,
    );
  }

  @override
  void registerSingleton<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  }) {
    GetIt.instance.registerSingleton<T>(
      factoryFunction(GetIt.instance),
      instanceName: instanceName,
    );
  }

  @override
  void registerFactory<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  }) {
    GetIt.instance.registerFactory(
      () => factoryFunction(GetIt.instance),
      instanceName: instanceName,
    );
  }

  // @override
  // void registerRoute(FluentRoute route) {
  //   var routes = <FluentRoute>[];
  //   if (GetIt.instance.isRegistered<List<FluentRoute>>()) {
  //     routes = GetIt.instance<List<FluentRoute>>();
  //   }
  //   routes.add(route);
  //   allowReassignment(allow: true);
  //   GetIt.instance.registerSingleton<List<FluentRoute>>(routes);
  //   allowReassignment(allow: false);
  // }

  @override
  void allowReassignment({required bool allow}) {
    GetIt.instance.allowReassignment = allow;
  }

  @override
  bool isRegistered<T extends Object>() => GetIt.instance.isRegistered<T>();
}
