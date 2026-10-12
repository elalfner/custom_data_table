## Why

The `custom_data_table` package currently relies on an outdated folder structure (`presentation/`, `entities/`, `core/`) with secondary classes embedded directly inside primary files (such as `TableController` and `SelectColumnsToShowDialog` nested inside `custom_data_table.dart`). 

Aligning the internal structure to Google's official Flutter Architecture Case Study standard improves maintainability, navigability, and code readability without altering runtime behavior or breaking the public API surface.

## What Changes

- **Domain Layer Reorganization**: Relocate pure Dart domain models and enums from `lib/src/domain/entities/` and `lib/src/domain/enums/` to `lib/src/domain/models/`.
- **Transversal Utilities**: Relocate utilities from `lib/src/core/utils/` and `lib/src/core/helpers/` to `lib/src/utils/`.
- **Core UI Layer**: Move theme definitions to `lib/src/ui/core/themes/` and shared reusable visual components to `lib/src/ui/core/ui/`.
- **Feature UI Layer**: Group the primary table widget and its components under `lib/src/ui/custom_data_table/`, separating view models (`TableController`) and sub-widgets (`TableFooter`, dialogs, etc.).
- **Decouple Embedded Classes**:
  - Extract `TableController` from `custom_data_table.dart` to `lib/src/ui/custom_data_table/view_models/table_controller.dart`.
  - Extract `SelectColumnsToShowDialog` from `custom_data_table.dart` to `lib/src/ui/custom_data_table/widgets/select_columns_dialog.dart`.
  - Extract `ColumnId` from `column_info.dart` to `lib/src/domain/models/column_id.dart`.
  - Extract `FilterSection` from `filter_item.dart` to `lib/src/domain/models/filter_section.dart`.
  - Extract `SelectPageWidget` from `table_paginated_count_widget.dart` to `lib/src/ui/custom_data_table/widgets/pagination/select_page_dialog.dart`.
  - Extract `FiltersView` from `custom_filters.dart` to `lib/src/ui/core/ui/filters/filters_view.dart`.
  - Extract `_DateFilterView` from `dates_filter_chip.dart` to `lib/src/ui/core/ui/date_filter/date_filter_dialog.dart`.
  - Rename `filters/time_filter.dart` to `date_time_range_picker.dart` under `lib/src/ui/core/ui/date_filter/`.
- **Testing Mirror**: Mirror the internal source structure in `test/` (modularizing into focused suites) and prepare `test/testing/` for fixtures and test fakes.
- **Strict Backward Compatibility**: Ensure `lib/custom_data_table.dart` exports all public entities, enums, themes, and widgets identically.

## Capabilities

### New Capabilities
- `flutter-architecture-restructure`: Restructures package layout into canonical Flutter Architecture layers (`domain/models`, `utils`, `ui/core`, `ui/custom_data_table`), extracts embedded classes into separate files, and mirrors the testing directory layout with zero behavioral regressions.

### Modified Capabilities

## Impact

- **Public API**: Zero breaking changes. `lib/custom_data_table.dart` exports identical classes and symbols. Consuming applications (e.g., `viali_panel`) require no code changes.
- **Internal Imports**: All relative import directives across `lib/src/` and `test/` will be updated to reflect the new file locations.
- **Dependencies**: No external dependency changes in `pubspec.yaml`.
