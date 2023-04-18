import 'package:dio/dio.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:fluent_networking/src/networking_config.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';

class NetworkingModule extends Module {
  NetworkingModule({
    required this.config,
    super.testMode = false,
  });

  final NetworkingConfig config;

  @override
  void build(Registry registry) {
    registry
      ..registerApi<Dio>((_) {
        return Dio(
          BaseOptions(baseUrl: config.baseUrl),
        )..interceptors.addAll([LoggyDioInterceptor()]);
      })
      ..registerApi<NetworkingApi>((it) => NetworkingApiImpl(it()));
  }
}
