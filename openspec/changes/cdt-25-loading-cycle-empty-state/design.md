## Context

`CustomDataTable` provides a comprehensive data grid widget for Flutter applications with sorting, filtering, pagination, and multi-directional scrolling. When interacting with remote asynchronous data sources, applications update `data` and `isLoading` flags. Under the current implementation:
1. `TableFooter` hardcodes `loading: false` to `TablePaginatedCountWidget`, allowing users to spam pagination buttons and page dialog selections while queries are pending.
2. The top `LinearProgressIndicator` appears during both initial loading (`data == null`) and background reloading (`data != null`), causing two concurrent loaders on initial fetch (central `CircularProgressIndicator` + top bar).
3. Passing an empty list `[]` calculates a content height of 0px, causing the table body to collapse to 10px with no placeholder or guidance.

### Architectural Reconciliation (Jira Ticket CDT-25 / CDT-26 Audit)
The original Jira ticket referenced resetting `contentHeight.value = null` when `data == null`, and referenced outdated paths (`lib/src/presentation/widgets/...`).
- **CDT-22** (`adaptable-height-and-unbounded-constraints`) already removed `ValueNotifier<double?> contentHeight` in favor of a pure synchronous helper `calculateContentHeight(...)` in `TableContent`. When `data == null`, height is already evaluated as `null` synchronously. No reactive height reset is needed.
- **CDT-18** and **CDT-20** already restructured and modularized `CustomDataTable` into `TableHeader`, `TableColumnsHeader`, `TableContent`, and `TableFooter` under `lib/src/ui/custom_data_table/widgets/`.
- Consequently, this change focuses exclusively on the remaining active defects: pagination loading lock, top loader visibility condition, and localized `emptyBuilder` support.

## Goals / Non-Goals

**Goals:**
- Propagate `isLoading` through `TableFooter` to `TablePaginatedCountWidget` to disable previous/next navigation and the page selection popup during active loading.
- Decouple loading indicators: display the top `LinearProgressIndicator` only when `isLoading == true && data != null`; during initial load (`data == null`), display only the central loader (`loadingBuilder` or `CircularProgressIndicator`).
- Provide an optional `emptyBuilder` on `CustomDataTable` (forwarded to `TableContent`) that renders when `data != null && data.isEmpty`.
- When `emptyBuilder` is null, provide a localized default empty state showing an icon and `"No results found"` / `"No se han encontrado resultados"` (`context.appLocalizations.noResultsFound`).
- Ensure empty states allocate a comfortable minimum height (160.0 px under unbounded constraints, centered within `Flexible` under bounded constraints) without collapsing to 10px.
- Enhance the `example/` app with an interactive toggle between a realistic single-page static mode and a simulated asynchronous web service with simulated network delay to facilitate visual inspection in `/jira-app-review`.
- Maintain complete backwards compatibility for existing `CustomDataTable` consumers.

**Non-Goals:**
- Mutating or reintroducing reactive `ValueNotifier` instances for height (resolved in CDT-22).
- Managing asynchronous data fetching or state management inside the library itself (the package remains presentation-focused; async simulation lives in `example/`).
- Changing pagination math, per-page dropdown behavior, or column filtering logic.

## Decisions

### 1. Propagating `isLoading` Through Footer and Pagination Count
- **Decision**: Add `final bool isLoading;` (default `false`) to `TableFooter`. Pass `isLoading: widget.isLoading` from `CustomDataTable` into `TableFooter`, and forward `loading: widget.isLoading` into `TablePaginatedCountWidget`.
- **Alternative considered**: Accessing an InheritedWidget or context provider. Rejected because `TableFooter` is a direct child widget of `CustomDataTable`, making explicit prop passing simpler, direct, and zero-overhead.

### 2. Guarding Page Selection Dialog on Loading
- **Decision**: In `TablePaginatedCountWidget`, guard the interactive page picker:
  ```dart
  final canSelect = widget.onSelectedPage != null &&
      widget.paginatorInfo.lastPage != 1 &&
      !widget.loading;
  ```
- **Rationale**: While `onPreviousPage` and `onNextPage` already checked `!widget.loading`, `canSelect` previously allowed opening `showDialogPage` and triggering `onSelectedPage` while loading.

### 3. Conditional Visibility of Top Linear Loader
- **Decision**: In `CustomDataTable.build()`, update the condition for the top `Positioned` progress bar from `if (widget.isLoading)` to `if (widget.isLoading && widget.data != null)`.
- **Rationale**: When `widget.data == null`, `TableContent` displays `widget.loadingBuilder?.call() ?? const CircularProgressIndicator()`. Showing the top bar simultaneously is redundant. When `data != null`, rows stay visible while the top bar signals background fetching.

### 4. Supporting `emptyBuilder` and Localized Default Empty State
- **Decision**:
  - Add `final Widget Function()? emptyBuilder;` to `CustomDataTable` and `TableContent`.
  - Add `noResultsFound` string to `app_en.arb` ("No results found") and `app_es.arb` ("No se han encontrado resultados").
  - When `data != null && data.isEmpty`:
    - Under `TableContent.build()`, render `widget.emptyBuilder?.call() ?? _buildDefaultEmptyState(context)`.
    - `_buildDefaultEmptyState` renders a centered column with an icon (`Icons.inbox_outlined`), the localized `noResultsFound` label, and theme-derived subtle styling.
    - Under unbounded constraints, allocate an ergonomic fixed height (160.0 px) instead of `0 + 10 = 10 px`.
    - Under bounded constraints, center within `Flexible` taking available viewport space.
- **Rationale**: An empty table should inform the user clearly that no records match instead of shrinking into an invisible 10px line.

### 5. Review Iteration 1: Interactive Example App with Simulated Web Service & Realistic Single Page
- **Decision**:
  - In `example/lib/services/mock_user_service.dart` (or `example/lib/main.dart`), implement an in-memory asynchronous user service with simulated network delay (e.g. 1000-1200ms) that returns paginated data (`List<User>` and `PaginatorInfo`).
  - In `example/lib/main.dart`:
    - Provide a mode toggle:
      - **Realistic Static Mode (Single Page)**: A clean, realistic list of fixed users with single-page paginator (`PaginatorInfo.singlePage(total: 7)`), eliminating confusing artificial 1500 pages.
      - **Simulated Web Service Mode (Async)**: Asynchronous pagination with 100 total users, 10 per page, tracking `_isLoading`. When navigating pages, `isLoading` is set to `true` during the delay, demonstrating the locked controls and top linear progress bar.
    - Provide quick test buttons:
      - `Initial Fetch (data == null)`: triggers central loader and then loads records.
      - `Simulate Empty ([])`: returns 0 records to demonstrate the new empty state.

## Risks / Trade-offs

- **[Risk] Custom empty widget overflow in bounded layouts** → **Mitigation**: Constrain the empty widget with `Center` and `SingleChildScrollView` or `Flexible` so large custom empty state widgets do not cause layout overflows.
- **[Risk] Existing callers expecting top loader on empty/null data** → **Mitigation**: Callers already expect central loader on initial load; top bar was visually conflicting with the central spinner.
- **[Risk] Network dependency in example app** → **Mitigation**: The simulated web service is 100% in-memory with `Future.delayed`, requiring zero external network or HTTP dependencies.
