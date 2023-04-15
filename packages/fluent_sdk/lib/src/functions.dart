import 'package:get_it/get_it.dart';

T getApi<T extends Object>() {
  return GetIt.instance<T>();
}

void mockApi<T extends Object>(T mock) {
  GetIt.instance.registerSingleton<T>(mock);
}
