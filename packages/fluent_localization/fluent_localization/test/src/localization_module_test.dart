import 'package:fluent_localization/fluent_localization.dart';
import 'package:fluent_localization/src/api/localization_api_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('localization module should register api implementation', () async {
    await Fluent.build([LocalizationModule()]);

    final api = Fluent.get<LocalizationApi>();

    expect(api, isA<LocalizationApiImpl>());
  });
}
