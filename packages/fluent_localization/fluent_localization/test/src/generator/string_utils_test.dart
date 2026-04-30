import 'package:fluent_localization/src/generator/string_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringUtils', () {
    test('toCamelCase should convert snake_case correctly', () {
      expect(StringUtils.toCamelCase('hello_world'), 'helloWorld');
      expect(
        StringUtils.toCamelCase('welcome_message_test'),
        'welcomeMessageTest',
      );
    });

    test('toCamelCase should convert dot.notation correctly', () {
      expect(StringUtils.toCamelCase('home.title'), 'homeTitle');
      expect(StringUtils.toCamelCase('auth.login.button'), 'authLoginButton');
    });

    test('toCamelCase should convert kebab-case correctly', () {
      expect(StringUtils.toCamelCase('my-cool-key'), 'myCoolKey');
    });

    test('toCamelCase should handle mixed separators', () {
      expect(
        StringUtils.toCamelCase('user.profile_image-url'),
        'userProfileImageUrl',
      );
    });

    test(
      'toCamelCase should preserve already camelCase keys (starting lowercase)',
      () {
        expect(StringUtils.toCamelCase('alreadyCamelCase'), 'alreadyCamelCase');
      },
    );
  });
}
