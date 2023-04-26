import 'package:fluent_sdk/src/fluent_route.dart';
import 'package:get_it/get_it.dart';

abstract class Registry {
  void allowReassignment({required bool allow});

  void registerLazySingleton<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  });

  void registerSingleton<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  });

  void registerFactory<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  });

  void registerRoute(FluentRoute route);
}
