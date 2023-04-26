import 'package:fluent_localization/src/api/localization_api_impl.dart';
import 'package:fluent_localization_api/fluent_localization_api.dart';

/// Register and build all the fluent localization dependencies
class LocalizationModule extends FluentModule {
  @override
  void build(Registry registry) {
    registry.registerSingleton<LocalizationApi>((it) => LocalizationApiImpl());
  }
}
