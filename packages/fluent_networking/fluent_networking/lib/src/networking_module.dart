import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class NetworkingModule extends FluentModule {
  NetworkingModule({
    required this.config,
  });

  final NetworkingConfig config;

  @override
  Future<void> build(Registry registry) async {
    registry
      ..registerSingleton<Dio>((_) {
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

        if (config.enableLog) {
          dio.interceptors.add(
            PrettyDioLogger(
              requestHeader: true,
              requestBody: true,
              compact: false,
            ),
          );
        }

        return dio;
      })
      ..registerSingleton<NetworkingApi>((it) => NetworkingApiImpl(it()));
  }
}
