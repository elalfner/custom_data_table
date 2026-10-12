# table-subcomponents-modularization Specification

## Purpose
TBD - created by archiving change cdt-20-subcomponents-modularization. Update Purpose after archive.
## Requirements
### Requirement: Specialized Table Header Component
The package SHALL provide a dedicated `TableHeader` widget under `lib/src/ui/custom_data_table/widgets/table_header.dart` that encapsulates the top actions toolbar, column visibility selection, export triggers, filter dialogs, and general search bar.

#### Scenario: Rendering top toolbar controls
- **WHEN** `TableHeader` is rendered with configured columns, search controller, and action callbacks
- **THEN** it displays the columns selector dropdown button, search input field, and available action buttons (copy, print, export) according to provided parameters

#### Scenario: Invoking column visibility dialog
- **WHEN** user taps the columns dropdown button in `TableHeader`
- **THEN** it opens `SelectColumnsToShowDialog` and triggers `onSelectedColumnsChanged` with the updated column selection

#### Scenario: Emitting general search input
- **WHEN** user types into the search field of `TableHeader`
- **THEN** it debounces input and invokes the `onChangeGeneralSearch` callback with the current search query

---

### Requirement: Column Headers Row and Atomic Header Cell
The package SHALL provide `TableColumnsHeader` and `TableColumnHeader` under `lib/src/ui/custom_data_table/widgets/` to decouple the horizontal column titles row and individual column header cells.

#### Scenario: Rendering synchronized column header row
- **WHEN** `TableColumnsHeader` is provided a list of visible columns and an injected `ScrollController`
- **THEN** it lays out each column according to its defined width or flex, horizontally scrollable via the provided controller

#### Scenario: Toggling sort direction on header cell
- **WHEN** user taps the sort button on a sortable `TableColumnHeader`
- **THEN** it toggles the sorting direction (ascending, descending) and emits the updated `SortInfo` via `onSort`

#### Scenario: Inputting column-specific search query
- **WHEN** a column with `canSearchInput: true` receives user input in its search field
- **THEN** `TableColumnHeader` debounces the input and triggers the column search change callback with updated field values

---

### Requirement: Content Viewport and Dual Scrollbars
The package SHALL provide `TableContent` under `lib/src/ui/custom_data_table/widgets/table_content.dart` to manage the viewport, dual scrollbars (horizontal and vertical), and layout adaptation for bounded and unbounded height constraints.

#### Scenario: Synchronizing dual scrollable viewport
- **WHEN** `TableContent` renders with horizontal and vertical scroll controllers
- **THEN** it attaches both scrollbars, displaying content rows in a separated list while scrolling horizontally in sync with `TableColumnsHeader`

#### Scenario: Adapting height in bounded vs unbounded constraints
- **WHEN** `TableContent` receives `BoxConstraints`
- **THEN** it calculates required content height via `calculateContentHeight` and renders within a `Flexible` container when bounded, or a fixed `SizedBox` container when unbounded, avoiding layout overflows

#### Scenario: Displaying loading and exception states
- **WHEN** table data is null
- **THEN** `TableContent` renders the custom `loadingBuilder` (or default progress indicator) when `isLoading` is true, or the custom `exceptionBuilder` when loading is false

---

### Requirement: Atomic Row Component and Zebra Striping
The package SHALL provide `TableRowWidget` under `lib/src/ui/custom_data_table/widgets/table_row_widget.dart` to render individual rows, handling alternating background decorations, hover feedback, and cell building.

#### Scenario: Applying zebra striping background
- **WHEN** `TableRowWidget` renders for a given row index
- **THEN** it applies `evenRowTheme` decoration for even indices and `oddRowTheme` decoration for odd indices

#### Scenario: Delegating row tap and custom cell builders
- **WHEN** user interacts with a row
- **THEN** `TableRowWidget` triggers `onTapRow` with the row element and delegates cell rendering to the provided `cell` builder or default text fallback

---

### Requirement: Orchestrator Integration and Public API Transparency
The package SHALL maintain `CustomDataTable` as a lean orchestrator of ~180 lines in `lib/src/ui/custom_data_table/widgets/custom_data_table.dart` that composes `TableHeader`, `TableColumnsHeader`, `TableContent`, and `TableFooter` with zero breaking changes to consumers.

#### Scenario: Backward compatibility preservation
- **WHEN** a client application instantiates `CustomDataTable<T>` using existing parameters
- **THEN** all visual elements, callbacks, and behaviors function identically without modification to consumer code

