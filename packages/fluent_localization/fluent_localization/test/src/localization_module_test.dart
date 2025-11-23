import 'package:fluent_localization/fluent_localization.dart';
import 'package:fluent_localization/src/api/localization_api_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LocalizationModule registers LocalizationApi correctly', () async {
    await Fluent.build([LocalizationModule()]);
    addTearDown(Fluent.reset);

    final api = Fluent.get<LocalizationApi>();

    expect(api, isA<LocalizationApiImpl>());
  });
}
