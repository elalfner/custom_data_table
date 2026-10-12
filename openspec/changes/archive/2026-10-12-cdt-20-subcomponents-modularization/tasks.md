## 1. Sub-widgets Extraction

- [x] 1.1 Implement `TableRowWidget` in `lib/src/ui/custom_data_table/widgets/table_row_widget.dart` extracting row decoration, zebra striping, hover, tap handling, and cell builders
- [x] 1.2 Implement `TableColumnHeader` in `lib/src/ui/custom_data_table/widgets/table_column_header.dart` extracting column title, sorting direction toggle, and column-specific search input
- [x] 1.3 Implement `TableColumnsHeader` in `lib/src/ui/custom_data_table/widgets/table_columns_header.dart` extracting horizontal column row layout and synchronized horizontal scroll controller
- [x] 1.4 Implement `TableContent` in `lib/src/ui/custom_data_table/widgets/table_content.dart` extracting dual scrollbars, separated row list, loading/exception states, and CDT-22 adaptive height constraints
- [x] 1.5 Implement `TableHeader` in `lib/src/ui/custom_data_table/widgets/table_header.dart` extracting column selector dialog trigger, action buttons, filter dialog triggers, and general search with debouncer

## 2. Orchestrator Refactor & Integration

- [x] 2.1 Refactor `CustomDataTable` and `_CustomDataTableState` in `lib/src/ui/custom_data_table/widgets/custom_data_table.dart` to compose extracted sub-widgets (~180 lines)
- [x] 2.2 Verify package entry point `lib/custom_data_table.dart` preserves all public exports and symbol visibility identically

## 3. Dedicated Widget Test Suites

- [x] 3.1 Create `test/ui/custom_data_table/widgets/table_row_widget_test.dart` verifying zebra striping, tap callback, and custom cell rendering
- [x] 3.2 Create `test/ui/custom_data_table/widgets/table_column_header_test.dart` verifying sort toggle and column search input debouncing
- [x] 3.3 Create `test/ui/custom_data_table/widgets/table_columns_header_test.dart` verifying horizontal column layout and scrolling
- [x] 3.4 Create `test/ui/custom_data_table/widgets/table_content_test.dart` verifying dual scrollbars, loading state, and bounded vs unbounded adaptability
- [x] 3.5 Create `test/ui/custom_data_table/widgets/table_header_test.dart` verifying search input, action button callbacks, and dialog triggers

## 4. Verification & Quality Gates

- [x] 4.1 Run static analysis via `flutter analyze --fatal-infos` ensuring 0 errors, warnings, and infos
- [x] 4.2 Verify code formatting via `dart format --output=none --set-exit-if-changed .`
- [x] 4.3 Run full test suite via `flutter test` ensuring all existing and new widget tests pass
- [x] 4.4 Run package publish dry-run via `flutter pub publish --dry-run` to ensure clean package payload
