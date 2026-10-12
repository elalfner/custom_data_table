## Why

During data loading and state transitions, `CustomDataTable` exhibits several UI inconsistencies:
1. When `isLoading` is true, pagination controls remain clickable, permitting rapid click spam and duplicate asynchronous requests.
2. During initial table loading (`data == null && isLoading == true`), both the central loading indicator (`loadingBuilder` or `CircularProgressIndicator`) and the top `LinearProgressIndicator` are rendered simultaneously, causing visual clutter.
3. When data is empty (`data != null && data.isEmpty`), content height collapses to 10px and no informative message or custom placeholder is displayed.

This change optimizes the loading lifecycle, locks pagination navigation when loading, decouples the top linear loader from initial load, and introduces an `emptyBuilder` with localized default fallback for empty dataset states.

> **Note on Jira Ticket Scope Reconciliation:**
> The original Jira ticket description (CDT-25 / CDT-26) referenced resetting `contentHeight.value = null` and legacy widget file paths (`lib/src/presentation/widgets/...`). Those items are obsolete:
> - **CDT-22** already eliminated `ValueNotifier<double?> contentHeight` in favor of pure synchronous calculation `calculateContentHeight(...)` in `TableContent`. When `data == null`, content height is already intrinsically `null`.
> - **CDT-18 & CDT-20** modularized the table components under `lib/src/ui/custom_data_table/widgets/`.
> The active scope of this change is strictly refined to the three remaining issues: pagination locking, loader decoupling, and empty state support.

## What Changes

- **Pagination Lock During Loading**: Pass `isLoading` from `CustomDataTable` to `TableFooter` and onwards to `TablePaginatedCountWidget`. Disable the previous page, next page, and page selector popup button when `isLoading` is true.
- **Conditional Top Progress Indicator**: Render the top `LinearProgressIndicator` only when `widget.isLoading && widget.data != null` (background refetching). During initial load (`widget.isLoading && widget.data == null`), only the central loading builder is shown.
- **Empty State Support**: Add an optional `final Widget Function()? emptyBuilder;` parameter to `CustomDataTable` and `TableContent`. When `data != null && data.isEmpty`, render `emptyBuilder?.call()` (or a default localized empty state widget) within an ergonomically sized viewport instead of collapsing to 10px.
- **Clean Height and Transition Behavior**: Ensure empty states and null data transitions gracefully adjust viewport dimensions without layout overflows.
- **Review Iteration 1 - Interactive Example App**: Enhance `example/` with an interactive toggle between a realistic single-page static table mode and a simulated asynchronous web service with simulated latency, allowing interactive verification of pagination lock, loaders, and empty states.
- **Review Iteration 2 - Zero-Shift Page Selector Stability**: Decouple page selector interactivity from its layout structure in `TablePaginatedCountWidget`, keeping the dropdown arrow icon and background pill visible and properly styled with `disabledColor` during loading, eliminating the 17px layout shift.

## Capabilities

### New Capabilities
- `table-loading-and-empty-state`: Dedicated loading coordination (top progress indicator visibility, pagination button disabling during active load) and configurable `emptyBuilder` support for empty data collections.

### Modified Capabilities
- `adaptable-height-and-unbounded-constraints`: Adjust empty data (`data.isEmpty`) height handling so the container does not collapse to 10px, providing adequate height for empty state widgets in both bounded and unbounded contexts.

## Impact

- `lib/src/ui/custom_data_table/widgets/custom_data_table.dart`: Add `emptyBuilder` parameter, pass `isLoading` to `TableFooter`, conditional top progress indicator.
- `lib/src/ui/custom_data_table/widgets/table_footer.dart`: Add `isLoading` property, forward `loading: widget.isLoading` to `TablePaginatedCountWidget`.
- `lib/src/ui/custom_data_table/widgets/pagination/table_paginated_count_widget.dart`: Prevent page selection dialog from opening when `widget.loading` is true while preserving container dimensions, background, and icon with disabled styling.
- `lib/src/ui/custom_data_table/widgets/table_content.dart`: Accept `emptyBuilder`, display empty state with comfortable height when `data.isEmpty`.
- `lib/l10n/`: Add `noResultsFound` to `app_en.arb` and `app_es.arb`.
- `example/`: Add simulated asynchronous web service and toggle between single-page static mode and async web service mode for interactive manual and automated testing.
- Backwards compatible: `emptyBuilder` is optional, `isLoading` on `TableFooter` defaults to `false`.
