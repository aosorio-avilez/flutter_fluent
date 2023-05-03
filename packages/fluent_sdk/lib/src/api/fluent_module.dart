import 'package:fluent_sdk/src/api/registry.dart';

/// Interface defined to create fluent modules
abstract class FluentModule {
  /// Build the specific module and register all his dependencies
  Future<void> build(Registry registry);
}
