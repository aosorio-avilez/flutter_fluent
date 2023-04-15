import 'package:fluent_sdk/src/api/environment.dart';
import 'package:fluent_sdk/src/route.dart';
import 'package:get_it/get_it.dart';

abstract class Registry {
  void registerApi<T extends Object>(
    T Function(GetIt it) factoryFunction, {
    String? instanceName,
    bool lazy = false,
  });

  void registerEnvironment(
    Environment environment, {
    String? instanceName,
  });

  void registerRoute(Route route);
}
