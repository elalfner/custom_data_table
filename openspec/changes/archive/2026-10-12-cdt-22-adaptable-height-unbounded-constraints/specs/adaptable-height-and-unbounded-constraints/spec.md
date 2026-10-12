## ADDED Requirements

### Requirement: Layout Adaptation under Bounded Height Constraints
`CustomDataTable` SHALL wrap table content within a `Flexible` widget when incoming vertical constraints are bounded (`constraints.hasBoundedHeight == true`), allowing the table to utilize available viewport height and support internal vertical scrolling when row content exceeds container boundaries.

#### Scenario: Table rendered inside bounded container
- **WHEN** `CustomDataTable` is placed inside a container with finite height constraints (such as `Expanded` or `SizedBox` with bounded height)
- **THEN** the table body renders within a `Flexible` child and enables internal vertical scroll behavior if content height exceeds available space

### Requirement: Layout Adaptation under Unbounded Height Constraints
`CustomDataTable` SHALL wrap table content within a fixed-height container (`SizedBox(height: contentHeight + 10)`) when incoming vertical constraints are unbounded (`constraints.hasBoundedHeight == false`), avoiding `RenderFlex` flex errors.

#### Scenario: Table rendered inside vertical scrollable viewport
- **WHEN** `CustomDataTable` is placed inside a container with unbounded vertical constraints (such as a vertical `SingleChildScrollView` or `ListView`)
- **THEN** the table renders without throwing `RenderFlex` exceptions and displays its content container sized to natural calculated height

### Requirement: Pure Synchronous Content Height Calculation
`CustomDataTable` SHALL calculate content height synchronously using a pure function without mutating reactive state or `ValueNotifier` instances during the widget `build()` execution.

#### Scenario: Synchronous calculation for non-empty data
- **WHEN** `CustomDataTable` builds with a non-empty `data` list of length `N`
- **THEN** content height is computed synchronously as `(minRowHeight * N) + (dividerHeight * (N - 1))` without mutating state during build

#### Scenario: Synchronous calculation for empty data
- **WHEN** `CustomDataTable` builds with an empty `data` list (`[]`)
- **THEN** content height is computed synchronously as `0.0` without throwing arithmetic errors or mutating state during build
