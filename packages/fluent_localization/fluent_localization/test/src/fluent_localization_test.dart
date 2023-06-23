import 'package:fluent_localization/src/fluent_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(WidgetsFlutterBinding.ensureInitialized);

  test('verify fluent localization load return false', () async {
    final localization = FluentLocalization();

    final result = await localization.load();

    expect(result, isFalse);
  });

  test('verify fluent localization load return true', () async {
    final localization = FluentLocalization(
      path: 'test/assets/languages',
    );

    final result = await localization.load();

    expect(result, isTrue);
  });

  test('verify fluent localization get string with map return localized string',
      () async {
    final localization = FluentLocalization(
      path: 'test/assets/languages',
    );

    await localization.load();

    expect(localization.get('test.hello', args: {'name': 'Dev'}), 'Hello Dev!');
  });

  test('verify fluent localization get string return localized string',
      () async {
    final localization = FluentLocalization(
      path: 'test/assets/languages',
    );

    await localization.load();

    expect(localization.get('title'), 'Title');
  });

  test('verify fluent localization get missing string should return key',
      () async {
    final localization = FluentLocalization(
      path: 'test/assets/languages',
    );

    await localization.load();

    expect(localization.get('missing_string'), 'missing_string');
  });
}
