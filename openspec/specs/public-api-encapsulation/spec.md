# public-api-encapsulation Specification

## Purpose
TBD - created by archiving change cdt-35-public-api-encapsulation-utilities-isolation. Update Purpose after archive.
## Requirements
### Requirement: Public API Barrel Encapsulation
The package entrypoint `lib/custom_data_table.dart` SHALL strictly export only UI components, controllers, models, themes, and localization, and SHALL NOT export internal utilities from `src/utils/`.

#### Scenario: Consuming package without symbol collisions
- **WHEN** an external application imports `package:custom_data_table/custom_data_table.dart`
- **THEN** no extension methods on `String`, `DateTime`, or `BuildContext` and no top-level symbols such as `Debouncer`, `TableDebouncer`, `ScreenSize`, `StringExtension`, or `DateExtension` are exposed to the consuming namespace

### Requirement: Internal Extension Isolation and Pruning
The package SHALL encapsulate internal utility extensions under `Cdt` prefixed extension names (`CdtStringExtension`, `CdtDateExtension`) and prune unused dead methods.

#### Scenario: Natural capitalization utility
- **WHEN** `naturalCapitalized` is accessed on a `String` within the package
- **THEN** the first letter of each word is capitalized correctly according to `CdtStringExtension`

#### Scenario: Date boundary utilities
- **WHEN** date filter operations access `onlyDate`, `endOfDay`, `onlyMonth`, `onlyYear`, `startOfWeek`, `endOfWeek`, or `timeOfDay` on a `DateTime`
- **THEN** the corresponding boundary dates are returned correctly according to `CdtDateExtension` without exposing orphan methods `onlyTime`, `isBetween`, or `isBetweenIncluding`

### Requirement: Encapsulated Table Debouncer
The package SHALL provide `TableDebouncer` in `lib/src/utils/debounce.dart` to manage search input debouncing without global naming collisions.

#### Scenario: Debouncing actions with TableDebouncer
- **WHEN** a rapid sequence of actions is triggered through `TableDebouncer.run`
- **THEN** only the final action executes after the configured delay expires

