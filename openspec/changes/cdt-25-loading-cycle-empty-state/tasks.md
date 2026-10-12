## 1. Pagination and Footer Loading Lockdown

- [x] 1.1 In `TablePaginatedCountWidget`, guard page selection modal trigger so `showDialogPage` is disabled when `widget.loading` is `true`.
- [x] 1.2 In `TableFooter`, add `final bool isLoading;` parameter (default `false`) and forward `loading: widget.isLoading` to `TablePaginatedCountWidget`.
- [x] 1.3 In `CustomDataTable`, pass `isLoading: widget.isLoading` when instantiating `TableFooter`.

## 2. Conditional Top Progress Indicator

- [x] 2.1 In `CustomDataTable`, update top `LinearProgressIndicator` visibility condition to `if (widget.isLoading && widget.data != null)`.

## 3. Localization and Empty State Support

- [x] 3.1 Add `noResultsFound` key to `lib/l10n/app_en.arb` ("No results found") and `lib/l10n/app_es.arb` ("No se han encontrado resultados") and run `flutter gen-l10n`.
- [x] 3.2 Add `final Widget Function()? emptyBuilder;` parameter to `CustomDataTable` and pass it to `TableContent`.
- [x] 3.3 Add `final Widget Function()? emptyBuilder;` parameter to `TableContent`.
- [x] 3.4 In `TableContent`, implement `_buildDefaultEmptyWidget(BuildContext context)` with icon and localized `noResultsFound` text.
- [x] 3.5 In `TableContent`, render `widget.emptyBuilder?.call() ?? _buildDefaultEmptyWidget(context)` when `data != null && data.isEmpty`.
- [x] 3.6 In `TableContent`, ensure empty datasets allocate comfortable minimum height (160.0 px under unbounded constraints, centered inside `Flexible` under bounded constraints) without collapsing to 10px.

## 4. Height Reset Verification and Test Suite

- [x] 4.1 Verify pure synchronous height calculation when `data` transitions to `null` (confirming legacy `contentHeight.value` mutation from CDT-25 is obsolete and handled via `currentContentHeight == null`).
- [x] 4.2 Add widget tests verifying pagination controls (previous, next, and page picker) are disabled during active loading (`isLoading == true`).
- [x] 4.3 Add widget tests verifying top `LinearProgressIndicator` is hidden on initial load (`data == null`) and visible on background reload (`data != null`).
- [x] 4.4 Add widget tests verifying custom `emptyBuilder` and default empty state placeholder when `data == []`.
- [x] 4.5 Add widget test verifying transitioning `data` from a populated list to `null` resets content height and adapts container constraints smoothly.
- [x] 4.6 Run format check, static analysis (`flutter analyze --fatal-infos`), and full test suite (`flutter test`).

## 5. Review Iteration: Interactive Web Service and Example Enhancements [Iteration 1]

- [x] 5.1 Implement mock async web service in `example/lib/services/mock_user_service.dart` simulating paginated network fetches with realistic delay (1000ms), 100 items, and empty response simulation.
- [x] 5.2 Add interactive toggle in `example/lib/main.dart` between realistic static single-page mode (`PaginatorInfo.singlePage(total: 7)`) and simulated async web service.
- [x] 5.3 Wire async page navigation, initial fetch (`data == null`), background reload, and empty state triggers into `CustomDataTable` in `example/`.
- [x] 5.4 Verify formatting (`dart format`), static analysis (`flutter analyze --fatal-infos`), and tests (`flutter test`).

## 6. Review Iteration: Zero-Shift Page Selector Stability [Iteration 2]

- [x] 6.1 In `TablePaginatedCountWidget`, decouple `isSelectable` from `isEnabled` so the fill background and dropdown icon remain visible during loading (`widget.loading`).
- [x] 6.2 In `TablePaginatedCountWidget`, apply `disabledColor` to the page text and dropdown icon when `widget.loading` is `true`.
- [x] 6.3 Add/update widget tests verifying `TablePaginatedCountWidget` maintains its dropdown icon and dimensions while disabled during `loading`.
- [x] 6.4 Verify formatting (`dart format`), static analysis (`flutter analyze --fatal-infos`), and test suite (`flutter test`).

## 7. Review Iteration: Visual Polish, Empty State Dimensions, and Paginator Sync [Iteration 3]

- [x] 7.1 In `TablePaginatedCountWidget`, retain `fillColor` background on page number button even when `lastPage == 1` for consistent pill styling with `TablePerPageWidget`.
- [x] 7.2 In `TableContent`, adjust default empty state height to a compact height (100.0 px) in both bounded and unbounded modes, with refined icon size (30.0 px).
- [x] 7.3 In `TableFooter.resultsNumberWidget`, handle `total == 0` edge case so it displays `0 results` / `0 resultados` cleanly without showing `1 to 0`.
- [x] 7.4 In `example/lib/main.dart`, synchronize `paginatorInfo` when toggling `btn_toggle_data` between static data and empty list.
- [x] 7.5 Update widget tests covering single-page pill styling, compact empty state height, and zero-results footer text.
- [x] 7.6 Verify formatting (`dart format`), static analysis (`flutter analyze --fatal-infos`), and tests (`flutter test`).

## 8. Review Iteration: Centered Initial Loading Indicator and Height Parity [Iteration 4]

- [x] 8.1 In `TableContent`, wrap default `CircularProgressIndicator` in `Center` with 30.0 px sizing (`SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 3))`).
- [x] 8.2 In `TableContent`, unify compact 100.0 px height (`isCompactState = (data != null && data.isEmpty) || (data == null && widget.isLoading)`) across bounded (`BoxConstraints(maxHeight: 100.0)`) and unbounded (`SizedBox(height: 100.0)`) modes.
- [x] 8.3 Update widget tests verifying initial loading state renders centered and matches 100.0 px height in bounded and unbounded contexts.
- [x] 8.4 Verify formatting (`dart format`), static analysis (`flutter analyze --fatal-infos`), and test suite (`flutter test`).
