# Changelog

All notable changes to the `custom_data_table` package will be documented in this file.
This project adheres to [Semantic Versioning](https://semver.org/).

## 3.1.0

### Key Capabilities & Enhancements
* **Adaptable Height & Unbounded Viewports (`shrinkWrap`)**:
  * Native support for unbounded vertical constraints (e.g. inside `SingleChildScrollView`, `Column`, or modal dialogs).
  * Introduced `shrinkWrap` property allowing the table to adapt its height to match intrinsic row content.
* **Granular Lifecycle State Builders**:
  * **`initialStateBuilder`**: Render custom placeholders, call-to-actions, or illustrations prior to the user executing an initial search or query.
  * **`emptyBuilder`**: Provide custom presentation for zero-result states, or rely on the built-in localized empty placeholder.
  * **`errorBuilder`**: Decoupled, modernized error presentation replacing `exceptionBuilder`.
* **Resilient Error Handling (`hasError` & `showErrorBanner`)**:
  * Decoupled error detection from data nullability using explicit boolean `hasError`.
  * Support for `showErrorBanner`: keep existing table data on screen during background refresh failures while displaying an informational warning banner.
  * Deprecated `exceptionBuilder` in favor of `errorBuilder` with full backwards compatibility.
* **Loading Cycle & Interaction Locking**:
  * Automatically disable pagination controls (page buttons, rows-per-page dropdown, next/prev) while `isLoading` is active to prevent duplicate network requests.
* **Pagination Helpers**:
  * Added `PaginatorInfo.singlePage(totalElements: ...)` helper for unpaginated datasets that still require record count summaries.
* **Architecture & Modularization**:
  * Clean architectural separation into dedicated widget modules (`TableCore`, `TableHeader`, `TableBody`, `TableFooter`, `DateDialogs`).
* **Internationalization Coverage**:
  * Expanded Spanish and English localized strings for empty states, error banners, and dialog actions.

## 3.0.6

Initial public release of `custom_data_table` on pub.dev.

### Key Capabilities
* **Interactive Rows**: Handle row taps via `onTapRow: (element) => ...` with built-in Material ink ripple effects, or customize row layouts using `rowBuilder`.
* **Integrated Column Search**: Search inputs embedded directly inside column headers for instant, per-column filtering.
* **Pre-Populated Search**: Support for pre-filled `generalSearchController` and `ColumnInfo.initialSearchValue` that filters data immediately upon initial render.
* **Smart Date Filtering**: Built-in `DateSelection` dialogs with intelligent range detection (single date, month, year, or custom period).
* **Synchronized Bi-Directional Scrolling**: Smooth horizontal and vertical scrolling with pinned headers for wide datasets.
* **Fully Customizable Theming**: Configure colors, alternating row striping, borders, paddings, and header styles via `DatatableThemeData`.
* **Responsive Pagination Footer**: Built-in footer supporting page navigation, customizable rows-per-page options, and formatted item count summaries.
