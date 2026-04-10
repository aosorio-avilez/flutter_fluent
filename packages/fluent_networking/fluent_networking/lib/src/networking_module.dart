import 'package:dio/dio.dart';
import 'package:fluent_logger_api/fluent_logger_api.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/interceptors/networking_log_interceptor.dart';
import 'package:fluent_networking/src/interceptors/networking_retry_interceptor.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';

class NetworkingModule extends FluentModule {
  const NetworkingModule({
    required this.config,
  });

  final NetworkingConfig config;

  @override
  void onCreate(Registry registry) {
    registry
      ..registerLazySingleton<Dio>((it) {
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
          dio.interceptors.add(
            NetworkingLogInterceptor(
              loggerApi: it<LoggerApi>(),
              sensitiveHeaders: config.sensitiveHeaders,
              sensitiveBodyKeys: config.sensitiveBodyKeys,
            ),
          );
        }

        dio.interceptors.add(
          NetworkingRetryInterceptor(
            dio: dio,
            globalRetryConfig: config.retryConfig,
          ),
        );

        return dio;
      })
      ..registerLazySingleton<NetworkingApi>((it) => NetworkingApiImpl(it()));
  }
}
