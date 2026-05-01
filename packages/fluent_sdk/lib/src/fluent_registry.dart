import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:get_it/get_it.dart';

/// Concrete implementation of [Registry] using [GetIt] as the backend engine.
class FluentRegistry implements Registry {
  final GetIt _getIt = GetIt.instance;

  @override
  @pragma('vm:prefer-inline')
  void allowReassignment({required bool allow}) {
    _getIt.allowReassignment = allow;
  }

  @override
  @pragma('vm:prefer-inline')
  bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();

  @override
  @pragma('vm:prefer-inline')
  void registerFactory<T extends Object>(
    T Function(GetIt i) factoryFunction, {
    String? instanceName,
  }) {
    _getIt.registerFactory<T>(
      () => factoryFunction(_getIt),
      instanceName: instanceName,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  void registerLazySingleton<T extends Object>(
    T Function(GetIt i) factoryFunction, {
    String? instanceName,
  }) {
    _getIt.registerLazySingleton<T>(
      () => factoryFunction(_getIt),
      instanceName: instanceName,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  void registerSingleton<T extends Object>(
    T Function(GetIt i) factoryFunction, {
    String? instanceName,
  }) {
    _getIt.registerSingleton<T>(
      factoryFunction(_getIt),
      instanceName: instanceName,
    );
  }
}
