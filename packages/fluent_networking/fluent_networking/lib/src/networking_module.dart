import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Register and build all the fluent networking dependencies
class NetworkingModule extends FluentModule {
  NetworkingModule({
    required this.config,
  });

  /// Networking configuration
  final NetworkingConfig config;

  @override
  void build(Registry registry) {
    registry
      ..registerSingleton<Dio>((_) {
        return Dio(
          BaseOptions(baseUrl: config.baseUrl),
        )..interceptors.addAll([PrettyDioLogger()]);
      })
      ..registerSingleton<NetworkingApi>((it) => NetworkingApiImpl(it()));
  }
}
