## Why

Following the architectural folder restructuring completed in CDT-18, the main file `custom_data_table.dart` continues to concentrate all UI rendering inside internal private methods of `_CustomDataTableState` (`header()`, `tableContent()`, `rowWidget()`, `columnsWidget()`, `columnWidget()`, `columnFieldWidget()`), accumulating over 1,200 lines of code.

This pattern contradicts the official Flutter Architecture Case Study (Compass App) and core Flutter guidelines, which strongly advocate composing views from small, dedicated widget classes rather than functions returning widgets. The monolithic state structure causes redundant full-table rebuilds on transient events (such as text search input, column filter interaction, and row hover), complicates maintenance, and precludes atomic widget testing.

Modularizing these internal UI construction methods into specialized, decoupled sub-widgets restores architectural purity, optimizes rebuild boundaries, and ensures robust, isolated testability while strictly preserving backward compatibility.

## What Changes

- **Top Actions & Filtering Toolbar (`TableHeader`)**:
  - Extract `header()` into `lib/src/ui/custom_data_table/widgets/table_header.dart`.
  - Encapsulate the columns selector trigger (`SelectColumnsToShowDialog`), action buttons (copy, print, export), filter dialog triggers, and general search field with debouncing.
  - Communicate changes upstream via explicit, unidirectional callbacks.

- **Columns Header Row Container (`TableColumnsHeader`)**:
  - Extract `columnsWidget()` into `lib/src/ui/custom_data_table/widgets/table_columns_header.dart`.
  - Render the horizontal row of column headers with injected `ScrollController` synchronized via `LinkedScrollControllerGroup`.
  - Support fixed-width and flexible column layouts cleanly.

- **Atomic Column Header Cell (`TableColumnHeader`)**:
  - Extract `columnWidget()` and `columnFieldWidget()` into `lib/src/ui/custom_data_table/widgets/table_column_header.dart`.
  - Encapsulate sorting direction toggle/icon and optional column-level search field with individual debouncing.

- **Content Viewport & Dual Scrollbars (`TableContent`)**:
  - Extract `tableContent()` and viewport layout into `lib/src/ui/custom_data_table/widgets/table_content.dart`.
  - Coordinate dual scrollbars (horizontal and vertical) with injected scroll controllers.
  - Preserve bounded and unbounded layout adaptation (`calculateContentHeight` and finite vs infinite height constraints established in CDT-22).
  - Handle loading and exception builder fallbacks.

- **Atomic Row Widget (`TableRowWidget`)**:
  - Extract `rowWidget()` and default cell fallback into `lib/src/ui/custom_data_table/widgets/table_row_widget.dart`.
  - Name explicitly `TableRowWidget` to prevent class name collision with Flutter SDK's `TableRow` (`package:flutter/src/widgets/table.dart`).
  - Manage zebra striping background styling, row hover/tap interactions, and cell builder delegation.

- **Lean Orchestrator (`CustomDataTable`)**:
  - Refactor `_CustomDataTableState` to act solely as a declarative orchestrator of ~180 lines composing `TableHeader`, `TableColumnsHeader`, `TableContent`, and `TableFooter`.

- **Test Suite Mirroring**:
  - Establish dedicated widget test suites in `test/ui/custom_data_table/widgets/` mirroring each new subcomponent per the official Flutter Architecture Case Study.

## Capabilities

### New Capabilities
- `table-subcomponents-modularization`: Modularizes `CustomDataTable` internal UI rendering methods into specialized, decoupled widget classes (`TableHeader`, `TableColumnsHeader`, `TableColumnHeader`, `TableContent`, and `TableRowWidget`), optimizing rebuild boundaries and testability while preserving 100% backward compatibility and layout adaptability.

### Modified Capabilities

## Impact

- **Public API**: Zero breaking changes. `lib/custom_data_table.dart` and `CustomDataTable<T>` retain their identical public signature, types, and constructor parameters.
- **Dependencies**: No external dependencies added or removed in `pubspec.yaml`.
- **Performance**: Isolated rebuild scopes for text inputs, sorting toggles, and row hover states.
- **Internal Structure**: All sub-widgets encapsulated within `lib/src/ui/custom_data_table/widgets/`.
