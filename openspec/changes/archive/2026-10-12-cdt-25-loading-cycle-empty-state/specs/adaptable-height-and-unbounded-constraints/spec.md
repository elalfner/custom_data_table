## MODIFIED Requirements

### Requirement: Layout Adaptation under Unbounded Height Constraints
`CustomDataTable` SHALL wrap table content within a sized container when incoming vertical constraints are unbounded (`constraints.hasBoundedHeight == false`), avoiding `RenderFlex` flex errors while allocating adequate height for content or empty state representations.

#### Scenario: Table rendered inside vertical scrollable viewport
- **WHEN** `CustomDataTable` is placed inside a container with unbounded vertical constraints (such as a vertical `SingleChildScrollView` or `ListView`)
- **THEN** the table renders without throwing `RenderFlex` exceptions and displays its content container sized to natural calculated height

#### Scenario: Table rendered inside vertical scrollable viewport with empty data
- **WHEN** `CustomDataTable` is placed inside a container with unbounded vertical constraints and an empty data list (`[]`)
- **THEN** the table renders without throwing `RenderFlex` exceptions and allocates a minimum comfortable height (160.0 px) for the empty placeholder instead of collapsing to 10px

### Requirement: Pure Synchronous Content Height Calculation
`CustomDataTable` SHALL calculate content height synchronously using a pure function without mutating reactive state or `ValueNotifier` instances during the widget `build()` execution, ensuring clean reset when data transitions to null.

#### Scenario: Synchronous calculation for non-empty data
- **WHEN** `CustomDataTable` builds with a non-empty `data` list of length `N`
- **THEN** content height is computed synchronously as `(minRowHeight * N) + (dividerHeight * (N - 1))` without mutating state during build

#### Scenario: Synchronous calculation for empty data
- **WHEN** `CustomDataTable` builds with an empty `data` list (`[]`)
- **THEN** content height is computed synchronously as `0.0` without throwing arithmetic errors or mutating state during build

#### Scenario: Synchronous clean reset when data transitions to null
- **WHEN** `CustomDataTable` rebuilds with `data` transitioning from a populated list to `null`
- **THEN** content height evaluates synchronously to `null` without retaining previous height or relying on reactive `contentHeight.value` mutations
