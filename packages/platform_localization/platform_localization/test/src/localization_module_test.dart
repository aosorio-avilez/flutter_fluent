import 'package:flutter_test/flutter_test.dart';
import 'package:platform_localization/platform_localization.dart';
import 'package:platform_localization/src/api/localization_api_impl.dart';
import 'package:platform_localization_api/platform_localization_api.dart';
import 'package:platform_sdk/platform_sdk.dart';

void main() {
  test('localization module should register api implementation', () async {
    Platform.build([LocalizationModule()]);

    final api = getApi<LocalizationApi>();

    expect(api, isA<LocalizationApiImpl>());
  });
}
