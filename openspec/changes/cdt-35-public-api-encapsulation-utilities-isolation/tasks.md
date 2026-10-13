## 1. Public API Barrel Encapsulation

- [x] 1.1 Remove utility re-exports (`date_time_extension.dart`, `debounce.dart`, `responsive_helpers.dart`, `string_extension.dart`) from `lib/custom_data_table.dart`

## 2. Utility Refactoring and Pruning

- [x] 2.1 Rename `StringExtension` to `CdtStringExtension` in `lib/src/utils/string_extension.dart` and remove unused methods (`convertStringToCode`, `convertCodeToString`, `splitFirstOccurrence`)
- [x] 2.2 Rename `DateExtension` to `CdtDateExtension` in `lib/src/utils/date_time_extension.dart` and remove unused methods (`onlyTime`, `isBetween`, `isBetweenIncluding`)
- [x] 2.3 Rename `Debouncer` to `TableDebouncer` in `lib/src/utils/debounce.dart`

## 3. Removal of responsive_helpers.dart and Test Migration

- [x] 3.1 Migrate `calculateContentHeight` unit tests from `test/utils/responsive_helpers_test.dart` to `test/ui/custom_data_table/widgets/table_content_test.dart`
- [x] 3.2 Remove `lib/src/utils/responsive_helpers.dart` and `test/utils/responsive_helpers_test.dart`

## 4. Header Debounce Configuration

- [x] 4.1 Update `TableHeader`, `TableColumnsHeader`, and `TableColumnHeader` to accept `debounceDuration` (default 500ms) and `TableDebouncer? debouncer`
- [x] 4.2 Update unit and widget tests in `test/ui/custom_data_table/widgets/table_header_test.dart` and `test/ui/custom_data_table/widgets/table_column_header_test.dart` to verify custom debounce duration and `TableDebouncer`

## 5. Version Bump and Quality Verification

- [x] 5.1 Bump package version to `3.1.1` in `pubspec.yaml` and document fixes under `## 3.1.1` in `CHANGELOG.md`
- [x] 5.2 Verify formatting (`dart format`), static analysis (`flutter analyze --fatal-infos`), tests (`flutter test`), and dry run (`flutter pub publish --dry-run`)
