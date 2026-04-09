/// Defines the contract for dependency registration.
abstract class Registry {
  /// Controls whether registered singletons can be overridden.
  /// Typically used internally for mocking support.
  void allowReassignment({required bool allow});

  /// Registers a Lazy Singleton.
  ///
  /// The [factoryFunction] is invoked only when the instance
  /// is requested for the first time.
  void registerLazySingleton<T extends Object>(
    T Function(Registry i) factoryFunction, {
    String? instanceName,
  });

  /// Registers a Singleton.
  ///
  /// The [factoryFunction] is invoked immediately upon registration.
  void registerSingleton<T extends Object>(
    T Function(Registry i) factoryFunction, {
    String? instanceName,
  });

  /// Registers a Factory.
  ///
  /// The [factoryFunction] is invoked every time [Fluent.get] is called.
  void registerFactory<T extends Object>(
    T Function(Registry i) factoryFunction, {
    String? instanceName,
  });

  /// Checks if a type [T] is currently registered in the container.
  bool isRegistered<T extends Object>();

  /// Retrieves an instance of a registered object [T].
  T get<T extends Object>({String? instanceName});

  /// Callable interface to retrieve an instance.
  T call<T extends Object>();
}
