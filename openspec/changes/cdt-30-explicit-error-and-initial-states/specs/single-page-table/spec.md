# single-page-table Specification

## MODIFIED Requirements

### Requirement: Decoupled Loading and Error States
`CustomDataTable` SHALL trigger loading, error, and initial builders independent of `paginatorInfo`, evaluating error status via `hasError` with fallback to `data` presence and `isLoading`.

#### Scenario: Initial loading state with null data
- **WHEN** `data` is `null` and `isLoading` is `true`
- **THEN** `CustomDataTable` renders `loadingBuilder` or the default `CircularProgressIndicator`

#### Scenario: Background loading state with existing data
- **WHEN** `data` is non-null and `isLoading` is `true`
- **THEN** `CustomDataTable` renders existing rows and displays the top `LinearProgressIndicator`

#### Scenario: Exception state with null data and explicit or legacy error
- **WHEN** `data` is `null` and error is detected (`hasError == true` or `hasError == null && !isLoading`)
- **THEN** `CustomDataTable` renders `errorBuilder`, `exceptionBuilder`, or default error state

#### Scenario: Initial state with null data and hasError false
- **WHEN** `data` is `null`, `isLoading` is `false`, and `hasError` is `false`
- **THEN** `CustomDataTable` renders `initialBuilder` or `const SizedBox()` without triggering error states
