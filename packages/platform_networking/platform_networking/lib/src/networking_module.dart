import 'package:dio/dio.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';
import 'package:platform_environment_api/platform_environment_api.dart';
import 'package:platform_networking/platform_networking.dart';
import 'package:platform_networking/src/networking_api_impl.dart';
import 'package:platform_networking/src/rest_api_impl.dart';
import 'package:platform_networking_api/platform_networking_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

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
