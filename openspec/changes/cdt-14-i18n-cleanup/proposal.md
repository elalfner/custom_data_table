# Proposal: i18n Cleanup and Localization Completion

## Why

The `custom_data_table` package currently features incomplete internationalization (i18n) coverage. Specifically, the clipboard copy confirmation notification (`SnackBar`) has hardcoded English text without a tooltip, and 9 unused translation keys remain in `app_en.arb` and `app_es.arb`. Furthermore, the package documentation lacks guidance on integrating Flutter's `GlobalMaterialLocalizations.delegates`, which can lead to untranslated native Material dialogs (such as date pickers) in consumer applications.

Cleaning up dead localization keys, localizing the copy action feedback, and providing explicit configuration instructions ensures robust multilingual behavior, improves developer experience, and keeps package footprint minimal.

## What Changes

- **Localization Catalog Pruning**: Remove 9 obsolete, unreferenced translation keys (`all`, `clearAll`, `filterSearch`, `moreOptions`, `resultsTitle`, `searchAdjective`, `selectedColumns`, `showHideColumns`, `showingAll`) from `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`.
- **Copy Action Localization**:
  - Add `copiedToClipboard` key to both `app_en.arb` ("Copied to clipboard") and `app_es.arb` ("Copiado al portapapeles").
  - Update `CustomDataTable` copy action to display `context.appLocalizations.copiedToClipboard` in the `SnackBar`.
  - Add `tooltip: context.appLocalizations.copy.naturalCapitalized` to the copy `IconButton`.
- **Localization Code Regeneration**: Re-run Flutter's official localization generator tool to refresh `DataTableLocalizations` classes cleanly.
- **Documentation Enhancement**: Update `README.md` to include clear setup instructions for `MaterialApp` localizations using `GlobalMaterialLocalizations.delegates` and `DataTableLocalizations.localizationsDelegates`.
- **Automated Verification**: Ensure all widget and unit tests pass, static analysis has 0 warnings/errors, and test coverage covers the localized copy button and tooltip.

## Capabilities

### New Capabilities
- `table-localization`: Comprehensive localization support covering table toolbar actions (copy feedback, tooltips), ARB catalog hygiene, and host app delegate configuration.

### Modified Capabilities
<!-- None: existing capability specs do not cover table i18n -->

## Impact

- **Affected Code**:
  - `lib/l10n/app_en.arb`
  - `lib/l10n/app_es.arb`
  - `lib/l10n/app_localizations.dart`
  - `lib/l10n/app_localizations_en.dart`
  - `lib/l10n/app_localizations_es.dart`
  - `lib/src/presentation/widgets/custom_data_table.dart`
  - `README.md`
  - `test/presentation/widgets/custom_data_table_test.dart` (or new test)
- **Breaking Changes**: None. Internal unused keys in `DataTableLocalizations` are removed, but public API parameters remain unchanged.
