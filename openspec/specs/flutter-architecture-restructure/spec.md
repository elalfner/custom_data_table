# flutter-architecture-restructure Specification

## Purpose
TBD - created by archiving change cdt-18-flutter-architecture-restructure. Update Purpose after archive.
## Requirements
### Requirement: Canonical Directory Layout
The package codebase SHALL organize internal sources under `lib/src/` adhering to the Flutter Architecture standard: `domain/models/`, `utils/`, `ui/core/`, and `ui/custom_data_table/`.

#### Scenario: Verify domain models location
- **WHEN** domain entity and enum files are inspected
- **THEN** they MUST reside inside `lib/src/domain/models/` without dependencies on Flutter UI rendering packages

#### Scenario: Verify transversal utilities location
- **WHEN** utility and extension files are inspected
- **THEN** they MUST reside inside `lib/src/utils/`

#### Scenario: Verify core themes and shared UI location
- **WHEN** theme and reusable UI components are inspected
- **THEN** themes MUST reside under `lib/src/ui/core/themes/` and shared widgets under `lib/src/ui/core/ui/`

#### Scenario: Verify feature UI module location
- **WHEN** table feature components and view models are inspected
- **THEN** the controller MUST reside under `lib/src/ui/custom_data_table/view_models/` and table widgets under `lib/src/ui/custom_data_table/widgets/`

### Requirement: Decoupling Embedded Secondary Classes
Secondary and auxiliary classes embedded within host files SHALL be decoupled into dedicated, single-responsibility files.

#### Scenario: Decouple TableController and SelectColumnsToShowDialog
- **WHEN** `custom_data_table.dart` is refactored
- **THEN** `TableController` MUST reside in `lib/src/ui/custom_data_table/view_models/table_controller.dart` and `SelectColumnsToShowDialog` MUST reside in `lib/src/ui/custom_data_table/widgets/select_columns_dialog.dart`

#### Scenario: Decouple ColumnId and FilterSection
- **WHEN** `column_info.dart` and `filter_item.dart` are refactored
- **THEN** `ColumnId` MUST reside in `lib/src/domain/models/column_id.dart` and `FilterSection` MUST reside in `lib/src/domain/models/filter_section.dart`

#### Scenario: Decouple pagination and filter dialogs
- **WHEN** `table_paginated_count_widget.dart`, `custom_filters.dart`, and `dates_filter_chip.dart` are refactored
- **THEN** `SelectPageWidget` MUST reside in `lib/src/ui/custom_data_table/widgets/pagination/select_page_dialog.dart`, `FiltersView` in `lib/src/ui/core/ui/filters/filters_view.dart`, `_DateFilterView` in `lib/src/ui/core/ui/date_filter/date_filter_dialog.dart`, and `time_filter.dart` renamed to `date_time_range_picker.dart`

### Requirement: Backward-Compatible Public Barrel
The public entry point `lib/custom_data_table.dart` SHALL maintain 100% backward compatibility by exporting all public types, enums, themes, and widgets.

#### Scenario: Consumer imports package entrypoint
- **WHEN** an external project imports `package:custom_data_table/custom_data_table.dart`
- **THEN** all public APIs previously exposed MUST remain accessible without compilation errors

### Requirement: Mirrored Test Directory Structure
The test suite SHALL mirror the `lib/src/` structure under `test/`, with dedicated folders and unit/widget test verification.

#### Scenario: Execute automated tests
- **WHEN** `flutter test` is executed
- **THEN** all test suites MUST run and pass with zero failures

#### Scenario: Execute static analysis
- **WHEN** `flutter analyze --fatal-infos` is executed
- **THEN** analysis MUST pass with zero errors, warnings, or infos

