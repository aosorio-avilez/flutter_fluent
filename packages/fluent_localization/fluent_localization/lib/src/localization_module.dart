import 'package:fluent_localization/src/api/localization_api_impl.dart';
import 'package:fluent_localization_api/fluent_localization_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

/// Register and build all the fluent localization dependencies
class LocalizationModule extends FluentModule {
  @override
  Future<void> build(Registry registry) async {
    registry.registerSingleton<LocalizationApi>((it) => LocalizationApiImpl());
  }
}
