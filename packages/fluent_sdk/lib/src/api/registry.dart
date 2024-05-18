import 'package:get_it/get_it.dart';

abstract class Registry {
  /// Allows or disallows the reassignment of a singleton object.
  ///
  /// This method is useful for testing purposes, as it allows you to
  /// register a mock implementation of a registered object.
  ///
  /// It takes a single argument, [allow], which is a boolean that
  /// indicates whether the reassignment of a singleton object is allowed.
  ///
  /// If [allow] is true, it allows the reassignment of a singleton
  /// object. If [allow] is false, it disallows the reassignment of a
  /// singleton object.
  ///
  /// By default, the reassignment of a singleton object is disallowed.
  void allowReassignment({required bool allow});

  /// Registers a new lazy singleton object
  ///
  /// This method takes a single argument, [factoryFunction], which is a
  /// function that returns an instance of the type [T].
  ///
  /// It also takes an optional argument, [instanceName], which is the name
  /// of the instance to be registered.
  ///
  /// [factoryFunction] is a function that returns an instance of the
  /// type [T].
  ///
  /// [instanceName] is the name of the instance to be registered.
  void registerLazySingleton<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  });

  /// Registers a new singleton object
  ///
  /// This method takes a single argument, [factoryFunction], which is a
  /// function that returns an instance of the type [T].
  ///
  /// It also takes an optional argument, [instanceName], which is the name
  /// of the instance to be registered.
  ///
  /// [factoryFunction] is a function that returns an instance of the
  /// type [T].
  ///
  /// [instanceName] is the name of the instance to be registered.
  ///
  /// If [instanceName] is not provided, the instance will be registered
  /// with the default name, which is the type of [T].
  void registerSingleton<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  });

  /// Registers a new factory object
  ///
  /// This method takes a single argument, [factoryFunction], which is a
  /// function that returns an instance of the type [T].
  ///
  /// It also takes an optional argument, [instanceName], which is the name
  /// of the instance to be registered.
  ///
  /// [factoryFunction] is a function that returns an instance of the
  /// type [T].
  ///
  /// [instanceName] is the name of the instance to be registered.
  ///
  /// If [instanceName] is not provided, the instance will be registered
  /// with the default name, which is the type of [T].
  ///
  /// This method is useful when you want to register a factory that will
  /// be used to create objects of type [T].
  void registerFactory<T extends Object>(
    T Function(GetIt) factoryFunction, {
    String? instanceName,
  });

  /// Checks if an instance of type [T] is registered.
  ///
  /// It returns true if an instance of type [T] is registered, and false
  /// otherwise.
  ///
  /// [T] is the type of the instance to be checked.
  bool isRegistered<T extends Object>() {
    /// Checks if an instance of type [T] is registered.
    return GetIt.instance.isRegistered<T>();
  }
}
