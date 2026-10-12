## Context

The `custom_data_table` package currently adheres to a legacy Clean Architecture file organization (`lib/src/core/`, `lib/src/domain/entities/`, `lib/src/presentation/theme/`, `lib/src/presentation/widgets/`). In addition, multiple core components have secondary classes embedded in the same file:
- `custom_data_table.dart` embeds `TableController` and `SelectColumnsToShowDialog`.
- `column_info.dart` embeds `ColumnId`.
- `filter_item.dart` embeds `FilterSection`.
- `table_paginated_count_widget.dart` embeds `SelectPageWidget`.
- `custom_filters.dart` embeds `FiltersView`.
- `dates_filter_chip.dart` embeds `_DateFilterView`.
- `time_filter.dart` has naming inconsistency relative to its actual function (range picker).

This restructuring aligns the package with Google's official **Flutter Architecture Case Study** ([docs.flutter.dev/app-architecture/case-study](https://docs.flutter.dev/app-architecture/case-study), referencing the Compass App sample) and official **Dart Package Layout Conventions** ([dart.dev/tools/pub/package-layout](https://dart.dev/tools/pub/package-layout)).

---

## Target Package Directory Architecture

```
lib/
├── custom_data_table.dart             # Public API entry point (re-exports all symbols)
├── l10n/                              # Standard Flutter internationalization assets & generated classes
└── src/                               # Internal package implementation (encapsulated)
    ├── domain/
    │   └── models/                    # Pure Dart data models & enums (no UI dependencies)
    │       ├── column_id.dart
    │       ├── column_info.dart
    │       ├── date_filter_type.dart
    │       ├── date_selection.dart
    │       ├── filter_item.dart
    │       ├── filter_section.dart
    │       ├── paginator_info.dart
    │       ├── search_field_info.dart
    │       └── sort_info.dart
    ├── utils/                         # Cross-cutting extensions, debounce & helpers
    │       ├── date_time_extension.dart
    │       ├── debounce.dart
    │       ├── responsive_helpers.dart
    │       └── string_extension.dart
    └── ui/
        ├── core/                      # Shared reusable UI primitives & design tokens
        │   ├── themes/                # Theme definitions & data classes
        │   │   ├── datatable_theme.dart
        │   │   ├── datatable_theme_data.dart
        │   │   └── row_theme.dart
        │   └── ui/                    # Shared widgets (avoids conflicting '/widgets' name)
        │       ├── date_filter/       # Date range pickers & filter dialogs
        │       │   ├── custom_month_picker.dart
        │       │   ├── date_filter_dialog.dart
        │       │   ├── date_time_range_picker.dart
        │       │   └── dates_filter_chip.dart
        │       └── filters/           # General filter widgets & section views
        │           ├── custom_filters.dart
        │           ├── filter_section_widget.dart
        │           ├── filters_view.dart
        │           └── selected_filters_widget.dart
        └── custom_data_table/         # Feature-scoped module for DataTable
            ├── view_models/           # State holder (ChangeNotifier)
            │   └── table_controller.dart
            └── widgets/               # Feature widgets & dialogs
                ├── both_directions_listview_builder.dart
                ├── custom_data_table.dart
                ├── per_page_widget.dart
                ├── select_columns_dialog.dart
                ├── table_footer.dart
                └── pagination/
                    ├── select_page_dialog.dart
                    └── table_paginated_count_widget.dart

test/                                  # Exact mirror of lib/src/ for unit and widget tests
├── domain/
│   └── models/
│       ├── column_info_test.dart
│       ├── date_selection_test.dart
│       └── paginator_info_test.dart
├── utils/
│   └── responsive_helpers_test.dart
├── ui/
│   ├── core/
│   │   └── localization_test.dart
│   └── custom_data_table/
│       └── custom_data_table_test.dart
└── testing/                           # Test fakes, mocks, and fixtures (scoped to test/)
```

---

## Goals / Non-Goals

