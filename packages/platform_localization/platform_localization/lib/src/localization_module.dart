import 'package:platform_localization/src/api/localization_api_impl.dart';
import 'package:platform_localization_api/platform_localization_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

class LocalizationModule extends Module {
  LocalizationModule({super.testMode = false});

  @override
  void build(Registry registry) {
    registry.registerApi<LocalizationApi>((it) => LocalizationApiImpl());
  }
}
