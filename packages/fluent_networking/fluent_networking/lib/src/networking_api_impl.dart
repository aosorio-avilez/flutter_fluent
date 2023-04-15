import 'package:fluent_networking_api/fluent_networking_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

class NetworkingApiImpl extends NetworkingApi {
  @override
  RestApi get restApi => getApi<RestApi>();
}
