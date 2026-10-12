## ADDED Requirements

### Requirement: Pagination Control Lockdown During Loading
`CustomDataTable` SHALL disable pagination controls (previous page button, next page button, and page selector popup button) whenever `isLoading` is `true`, while preserving page selector geometry without layout shifts.

#### Scenario: Previous and next buttons disabled when loading
- **WHEN** `isLoading` is `true` and the table has multiple pages
- **THEN** the previous page and next page `IconButton` widgets have `onPressed: null` and cannot be activated

#### Scenario: Page selector popup disabled without layout shift during loading
- **WHEN** `isLoading` is `true` and the table has multiple pages
- **THEN** the page selector tap handler is inactive (`onTap: null`), the button container preserves its fill background and dimensions, the dropdown arrow icon remains visible, and the page number text and icon render with `Theme.of(context).disabledColor`

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

### Requirement: Interactive Example Application Verification
The `example/` application SHALL provide interactive controls to simulate asynchronous network data fetching with latency alongside a realistic static single-page mode.

#### Scenario: Asynchronous web service simulation in example
- **WHEN** the user selects the simulated web service mode in `example/lib/main.dart` and triggers page navigation
- **THEN** the table displays `isLoading: true`, activates the top linear indicator, locks pagination navigation buttons during the simulated latency delay, and renders updated page items upon completion

#### Scenario: Realistic static single page mode in example
- **WHEN** the user selects the static data mode in `example/lib/main.dart`
- **THEN** the table displays a realistic set of records configured with single-page pagination metadata

### Requirement: Consistent Single-Page Selector Pill Styling
`TablePaginatedCountWidget` SHALL preserve its fill background (`inputDecorationTheme.fillColor`) and pill geometry even when `lastPage == 1`, matching the styling of `TablePerPageWidget`.

#### Scenario: Single-page pill styling
- **WHEN** the table has only 1 page (`lastPage == 1`)
- **THEN** the page number button renders with `Theme.of(context).inputDecorationTheme.fillColor` and rounded border, omits the dropdown arrow icon, and has `onTap: null`

### Requirement: Compact Empty State Viewport Dimensions
`TableContent` SHALL bound the empty state viewport to a proportionate, compact height (~100.0 px) in both bounded and unbounded vertical constraints, with an icon size of 30.0 px.

#### Scenario: Compact empty state rendering
- **WHEN** `data` is empty (`[]`)
- **THEN** `TableContent` renders with a constrained height of 100.0 px and an inbox icon sized at 30.0 px

### Requirement: Zero-Results Footer Range Formatting
`TableFooter.resultsNumberWidget` SHALL format the results count cleanly when `total == 0`, avoiding invalid ranges like "1 to 0".

#### Scenario: Zero results footer text
- **WHEN** `paginatorInfo.total` is `0`
- **THEN** `TableFooter` renders `0 results` without displaying a "showing 1 to 0" range
