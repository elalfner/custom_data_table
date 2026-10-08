## Context

The `custom_data_table` package provides built-in internationalization (i18n) for English (`en`) and Spanish (`es`) using Flutter's ARB-based localization tooling. The localization artifacts reside directly under `lib/l10n/` and are exported through `lib/custom_data_table.dart`.

Currently, the feedback message displayed when copying table data to the clipboard (`SnackBar`) is hardcoded to `'Copied to clipboard'` inside `lib/src/presentation/widgets/custom_data_table.dart`, and the copy `IconButton` lacks an accessibility `tooltip`. Additionally, 9 legacy ARB keys remain unreferenced across the codebase, adding dead weight to the generated localization classes. Lastly, the `README.md` documentation does not explicitly demonstrate how consumer applications should register localization delegates to ensure native Material dialogs (such as date pickers) render in the chosen language.

## Goals / Non-Goals

**Goals:**
- Add `copiedToClipboard` translation keys to `lib/l10n/app_en.arb` ("Copied to clipboard") and `lib/l10n/app_es.arb` ("Copiado al portapapeles").
- Prune the 9 obsolete keys (`all`, `clearAll`, `filterSearch`, `moreOptions`, `resultsTitle`, `searchAdjective`, `selectedColumns`, `showHideColumns`, `showingAll`) from both ARB files.
- Regenerate localization classes (`lib/l10n/app_localizations*.dart`) with `output-class: DataTableLocalizations` and `--no-synthetic-package`.
- Replace the hardcoded `'Copied to clipboard'` string with `context.appLocalizations.copiedToClipboard` in `CustomDataTable`.
- Add `tooltip: context.appLocalizations.copy.naturalCapitalized` to the copy `IconButton`.
- Update `README.md` with an idiomatic `MaterialApp` configuration sample demonstrating `DataTableLocalizations.localizationsDelegates` and `GlobalMaterialLocalizations.delegates`.
- Validate zero static analysis warnings (`flutter analyze --fatal-infos`) and 100% test pass rate.

**Non-Goals:**
- Introducing new language translations (e.g., French, Portuguese) in this iteration.
- Altering the public API signature of `CustomDataTable` or its domain entities.
- Integrating external backend services or persistence layers (100% Flutter client-side).

## Decisions

### 1. Localization Code Generation Strategy
- **Decision**: Run `flutter gen-l10n` targeting `lib/l10n` with `--output-class DataTableLocalizations`, `--no-synthetic-package`, and standard template file `app_en.arb`.
- **Rationale**: Keeps generated files committed in `lib/l10n/`, matching the existing repository structure and allowing packages that depend on `custom_data_table` to access `DataTableLocalizations` directly without requiring synthetic package resolution.
- **Alternatives Considered**: Using Flutter's default synthetic package generation (`.dart_tool/flutter_gen`). Rejected because library packages distributed on pub.dev must export non-synthetic localization classes directly to consumers.

### 2. Localization Access via `BuildContextExtension`
- **Decision**: Consume `context.appLocalizations.copiedToClipboard` and `context.appLocalizations.copy.naturalCapitalized`.
- **Rationale**: `BuildContextExtension.appLocalizations` provides a safe fallback mechanism: if `DataTableLocalizations.of(context)` returns null, it attempts to resolve the language from the nearest `MaterialApp.locale` or falls back gracefully to `en`, preventing runtime null dereferences.
- **Alternatives Considered**: Using `DataTableLocalizations.of(context)!` directly. Rejected because it throws an unhandled exception if delegates are not registered in test or consumer contexts.

### 3. Documentation Configuration Guide
- **Decision**: Provide a dedicated code snippet in `README.md` showing both `DataTableLocalizations.localizationsDelegates` and `GlobalMaterialLocalizations.delegates`.
- **Rationale**: `DataTableLocalizations.localizationsDelegates` already includes `GlobalMaterialLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`, and `GlobalWidgetsLocalizations.delegate`. Explaining this simplifies developer integration and guarantees localized date pickers and dialogs.

### 4. Resilient Clipboard Error Handling (Review Iteration 1)
- **Decision**: Enclose `Clipboard.setData(...)` and `scaffoldMessenger.showSnackBar(...)` in a `try-catch` block, logging any exception via `debugPrint`.
- **Rationale**: On Flutter Web and secured sandboxed platforms, `Clipboard.setData()` throws a `PlatformException` if the browser tab lacks user-activation focus or if clipboard permissions are restricted. Without a defensive catch block, an unhandled exception is thrown, and the UI can become unresponsive. Furthermore, the confirmation SnackBar must only be displayed when copying successfully succeeds to prevent false-positive user feedback.
- **Alternatives Considered**: Suppressing errors silently without logs. Rejected because diagnostic logging via `debugPrint` is vital for developers debugging web sandbox or permission restrictions.

## Risks / Trade-offs

- **[Risk]**: Consumer applications relying on the 9 pruned keys on `DataTableLocalizations`.
  - **Mitigation**: Those keys were unreferenced remnants never consumed by `CustomDataTable` widgets. Removing them reduces catalog bloat and clarifies the actual library surface.
- **[Risk]**: Regressions in test suite when accessing localized strings in widget tests.
  - **Mitigation**: Ensure widget test harnesses provide localization delegates (`DataTableLocalizations.localizationsDelegates`) when verifying copy interactions.
- **[Risk]**: Clipboard failures on restricted browser environments.
  - **Mitigation**: Gracefully catch `PlatformException`, log diagnostics with `debugPrint`, and avoid showing false-positive confirmation SnackBars.
