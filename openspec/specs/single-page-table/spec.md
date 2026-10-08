# single-page-table Specification

## Purpose
TBD - created by archiving change cdt-16-single-page-table. Update Purpose after archive.
## Requirements
### Requirement: Unpaginated Data Rendering
`CustomDataTable` SHALL render data rows, columns, and search filters when `data` is non-null and `paginatorInfo` is `null`.

#### Scenario: Data provided with null paginatorInfo
- **WHEN** `data` contains items and `paginatorInfo` is `null`
- **THEN** the table renders all columns and rows without displaying loading indicators or empty exception widgets

#### Scenario: Empty data list provided with null paginatorInfo
- **WHEN** `data` is an empty list (`[]`) and `paginatorInfo` is `null`
- **THEN** the table renders headers and an empty body without throwing exceptions

### Requirement: Pagination Footer Omission
`CustomDataTable` SHALL omit the `TableFooter` widget when `paginatorInfo` is `null`.

#### Scenario: Null paginatorInfo omits TableFooter
- **WHEN** `paginatorInfo` is `null`
- **THEN** the footer area renders `const SizedBox()` and no `TableFooter` exists in the widget tree

#### Scenario: Provided paginatorInfo renders TableFooter
- **WHEN** `paginatorInfo` is provided with valid pagination values
- **THEN** `TableFooter` is present in the widget tree with page navigation and per-page selection controls

### Requirement: Decoupled Loading and Error States
`CustomDataTable` SHALL trigger loading and exception builders solely based on `data` presence and the `isLoading` property, independent of `paginatorInfo`.

#### Scenario: Initial loading state with null data
- **WHEN** `data` is `null` and `isLoading` is `true`
- **THEN** `CustomDataTable` renders `loadingBuilder` or the default `CircularProgressIndicator`

#### Scenario: Background loading state with existing data
- **WHEN** `data` is non-null and `isLoading` is `true`
- **THEN** `CustomDataTable` renders existing rows and displays the top `LinearProgressIndicator`

#### Scenario: Exception or empty state with null data
- **WHEN** `data` is `null` and `isLoading` is `false`
- **THEN** `CustomDataTable` renders `exceptionBuilder` or `const SizedBox()`

