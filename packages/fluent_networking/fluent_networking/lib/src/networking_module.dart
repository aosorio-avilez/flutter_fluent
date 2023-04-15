import 'package:dio/dio.dart';
import 'package:fluent_environment_api/fluent_environment_api.dart';
import 'package:fluent_networking/fluent_networking.dart';
import 'package:fluent_networking/src/networking_api_impl.dart';
import 'package:fluent_networking/src/rest_api_impl.dart';
import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';

class NetworkingModule extends Module {
  NetworkingModule({
    this.interceptors = const [],
    super.testMode = false,
  });

  final List<RestApiInterceptor> interceptors;

  @override
  void build(Registry registry) {
    registry
      ..registerApi<Dio>((_) {
        final environment = getApi<EnvironmentApi>().getEnvironment();
        return Dio(
          BaseOptions(baseUrl: environment.values['url']!),
        )..interceptors.addAll([LoggyDioInterceptor()]);
      })
      ..registerApi<RestApi>((it) => RestApiImpl(it()))
      ..registerApi<NetworkingApi>((it) => NetworkingApiImpl());
  }
}
