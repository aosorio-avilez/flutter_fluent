import 'package:fluent_sdk/fluent_sdk.dart';

abstract class FluentModule {
  /// Builds the module.
  ///
  /// This method is called by [Fluent] to build the module. It takes
  /// a single argument, [registry], which is the [Registry] instance
  /// used to register objects.
  ///
  /// It returns a [Future] that completes when the module has been
  /// built.
  ///
  /// You should call [Registry.registerFactory], [Registry.registerSingleton],
  /// or [Registry.registerLazySingleton] to register objects with the
  /// [Registry].
  ///
  /// You can also call [Registry.allowReassignment] to allow objects
  /// to be reassigned.
  Future<void> onCreate(Registry registry);

  /// Called after all modules have been built.
  ///
  /// Use this method to execute logic that requires other modules to be
  /// registered, such as initializing services that depend on others.
  Future<void> onStart() async {}

  /// Called before the registry is reset.
  ///
  /// Use this method to dispose of resources, close streams, or perform
  /// cleanup tasks.
  Future<void> onStop() async {}
}
