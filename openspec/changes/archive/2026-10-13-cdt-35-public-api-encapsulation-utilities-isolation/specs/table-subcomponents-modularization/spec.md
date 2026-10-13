## MODIFIED Requirements

### Requirement: Specialized Table Header Component
The package SHALL provide a dedicated `TableHeader` widget under `lib/src/ui/custom_data_table/widgets/table_header.dart` that encapsulates the top actions toolbar, column visibility selection, export triggers, filter dialogs, general search bar, and configurable debouncing.

#### Scenario: Rendering top toolbar controls
- **WHEN** `TableHeader` is rendered with configured columns, search controller, and action callbacks
- **THEN** it displays the columns selector dropdown button, search input field, and available action buttons (copy, print, export) according to provided parameters

#### Scenario: Invoking column visibility dialog
- **WHEN** user taps the columns dropdown button in `TableHeader`
- **THEN** it opens `SelectColumnsToShowDialog` and triggers `onSelectedColumnsChanged` with the updated column selection

#### Scenario: Emitting general search input
- **WHEN** user types into the search field of `TableHeader`
- **THEN** it debounces input using `debounceDuration` (default 500ms) or an injected `TableDebouncer` and invokes the `onChangeGeneralSearch` callback with the current search query

---

### Requirement: Column Headers Row and Atomic Header Cell
The package SHALL provide `TableColumnsHeader` and `TableColumnHeader` under `lib/src/ui/custom_data_table/widgets/` to decouple the horizontal column titles row and individual column header cells, supporting configurable search debouncing.

#### Scenario: Rendering synchronized column header row
- **WHEN** `TableColumnsHeader` is provided a list of visible columns, an optional `debounceDuration`, and an injected `ScrollController`
- **THEN** it lays out each column according to its defined width or flex, horizontally scrollable via the provided controller, forwarding debounce settings to child headers

#### Scenario: Toggling sort direction on header cell
- **WHEN** user taps the sort button on a sortable `TableColumnHeader`
- **THEN** it toggles the sorting direction (ascending, descending) and emits the updated `SortInfo` via `onSort`

#### Scenario: Inputting column-specific search query
- **WHEN** a column with `canSearchInput: true` receives user input in its search field
- **THEN** `TableColumnHeader` debounces the input using `debounceDuration` (default 500ms) or an injected `TableDebouncer` and triggers the column search change callback with updated field values
