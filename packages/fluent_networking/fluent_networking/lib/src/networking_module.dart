import 'package:dio/dio.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';

class NetworkingModule extends FluentModule {
  NetworkingModule({
    required this.config,
  });

  final NetworkingConfig config;

  @override
  void build(Registry registry) {
    registry
      ..registerSingleton<Dio>((_) {
        return Dio(
          BaseOptions(baseUrl: config.baseUrl),
        )..interceptors.addAll([LoggyDioInterceptor()]);
      })
      ..registerSingleton<NetworkingApi>((it) => NetworkingApiImpl(it()));
  }
}
