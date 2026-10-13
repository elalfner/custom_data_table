## Context

In `custom_data_table` version 3.1.0, the public library entrypoint (`lib/custom_data_table.dart`) re-exports internal utility files:
- `src/utils/date_time_extension.dart`
- `src/utils/debounce.dart`
- `src/utils/responsive_helpers.dart`
- `src/utils/string_extension.dart`

When downstream Flutter applications (Mobile and Web) import `package:custom_data_table/custom_data_table.dart`, their global namespace is contaminated with extensions on Flutter/Dart core classes (`String`, `DateTime`, `BuildContext`) and top-level identifiers (`Debouncer`, `ScreenSize`). This triggers fatal Dart compiler errors:
- `ambiguous_extension_member_access`
- `ambiguous_import`
- `invocation_of_non_function`

Furthermore, `responsive_helpers.dart` imports `dart:io`, which is unnecessary and problematic on web platforms, while its screen size breakpoints are not used by the table widgets. Several unused methods also linger in `string_extension.dart` and `date_time_extension.dart`.

## Goals / Non-Goals

**Goals:**
- Eliminate utility re-exports from `lib/custom_data_table.dart`, preventing namespace pollution in consumer projects.
- Rename internal extensions to `CdtStringExtension` and `CdtDateExtension`, pruning dead methods (`convertStringToCode`, `convertCodeToString`, `splitFirstOccurrence`, `onlyTime`, `isBetween`, `isBetweenIncluding`).
- Remove `lib/src/utils/responsive_helpers.dart` and `test/utils/responsive_helpers_test.dart`, migrating `calculateContentHeight` unit tests to `test/ui/custom_data_table/widgets/table_content_test.dart`.
- Rename `Debouncer` to `TableDebouncer` in `lib/src/utils/debounce.dart` and support idiomatic `Duration debounceDuration = const Duration(milliseconds: 500)` and optional `TableDebouncer? debouncer` in `TableHeader`, `TableColumnsHeader`, and `TableColumnHeader`.
- Bump version to `3.1.1` in `pubspec.yaml` and record changes in `CHANGELOG.md`.
- Maintain 100% test pass rate, zero analyzer diagnostics with `--fatal-infos`, clean formatting, and valid pub dry-run.

**Non-Goals:**
- Redesigning table filtering or searching UI components beyond debounce configuration.
- Modifying backend or GraphQL data structures (this is a standalone Flutter package).
- Changing public APIs for table rows, columns, controllers, or themes.

## Decisions

### 1. Complete encapsulation of `src/utils/`
- **Decision**: Stop exporting `src/utils/` files in `lib/custom_data_table.dart`.
- **Rationale**: A UI data table package should only expose components, controllers, models, themes, and localization. Internal helpers are implementation details.
- **Alternatives Considered**:
  - *Exporting with `show`*: Still leaks utilities and creates naming hazards.
  - *Deprecated export*: Delays fixing breaking collisions for consumers on version 3.1.0.

### 2. Rename internal extensions with `Cdt` prefix
- **Decision**: Rename `StringExtension` to `CdtStringExtension` and `DateExtension` to `CdtDateExtension`.
- **Rationale**: Prevents accidental collision even when internal files import `src/utils/`.
- **Alternatives Considered**:
  - *Keeping generic names*: High risk of collision with standard utilities or core libraries in existing tests and internals.

### 3. Prune orphan methods and remove `responsive_helpers.dart`
- **Decision**: Remove dead code (`convertStringToCode`, `convertCodeToString`, `splitFirstOccurrence`, `onlyTime`, `isBetween`, `isBetweenIncluding`) and delete `responsive_helpers.dart`.
- **Rationale**: Keeps package payload minimal and removes `dart:io` import that has no purpose in a responsive Flutter widget library. `calculateContentHeight` already belongs to `TableContent`.
- **Alternatives Considered**:
  - *Keeping `responsive_helpers.dart` private*: Unnecessary maintenance overhead for dead code.

### 4. Idiomatic debouncing with `Duration debounceDuration`
- **Decision**: Add `final Duration debounceDuration = const Duration(milliseconds: 500);` to header widgets (`TableHeader`, `TableColumnsHeader`, `TableColumnHeader`) while retaining `final TableDebouncer? debouncer;` for test injection. Rename class to `TableDebouncer`.
- **Rationale**: In Flutter, configuring delays via `Duration` is idiomatic and simple for users without needing to instantiate utility classes.
- **Alternatives Considered**:
  - *Requiring `TableDebouncer` instance*: Forces boilerplate on developers just wanting to change the debounce time.

## Risks / Trade-offs

- **[Risk] Downstream apps relying on leaked utilities break on upgrade** → **Mitigation**: The previous export was an accidental leak that caused compile-time errors in consuming apps. Document the isolation clearly in `CHANGELOG.md` under `3.1.1` with guidance to implement local utilities or import standalone packages.
- **[Risk] Regressions in table height calculation after removing `responsive_helpers_test.dart`** → **Mitigation**: Move the complete test suite for `calculateContentHeight` into `test/ui/custom_data_table/widgets/table_content_test.dart` before deleting the old test file.
- **[Risk] Header search debouncing regressions** → **Mitigation**: Update and add unit tests in `table_header_test.dart` and `table_column_header_test.dart` asserting proper debouncing with default and custom durations.
