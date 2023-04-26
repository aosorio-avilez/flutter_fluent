import 'package:get_it/get_it.dart';

/// Interface defined to register module dependencies
abstract class Registry {
  /// Enable/Disable the ability to register a new object
  /// although the object is already registered
  void allowReassignment({required bool allow});

  /// Register a new lazy singleton object
  void registerLazySingleton<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  });

  /// Register a new singleton object
  void registerSingleton<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  });

  /// Register a new factory object
  void registerFactory<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  });

  /// Return if an object is already registered or not
  bool isRegistered<T extends Object>();
}
