## 0.1.1

- Add standalone `example/main.dart` demonstrating custom SDUI modules, AST definitions, and JSON Schema generation.
- Broaden `equatable` constraint to `'>=2.0.5 <4.0.0'` supporting latest stable release 3.x.
- Expand package `description` in `pubspec.yaml` to meet pub.dev guidelines.
- Add explicit documentation comments to constructors of `CmsApi`, `AsyncDataSource`, `CmsModuleContext`, `CmsPageStore`, and `HydrationEngine`.

## 0.1.0

- Initial release of `fluent_cms_api`.
- Immutable AST models (`CmsPage`, `ContentZone`, `ModuleNode`, `ActionNode`, `ResponsiveLayoutConfig`, `AsyncSource`, `RepeaterConfig`, `A11yConfig`).
- Public contracts and interfaces (`CmsApi`, `SduiModule`, `HydrationEngine`, `NoOpHydrationEngine`, `PipeTransformer`, `AsyncDataSource`, `CmsPageStore`).
- JSON Schema Draft 2020-12 generator (`CmsJsonSchemaGenerator`).
