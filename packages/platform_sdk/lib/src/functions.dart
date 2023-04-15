import 'package:platform_sdk/platform_sdk.dart';

T getApi<T extends Object>() {
  return GetIt.instance<T>();
}

void mockApi<T extends Object>(T mock) {
  GetIt.instance.registerSingleton<T>(mock);
}
