import 'package:fluent_cms/fluent_cms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CmsConfig & Sentinel URI security', () {
    test(
      'allows relative paths and validates http/https against allowedHosts',
      () {
        const openConfig = CmsConfig();
        expect(openConfig.isUriAllowed('/v1/wallet/summary'), isTrue);
        expect(
          openConfig.isUriAllowed('https://api.example.com/v1/home'),
          isTrue,
        );
        expect(openConfig.isUriAllowed('javascript:alert(1)'), isFalse);
        expect(openConfig.isUriAllowed('file:///etc/passwd'), isFalse);
        expect(openConfig.isUriAllowed('   '), isFalse);
        expect(openConfig.isUriAllowed('::invalid::'), isFalse);

        const restrictedConfig = CmsConfig(
          allowedHosts: {'api.fluent.mx', 'cdn.fluent.mx'},
        );
        expect(
          restrictedConfig.isUriAllowed('https://api.fluent.mx/v1/catalog'),
          isTrue,
        );
        expect(
          restrictedConfig.isUriAllowed('https://evil.example.com/phish'),
          isFalse,
        );
      },
    );
  });
}
