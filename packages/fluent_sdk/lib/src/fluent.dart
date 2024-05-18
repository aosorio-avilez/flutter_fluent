import 'package:fluent_sdk/src/api/fluent_module.dart';
import 'package:fluent_sdk/src/api/registry.dart';
import 'package:fluent_sdk/src/fluent_registry.dart';
import 'package:get_it/get_it.dart';

class Fluent {
  static final Registry _registry = FluentRegistry();

  /// Builds a list of fluent modules
  ///
  /// This method takes a list of [FluentModule] and builds them
  /// by calling their [build] method with the [_registry] instance.
  ///
  /// It returns a [Future] that completes when all modules have been
  /// built.
  static Future<void> build(List<FluentModule> modules) async {
    /// Build each module
    final futures = modules.map((module) => module.build(_registry));

    /// Wait for all modules to be built
    await Future.wait<void>(futures.toList());
  }

  /// Reset the [GetIt] instance, removing all registered objects.
  ///
  /// This method is useful for testing purposes, as it allows you to reset
  /// the state of the [GetIt] instance.
  ///
  /// It returns a [Future] that completes when all registered objects have
  /// been removed.
  static Future<void> reset() async {
    /// Reset the [GetIt] instance, removing all registered objects.
    return GetIt.instance.reset();
  }

  /// Gets an instance of a registered object
  ///
  /// This method is a shorthand for [GetIt.instance.get].
  ///
  /// It returns the instance of the type [T] that was registered with
  /// [GetIt].
  ///
  /// If no instance is registered, it throws a [StateError].
  static T get<T extends Object>() {
    /// Gets an instance of a registered object
    return GetIt.instance<T>();
  }

  /// Allows you to register a mock class of a registered object
  ///
  /// This method is useful for testing purposes, as it allows you to
  /// register a mock implementation of a registered object.
  ///
  /// It takes a single argument, [mock], which is the mock object to
  /// be registered.
  ///
  /// It first calls [GetIt.allowReassignment] to allow the object to be
  /// reassigned, then it calls [GetIt.registerSingleton] to register the
  /// mock object, and finally it calls [GetIt.allowReassignment] again to
  /// disallow the object from being reassigned.
  static void mock<T extends Object>(T mock) {
    /// Allows you to register a mock class of a registered object
    _registry

      /// Allow the object to be reassigned
      ..allowReassignment(allow: true)

      /// Register the mock object
      ..registerSingleton<T>((it) => mock)

      /// Disallow the object from being reassigned
      ..allowReassignment(allow: false);
  }
}
