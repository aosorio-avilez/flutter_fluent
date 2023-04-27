import 'package:fluent_sdk/src/api/fluent_module.dart';
import 'package:fluent_sdk/src/api/registry.dart';
import 'package:fluent_sdk/src/fluent_registry.dart';
import 'package:get_it/get_it.dart';

/// Main class or the framework
class Fluent {
  static final Registry _registry = FluentRegistry();

  /// Allow you to build a list of fluent modules
  static Future<void> build(List<FluentModule> modules) async {
    final getIt = GetIt.instance;

    for (final module in modules) {
      getIt.pushNewScope();
      module.build(_registry);
    }
  }

  /// Clear all the registered objects
  static Future<void> reset() async {
    return GetIt.instance.reset();
  }

  /// Get a specific registered object
  static T get<T extends Object>() {
    return GetIt.instance<T>();
  }

  /// Allows you to register a mock class of a registered object
  static void mock<T extends Object>(T mock) {
    _registry
      ..allowReassignment(allow: true)
      ..registerSingleton<T>((it) => mock)
      ..allowReassignment(allow: false);
  }
}
