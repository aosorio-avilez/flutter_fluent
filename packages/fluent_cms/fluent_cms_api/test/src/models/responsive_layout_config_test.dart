import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveLayoutConfig & Breakpoints', () {
    test('CmsBreakpoint.fromWidth resolves mobile, tablet, and desktop', () {
      expect(CmsBreakpoint.fromWidth(375), CmsBreakpoint.mobile);
      expect(CmsBreakpoint.fromWidth(599.9), CmsBreakpoint.mobile);
      expect(CmsBreakpoint.fromWidth(600), CmsBreakpoint.tablet);
      expect(CmsBreakpoint.fromWidth(1024), CmsBreakpoint.tablet);
      expect(CmsBreakpoint.fromWidth(1024.1), CmsBreakpoint.desktop);
      expect(CmsBreakpoint.fromWidth(1440), CmsBreakpoint.desktop);
    });

    test('ColumnSpanConfig clamps span between 1 and 12 and copyWith', () {
      final low = ColumnSpanConfig.fromJson(const {
        'span': 0,
        'zones': ['z1'],
      });
      final high = ColumnSpanConfig.fromJson(const {
        'span': 20,
        'zones': ['z2'],
      });
      expect(low.span, 1);
      expect(high.span, 12);

      final updated = low.copyWith(span: 6, zones: const ['z1', 'z2']);
      expect(updated.span, 6);
      expect(updated.zones, ['z1', 'z2']);
      expect(updated.copyWith(), equals(updated));
      expect(ColumnSpanConfig.fromJson(updated.toJson()), equals(updated));
    });

    test('BreakpointLayout parses dynamic maps in columns and copyWith', () {
      final layout = BreakpointLayout.fromJson(const <String, dynamic>{
        'type': 'grid_12_cols',
        'columns': <dynamic>[
          <dynamic, dynamic>{
            'span': 8,
            'zones': <dynamic>['main'],
          },
        ],
      });
      expect(layout.isGrid, isTrue);
      expect(layout.columns?.first.span, 8);

      final copied = layout.copyWith(
        type: 'single_column',
        zonesOrder: const ['main'],
        columns: const [],
      );
      expect(copied.isGrid, isFalse);
      expect(copied.copyWith(), equals(copied));
    });

    test('ResponsiveLayoutConfig falls back mobile -> tablet -> desktop', () {
      const mobile = BreakpointLayout(zonesOrder: ['m']);
      const tablet = BreakpointLayout(zonesOrder: ['t']);
      const desktop = BreakpointLayout(
        type: 'grid_12_cols',
        columns: [
          ColumnSpanConfig(span: 12, zones: ['d']),
        ],
      );

      const mobileOnly = ResponsiveLayoutConfig(mobile: mobile);
      expect(mobileOnly.resolveForBreakpoint(CmsBreakpoint.mobile), mobile);
      expect(mobileOnly.resolveForBreakpoint(CmsBreakpoint.tablet), mobile);
      expect(mobileOnly.resolveForBreakpoint(CmsBreakpoint.desktop), mobile);

      final withTablet = mobileOnly.copyWith(tablet: tablet);
      expect(withTablet.resolveForBreakpoint(CmsBreakpoint.tablet), tablet);
      expect(withTablet.resolveForBreakpoint(CmsBreakpoint.desktop), tablet);

      final full = withTablet.copyWith(desktop: desktop);
      expect(full.resolveForBreakpoint(CmsBreakpoint.desktop), desktop);
      expect(full.copyWith(), equals(full));
      expect(ResponsiveLayoutConfig.fromJson(full.toJson()), equals(full));
    });
  });
}
