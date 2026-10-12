## 1. Domain Models Extraction and Relocation

- [x] 1.1 Move domain models and enums from `lib/src/domain/entities/` and `lib/src/domain/enums/` into `lib/src/domain/models/`
- [x] 1.2 Extract `ColumnId` from `column_info.dart` into `lib/src/domain/models/column_id.dart`
- [x] 1.3 Extract `FilterSection` from `filter_item.dart` into `lib/src/domain/models/filter_section.dart`

## 2. Utilities Relocation

- [x] 2.1 Move utility and helper files from `lib/src/core/utils/` and `lib/src/core/helpers/` into `lib/src/utils/`

## 3. Core UI and Themes Relocation

- [x] 3.1 Move theme definitions from `lib/src/presentation/theme/` to `lib/src/ui/core/themes/`
- [x] 3.2 Move date filtering components into `lib/src/ui/core/ui/date_filter/`, extract `_DateFilterView` to `date_filter_dialog.dart`, and rename `time_filter.dart` to `date_time_range_picker.dart`
- [x] 3.3 Move filter components into `lib/src/ui/core/ui/filters/` and extract `FiltersView` to `filters_view.dart`

## 4. Feature UI Decoupling

- [x] 4.1 Extract `TableController` from `custom_data_table.dart` to `lib/src/ui/custom_data_table/view_models/table_controller.dart`
- [x] 4.2 Extract `SelectColumnsToShowDialog` from `custom_data_table.dart` to `lib/src/ui/custom_data_table/widgets/select_columns_dialog.dart`
- [x] 4.3 Extract `SelectPageWidget` from `table_paginated_count_widget.dart` to `lib/src/ui/custom_data_table/widgets/pagination/select_page_dialog.dart`
- [x] 4.4 Relocate remaining table widgets (`custom_data_table.dart`, `table_footer.dart`, `both_directions_listview_builder.dart`, `per_page_widget.dart`) under `lib/src/ui/custom_data_table/widgets/`

## 5. Barrel File and Import Resolution

- [x] 5.1 Update internal relative imports across all relocated and newly extracted files
- [x] 5.2 Update `lib/custom_data_table.dart` export directives preserving 100% public API compatibility
- [x] 5.3 Remove obsolete empty legacy directories under `lib/src/`

## 6. Testing Structure Mirroring and Quality Verification

- [x] 6.1 Set up `test/testing/` directory for shared test fixtures and fakes
- [x] 6.2 Decompose monolithic `test/custom_data_table_test.dart` into modular test suites mirroring `lib/src/`:
  - `test/domain/models/column_info_test.dart`
  - `test/domain/models/date_selection_test.dart`
  - `test/domain/models/paginator_info_test.dart`
  - `test/utils/responsive_helpers_test.dart`
  - `test/ui/core/localization_test.dart`
  - `test/ui/custom_data_table/custom_data_table_test.dart`
- [x] 6.3 Verify all tests pass (`flutter test`) with zero failures
- [x] 6.4 Verify static analysis (`flutter analyze --fatal-infos`) and formatting (`dart format --output=none --set-exit-if-changed .`)
- [x] 6.5 Verify package publishing dry-run (`flutter pub publish --dry-run`)
