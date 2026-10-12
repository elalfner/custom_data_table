## Why

Currently, `CustomDataTable` wraps its vertical content within a `Flexible` widget inside a `Column` and delegates height updates to a `ValueNotifier<double?> contentHeight` that is synchronously mutated during the widget's `build()` execution. When the table is placed inside a scrollable vertical viewport (such as `SingleChildScrollView` or `ListView`) where height constraints are unbounded, Flutter throws a fatal exception: `RenderFlex children have non-zero flex but incoming height constraints are unbounded`. Furthermore, mutating a `ValueNotifier` during `build()` violates Flutter lifecycle best practices and can trigger unnecessary rebuilds or runtime framework warnings.

Resolving this layout limitation allows `CustomDataTable` to be embedded seamlessly into vertical scrollable views, forms, and dashboard layouts while preserving full backward compatibility for existing bounded layouts (such as `Expanded` wrappers).

## What Changes

- Eliminate the `ValueNotifier<double?> contentHeight` instance variable, its mutation inside `build()`, and the surrounding `ValueListenableBuilder`.
- Introduce a pure, synchronous helper function `calculateContentHeight` to compute table content height based on item count, minimum row height, and divider height.
- Inspect `constraints.hasBoundedHeight` inside `_body()` via `LayoutBuilder`:
  - When `hasBoundedHeight == true`: retain bounded container behavior using `Flexible(child: tableContentContainer)` and enable internal vertical scrolling when content exceeds viewport bounds.
  - When `hasBoundedHeight == false`: render the table content container within a fixed-height container (`SizedBox(height: contentHeight + 10, child: tableContentContainer)`) matching natural content dimensions, avoiding `RenderFlex` flex calculation crashes.
- Add comprehensive widget tests covering both bounded height containers (`Expanded`, `SizedBox`) and unbounded height containers (`SingleChildScrollView`).

## Capabilities

### New Capabilities
- `adaptable-height-and-unbounded-constraints`: Dynamic height adaptation supporting both bounded containers and unbounded vertical scrollables (`hasBoundedHeight` evaluation) alongside pure synchronous content height calculation without lifecycle mutations.

### Modified Capabilities
<!-- None: existing specs in openspec/specs/ are continuous-integration, package-readiness, table-localization, single-page-table, and paginator-helpers-and-graphql. -->

## Impact

- `lib/src/presentation/widgets/custom_data_table.dart`: Removal of `ValueNotifier<double?> contentHeight` and `ValueListenableBuilder`; addition of synchronous height calculation and conditional `constraints.hasBoundedHeight` handling.
- `test/custom_data_table_test.dart`: New automated widget tests verifying layout behavior under bounded and unbounded vertical constraints.
- Zero breaking changes in public API signatures, parameters, styling, or existing bounded table usage (e.g. `viali_panel` integration).
