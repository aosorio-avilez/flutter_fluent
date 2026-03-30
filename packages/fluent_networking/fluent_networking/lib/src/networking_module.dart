import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/interceptors/networking_log_interceptor.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';

class NetworkingModule extends FluentModule {
  const NetworkingModule({
    required this.config,
  });

  final NetworkingConfig config;

  @override
  void onCreate(Registry registry) {
    registry
      ..registerLazySingleton<Dio>((_) {
        final dio = Dio(
          BaseOptions(
            baseUrl: config.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

        if (config.interceptors.isNotEmpty) {
          dio.interceptors.addAll(config.interceptors);
        }

        if (config.enableLog &&
            !const bool.fromEnvironment('dart.vm.product')) {
          dio.interceptors.add(const NetworkingLogInterceptor());
        }

        return dio;
      })
      ..registerLazySingleton<NetworkingApi>((it) => NetworkingApiImpl(it()));
  }
}
