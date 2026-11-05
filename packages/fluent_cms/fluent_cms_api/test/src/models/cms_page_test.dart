import 'dart:convert';

import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CmsPage & AsyncSource', () {
    const masterSchemaJson = r'''
{
  "schemaVersion": "1.0.0",
  "pageId": "home_omnicanal",
  "cacheTtlSeconds": 600,
  "refreshable": true,
  "preserveStateOnRefresh": true,
  "dataContext": {
    "user": { "firstName": "Alfonso", "tier": "Gold" },
    "membership": { "active": true, "savings": 1250.50 }
  },
  "asyncSources": {
    "wallet": {
      "endpoint": "/v1/wallet/summary",
      "method": "get",
      "headers": { "X-Tenant": "mx" },
      "ttlSeconds": 120,
      "fallback": { "balance": 0.0 }
    }
  },
  "layout": {
    "mobile": {
      "type": "single_column",
      "zonesOrder": ["sticky_top", "hero_zone", "main_feed", "promo_sidebar"]
    },
    "desktop": {
      "type": "grid_12_cols",
      "columns": [
        { "span": 12, "zones": ["sticky_top", "hero_zone"] },
        { "span": 8, "zones": ["main_feed"] },
        { "span": 4, "zones": ["promo_sidebar"] }
      ]
    }
  },
  "zones": {
    "sticky_top": {
      "pinned": true,
      "modules": [
        {
          "id": "search_bar_mod",
          "type": "search_input_module",
          "props": {
            "placeholder": "Buscar productos...",
            "bindTo": "searchQuery",
            "backgroundColor": "$surfaceSecondary"
          },
          "actions": {
            "onChanged": {
              "actionType": "custom_command",
              "target": "filter_results",
              "concurrency": "debounce",
              "debounceMs": 300,
              "payload": { "query": "{{state.searchQuery}}" }
            }
          }
        }
      ]
    },
    "hero_zone": {
      "modules": [
        {
          "id": "loyalty_hero_1",
          "type": "loyalty_banner",
          "platforms": ["android", "ios", "web"],
          "visibleWhen": "{{data.membership.active}} == true",
          "requiresData": ["async.wallet"],
          "keepAlive": true,
          "a11y": {
            "label": "Resumen de membresía de {{data.user.firstName}}",
            "isButton": true
          },
          "props": {
            "greeting": "Hola, {{data.user.firstName}}",
            "savingsText": "Ahorro: {{data.membership.savings | currency:MXN}}",
            "walletText": "Cashback: {{async.wallet.balance | currency:MXN}}",
            "cardColor": { "light": "#F5F7FA", "dark": "#1E222A" }
          },
          "responsiveProps": {
            "mobile": { "compactMode": true, "maxLines": 2 },
            "desktop": { "compactMode": false, "maxLines": 4 }
          },
          "actions": {
            "onImpression": {
              "actionType": "analytics_only",
              "analytics": {
                "event": "hero_loyalty_viewed",
                "tier": "{{data.user.tier}}"
              }
            },
            "onTap": {
              "actionType": "navigation",
              "target": "/wallet-details",
              "concurrency": "dropIfBusy",
              "payload": { "source": "home_hero" }
            }
          }
        }
      ]
    }
  }
}
''';

    test('parses Master Schema v1.0 JSON and round-trips toJson', () {
      final rawMap = jsonDecode(masterSchemaJson) as Map<String, dynamic>;
      final page = CmsPage.fromJson(rawMap);

      expect(page.schemaVersion, '1.0.0');
      expect(page.pageId, 'home_omnicanal');
      expect(page.cacheTtlSeconds, 600);
      expect(page.refreshable, isTrue);
      expect(page.preserveStateOnRefresh, isTrue);
      expect(
        page.dataContext?['user'],
        {'firstName': 'Alfonso', 'tier': 'Gold'},
      );

      final walletSource = page.asyncSources?['wallet'];
      expect(walletSource, isNotNull);
      expect(walletSource!.endpoint, '/v1/wallet/summary');
      expect(walletSource.method, 'GET');
      expect(walletSource.headers, {'X-Tenant': 'mx'});
      expect(walletSource.ttlSeconds, 120);
      expect(walletSource.fallback, {'balance': 0.0});

      final roundTripped = CmsPage.fromJson(page.toJson());
      expect(roundTripped, equals(page));
    });

    test('supports copyWith and default values on CmsPage and AsyncSource', () {
      final defaultPage = CmsPage.fromJson(const <String, dynamic>{
        'pageId': 'minimal_page',
      });
      expect(defaultPage.schemaVersion, '1.0.0');
      expect(defaultPage.refreshable, isFalse);
      expect(defaultPage.preserveStateOnRefresh, isTrue);
      expect(defaultPage.zones, isEmpty);

      final updatedPage = defaultPage.copyWith(
        pageId: 'updated_page',
        cacheTtlSeconds: 300,
        refreshable: true,
        preserveStateOnRefresh: false,
        dataContext: const {'k': 'v'},
        asyncSources: const {
          'src': AsyncSource(endpoint: '/api'),
        },
      );
      expect(updatedPage.pageId, 'updated_page');
      expect(updatedPage.cacheTtlSeconds, 300);
      expect(updatedPage.refreshable, isTrue);
      expect(updatedPage.preserveStateOnRefresh, isFalse);
      expect(updatedPage.copyWith(), equals(updatedPage));

      const source = AsyncSource(endpoint: '/v1/items');
      final copiedSource = source.copyWith(
        endpoint: '/v2/items',
        method: 'POST',
        headers: const {'Authorization': 'Bearer token'},
        ttlSeconds: 60,
        fallback: const {'items': <dynamic>[]},
      );
      expect(copiedSource.endpoint, '/v2/items');
      expect(copiedSource.method, 'POST');
      expect(copiedSource.copyWith(), equals(copiedSource));
    });
  });
}
