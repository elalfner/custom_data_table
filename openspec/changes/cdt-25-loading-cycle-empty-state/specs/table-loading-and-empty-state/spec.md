## ADDED Requirements

### Requirement: Pagination Control Lockdown During Loading
`CustomDataTable` SHALL disable pagination controls (previous page button, next page button, and page selector popup button) whenever `isLoading` is `true`.

#### Scenario: Previous and next buttons disabled when loading
- **WHEN** `isLoading` is `true` and the table has multiple pages
- **THEN** the previous page and next page `IconButton` widgets have `onPressed: null` and cannot be activated

#### Scenario: Page selector popup disabled when loading
- **WHEN** `isLoading` is `true`
- **THEN** the page selector tap handler is inactive (`onTap: null`), preventing the page selection modal from opening

### Requirement: Independent Loading Indicator Visibility
`CustomDataTable` SHALL decouple the top linear loading bar from initial load, displaying the top `LinearProgressIndicator` only when `isLoading == true` and existing `data != null`.

#### Scenario: Initial loading state
- **WHEN** `isLoading` is `true` and `data` is `null`
- **THEN** the top `LinearProgressIndicator` is not rendered, and the central `loadingBuilder` (or default `CircularProgressIndicator`) is displayed

#### Scenario: Background refresh loading state
- **WHEN** `isLoading` is `true` and `data` is non-null
- **THEN** the existing table rows remain visible and the top `LinearProgressIndicator` is displayed

### Requirement: Configurable Empty State Builder
`CustomDataTable` SHALL provide an optional `emptyBuilder` callback that is rendered when `data != null && data.isEmpty`.

#### Scenario: Custom empty builder provided
- **WHEN** `data` is empty (`[]`) and `emptyBuilder` is provided
- **THEN** `CustomDataTable` renders the widget returned by `emptyBuilder`

#### Scenario: Default localized empty placeholder when emptyBuilder is omitted
- **WHEN** `data` is empty (`[]`) and `emptyBuilder` is null
- **THEN** `CustomDataTable` renders a centered localized empty state with an icon and `noResultsFound` text ("No results found" in English, "No se han encontrado resultados" in Spanish)
