## Why

In `custom_data_table` version 3.1.0, the public barrel file (`lib/custom_data_table.dart`) re-exports general-purpose utility files from `src/utils/`:
- `src/utils/date_time_extension.dart`
- `src/utils/debounce.dart`
- `src/utils/responsive_helpers.dart`
- `src/utils/string_extension.dart`

When consumer applications (Flutter Mobile and Web) import `package:custom_data_table/custom_data_table.dart`, the global namespace is polluted with generic extensions on SDK classes (`String`, `DateTime`, `BuildContext`) and top-level identifiers such as `Debouncer`, `ScreenSize`, `StringExtension`, and `DateExtension`. This causes fatal compiler name collisions (`ambiguous_extension_member_access`, `ambiguous_import`, `invocation_of_non_function`), forcing downstream applications to write awkward `hide` clauses.

Additionally, dead utility code exists in `src/utils/` (such as orphan helper methods and unused screen size logic in `responsive_helpers.dart`), while debouncing mechanisms need idiomatic `Duration debounceDuration` configuration and encapsulation into `TableDebouncer`.

## What Changes

- **Public Barrel Clean-up**: Remove re-exports of `src/utils/date_time_extension.dart`, `src/utils/debounce.dart`, `src/utils/responsive_helpers.dart`, and `src/utils/string_extension.dart` from `lib/custom_data_table.dart`.
- **Internal Extension Isolation and Pruning**:
  - Rename `StringExtension on String` to `CdtStringExtension on String` in `lib/src/utils/string_extension.dart` to prevent collision even in internal imports, and prune unused dead methods (`convertStringToCode`, `convertCodeToString`, `splitFirstOccurrence`), retaining `naturalCapitalized`.
  - Rename `DateExtension on DateTime` to `CdtDateExtension on DateTime` in `lib/src/utils/date_time_extension.dart`, and prune unused dead methods (`onlyTime`, `isBetween`, `isBetweenIncluding`), retaining date manipulation utilities needed by date filters (`onlyDate`, `endOfDay`, `onlyMonth`, `onlyYear`, `startOfWeek`, `endOfWeek`, `timeOfDay`).
- **Removal of Dead `responsive_helpers.dart`**:
  - Delete `lib/src/utils/responsive_helpers.dart` (which also removes an unnecessary `dart:io` import that could affect Web platforms).
  - Migrate unit tests for `calculateContentHeight` from `test/utils/responsive_helpers_test.dart` to `test/ui/custom_data_table/widgets/table_content_test.dart`.
  - Remove `test/utils/responsive_helpers_test.dart`.
- **Debouncing Encapsulation**:
  - Rename `Debouncer` to `TableDebouncer` in `lib/src/utils/debounce.dart`.
  - In `TableHeader`, `TableColumnsHeader`, and `TableColumnHeader`, add `final Duration debounceDuration = const Duration(milliseconds: 500);` and update `debouncer` to `final TableDebouncer? debouncer;`.
  - Update unit tests in `table_header_test.dart` and `table_column_header_test.dart` to verify custom debounce duration and `TableDebouncer` behavior.
- **Version Bump and Release Prep**:
  - Bump package version to `3.1.1` in `pubspec.yaml`.
  - Document all fixes under `## 3.1.1` in `CHANGELOG.md`.

## Capabilities

### New Capabilities
- `public-api-encapsulation`: Strict encapsulation of the public barrel export `lib/custom_data_table.dart`, preventing utility and extension leakage into consuming projects, pruning unused internal utilities, and prefixing internal extensions with `Cdt`.

### Modified Capabilities
- `table-subcomponents-modularization`: Support idiomatic `debounceDuration` parameter (default 500ms) and encapsulated `TableDebouncer` in `TableHeader`, `TableColumnsHeader`, and `TableColumnHeader`.

## Impact

- `lib/custom_data_table.dart`: Ceases exporting utility files (`date_time_extension.dart`, `debounce.dart`, `responsive_helpers.dart`, `string_extension.dart`).
- `lib/src/utils/`:
  - `responsive_helpers.dart` is deleted.
  - `string_extension.dart` renamed to `CdtStringExtension` and pruned.
  - `date_time_extension.dart` renamed to `CdtDateExtension` and pruned.
  - `debounce.dart` updated with `TableDebouncer`.
- `lib/src/ui/custom_data_table/widgets/`:
  - `table_header.dart`, `table_columns_header.dart`, `table_column_header.dart` receive `debounceDuration` and `TableDebouncer`.
- `test/`:
  - `test/utils/responsive_helpers_test.dart` deleted.
  - `test/ui/custom_data_table/widgets/table_content_test.dart` gains unit tests for `calculateContentHeight`.
  - `test/ui/custom_data_table/widgets/table_header_test.dart` and `table_column_header_test.dart` updated to test debounce duration and `TableDebouncer`.
- `pubspec.yaml` & `CHANGELOG.md`: Bump to 3.1.1.
