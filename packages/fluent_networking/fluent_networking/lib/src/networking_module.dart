import 'package:dio/dio.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:fluent_networking/src/rest_api_impl.dart';
import 'package:fluent_networking/src/rest_config.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';

class NetworkingModule extends Module {
  NetworkingModule({
    required this.config,
    super.testMode = false,
  });

  final RestConfig config;

  @override
  void build(Registry registry) {
    registry
      ..registerApi<Dio>((_) {
        return Dio(
          BaseOptions(baseUrl: config.baseUrl),
        )..interceptors.addAll([
            ...[LoggyDioInterceptor()],
            ...config.interceptors
          ]);
      })
      ..registerApi<RestApi>((it) => RestApiImpl(it()))
      ..registerApi<NetworkingApi>((it) => NetworkingApiImpl());
  }
}
