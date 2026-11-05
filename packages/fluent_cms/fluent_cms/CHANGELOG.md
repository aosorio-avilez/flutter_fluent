## 0.1.0

- Initial release of `fluent_cms`.
- Server-Driven UI (SDUI) engine with hybrid JSON parser (sync for <50KB, Isolate for >=50KB).
- Tier 1 ($O(1)$ zero-hydration fast path) and Tier 3 (reactive opt-in hydration with 7 scopes and pipe chaining).
- Sliver-based responsive zone layout (`single_column`, `grid_12_cols`) with `pinned` headers and `stickyBottom` bars.
- Built-in `cms_repeater` module for virtualized lists, grids, and carousels.
- Parallel asynchronous data source manager (`asyncSources`) with TTL caching and `AutoSkeletonModuleWrapper`.
- Declarative action engine supporting optimistic updates, automatic rollback, concurrency policies, `scroll_to`, `modal_zone`, and custom commands.
- Dynamic theme token resolution and full integration with `fluent_environment`.
