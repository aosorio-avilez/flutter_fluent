import 'package:fluent_localization/fluent_localization.dart';
import 'package:fluent_localization/src/api/localization_api_impl.dart';
import 'package:fluent_localization_api/fluent_localization_api.dart';
import 'package:fluent_sdk/fluent_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('localization module should register api implementation', () async {
    Fluent.build([LocalizationModule()]);

    final api = getApi<LocalizationApi>();

    expect(api, isA<LocalizationApiImpl>());
  });
}