**Goals:**
- **Standardized Directory Structure**: Reorganize package files strictly adhering to Flutter Architecture guidelines (`domain/models`, `utils`, `ui/core`, `ui/custom_data_table`).
- **Class Decoupling**: Extract each embedded secondary class into a dedicated file with single responsibility.
- **100% Backward Compatibility**: Keep the public API surface exposed by `lib/custom_data_table.dart` identical.
- **Preserve Localization**: Retain `lib/l10n/` without path mutations to respect standard Flutter ARB generator behavior.
- **Test Alignment & Modularization**: Split monolithic test file into modular suites mirroring `lib/src/` under `test/`, and place shared test fakes and fixtures in `test/testing/`.
- **Zero Behavioral Regressions**: Ensure all automated tests pass with zero logic changes.

**Non-Goals:**
- Modifying UI layouts, styles, themes, or visual rendering.
- Modifying table pagination, filtering logic, or controller event handling.
- Deprecating or altering any public API contracts.

---

## Architectural Decisions & Documentation Alignment

### 1. Dedicated Files for Secondary Classes
- **Decision**: Extract `TableController`, `SelectColumnsToShowDialog`, `ColumnId`, `FilterSection`, `SelectPageWidget`, `FiltersView`, and `_DateFilterView` into their own dedicated files.
- **Rationale**: Single-responsibility files promote code navigation, testability, and clean dependency trees.
- **Alternatives Considered**: Using `part of` files. Rejected because modern Flutter architecture discourages `part` files across feature boundaries.

### 2. Adoption of `ui/core/` over Generic `/widgets`
- **Decision**: Place shared widgets and themes under `lib/src/ui/core/`.
- **Documentation Rationale**: Official Flutter Architecture documentation specifically notes:
  > *"For clarity, we do not recommend using names that can be confused with objects from the Flutter SDK. For example, you should put your shared widgets in a directory called `ui/core/`, rather than a directory called `/widgets`."*

### 3. `TableController` as Feature ViewModel (`view_models/`)
- **Decision**: Place `TableController` under `lib/src/ui/custom_data_table/view_models/table_controller.dart`.
- **Documentation Rationale**: Under Flutter's MVVM pattern (as illustrated in Compass App's `HomeViewModel`), UI state holders extending `ChangeNotifier` manage mutable presentation states and notify views. `TableController` directly fulfills this role for `CustomDataTable`.

### 4. Package Encapsulation (`lib/src/` vs `lib/`)
- **Decision**: All implementation files reside strictly under `lib/src/`, and `lib/custom_data_table.dart` re-exports the public interface.
- **Documentation Rationale**: Dart package layout rules dictate that code not intended for direct consumer imports must reside under `lib/src/` to preserve internal encapsulation and prevent breaking changes during refactors.

### 5. Test Suite Modularization & Scoped Fixtures (`test/testing/`)
- **Decision**: Decompose the 432-line monolithic `test/custom_data_table_test.dart` into focused test suites mirroring `lib/src/` (`test/domain/models/`, `test/utils/`, `test/ui/core/`, `test/ui/custom_data_table/`), and house shared test fakes and dummy models inside `test/testing/`.
- **Documentation Rationale**: Dart package conventions recommend keeping test utilities inside `test/` so that `flutter test` can resolve them naturally without polluting the package root or packaging them into pub.dev releases.

### 6. Localization Path Preservation (`lib/l10n/`)
- **Decision**: Maintain `lib/l10n/` without moving it to `lib/src/ui/core/localization/`.
- **Documentation Rationale**: Flutter's official internationalization tooling (`gen-l10n`) operates standardly at `lib/l10n/`. Preserving this location avoids breaking code generation configurations and ensures stability with the implementation established in CDT-14.

---

## Risks / Trade-offs

- **[Risk] Broken relative imports during file moves** → *Mitigation*: Run `flutter analyze --fatal-infos` across the entire workspace to identify and fix all import paths.
- **[Risk] Missing export in barrel file** → *Mitigation*: Cross-check all previously exported classes against `lib/custom_data_table.dart` exports, and ensure existing test suites pass without modified test imports.
- **[Risk] Git history loss on file renames** → *Mitigation*: Use `git mv` for file relocations where feasible.
