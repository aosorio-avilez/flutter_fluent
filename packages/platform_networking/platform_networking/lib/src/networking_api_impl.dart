import 'package:platform_networking_api/platform_networking_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class NetworkingApiImpl extends NetworkingApi {
  @override
  RestApi get restApi => getApi<RestApi>();
}
