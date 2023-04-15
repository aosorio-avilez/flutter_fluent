import 'package:fluent_localization/src/api/localization_api_impl.dart';
import 'package:fluent_localization_api/fluent_localization_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';

class LocalizationModule extends Module {
  LocalizationModule({super.testMode = false});

  @override
  void build(Registry registry) {
    registry.registerApi<LocalizationApi>((it) => LocalizationApiImpl());
  }
}
