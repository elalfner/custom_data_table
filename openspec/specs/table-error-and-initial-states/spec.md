# table-error-and-initial-states Specification

## Purpose
TBD - created by archiving change cdt-30-explicit-error-and-initial-states. Update Purpose after archive.
## Requirements
### Requirement: Explicit Error Evaluation
`CustomDataTable` SHALL determine error status based on `hasError` when provided, and SHALL fall back to `(data == null && !isLoading)` only when `hasError` is `null`.

#### Scenario: Explicit error flag is true
- **WHEN** `hasError` is `true` and `data` is `null`
- **THEN** `CustomDataTable` renders the error state immediately regardless of `isLoading`

#### Scenario: Explicit error flag is false with null data
- **WHEN** `hasError` is `false`, `data` is `null`, and `isLoading` is `false`
- **THEN** `CustomDataTable` does NOT render error state and renders the initial/idle state instead

#### Scenario: Omitted hasError preserves legacy error fallback
- **WHEN** `hasError` is `null`, `data` is `null`, and `isLoading` is `false`
- **THEN** `CustomDataTable` evaluates as error and renders the error state for backwards compatibility

### Requirement: Canonical Error Builder Support
`CustomDataTable` SHALL support an `errorBuilder` callback receiving `BuildContext` and `Object? error`, prioritizing it over `exceptionBuilder`.

#### Scenario: Error builder provided with error object
- **WHEN** `hasError` is `true`, `error` is provided as an object, and `errorBuilder` is configured
- **THEN** `CustomDataTable` invokes `errorBuilder(context, error)` passing the valid error payload

#### Scenario: Legacy exceptionBuilder fallback when errorBuilder omitted
- **WHEN** `hasError` is `true`, `errorBuilder` is `null`, and `exceptionBuilder` is configured
- **THEN** `CustomDataTable` invokes `exceptionBuilder()` without throwing exceptions

### Requirement: Initial Idle State Rendering
`CustomDataTable` SHALL render an optional `initialBuilder` when `data == null && !isLoading && hasError == false`.

#### Scenario: Custom initialBuilder provided
- **WHEN** `data` is `null`, `isLoading` is `false`, `hasError` is `false`, and `initialBuilder` is provided
- **THEN** `CustomDataTable` renders the widget produced by `initialBuilder`

#### Scenario: Default initial state when initialBuilder omitted
- **WHEN** `data` is `null`, `isLoading` is `false`, `hasError` is `false`, and `initialBuilder` is `null`
- **THEN** `CustomDataTable` renders an empty `const SizedBox()` without displaying error indicators

### Requirement: Background Refetch Error Banner
`CustomDataTable` SHALL support displaying an error banner above existing table rows when `data != null`, `hasError == true`, and `showErrorBanner == true`.

#### Scenario: Background error with banner enabled
- **WHEN** `data` contains rows, `hasError` is `true`, and `showErrorBanner` is `true`
- **THEN** `CustomDataTable` preserves all data rows and displays an error banner above the rows

#### Scenario: Background error with banner disabled
- **WHEN** `data` contains rows, `hasError` is `true`, and `showErrorBanner` is `false`
- **THEN** `CustomDataTable` preserves all data rows without displaying an error banner

