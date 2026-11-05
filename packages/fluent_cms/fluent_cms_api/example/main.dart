import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter/material.dart';

/// Minimal example demonstrating how to declare an [SduiModule] and construct
/// an immutable [CmsPage] AST definition using the `fluent_cms_api` contract.
void main() {
  // 1. Construct an immutable CmsPage AST definition
  const page = CmsPage(
    pageId: 'storefront_home',
    layout: ResponsiveLayoutConfig(
      mobile: BreakpointLayout(zonesOrder: ['hero_zone']),
    ),
    zones: {
      'hero_zone': ContentZone(
        modules: [
          ModuleNode(
            id: 'promo_banner_1',
            type: 'promo_banner',
            props: {
              'title': 'Summer Super Sale',
              'discount': 40,
            },
          ),
        ],
      ),
    },
  );

  // 2. Generate JSON Schema Draft 2020-12 for backend contract validation
  final schema = CmsJsonSchemaGenerator.generate(
    modules: const [PromoBannerModule()],
  );

  debugPrint(
    'Constructed page: ${page.pageId} with ${page.zones.length} zone(s).',
  );
  debugPrint('Generated JSON schema with ${schema.keys.length} root keys.');
}

/// A sample SDUI module implementing the public [SduiModule] contract.
class PromoBannerModule extends SduiModule {
  /// Creates a [PromoBannerModule].
  const PromoBannerModule();

  @override
  String get type => 'promo_banner';

  @override
  Widget build(BuildContext context, CmsModuleContext moduleContext) {
    final title = moduleContext.getString('title', defaultValue: 'Promotion');
    return Center(child: Text(title));
  }
}
