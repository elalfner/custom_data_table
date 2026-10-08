## ADDED Requirements

### Requirement: Localized Clipboard Copy Feedback
The `CustomDataTable` SHALL provide localized feedback via a SnackBar when copying table data to the clipboard.

#### Scenario: Copy confirmation in English locale
- **WHEN** the user presses the copy button and the active locale is English (`en`)
- **THEN** a SnackBar appears displaying the localized text "Copied to clipboard"

#### Scenario: Copy confirmation in Spanish locale
- **WHEN** the user presses the copy button and the active locale is Spanish (`es`)
- **THEN** a SnackBar appears displaying the localized text "Copiado al portapapeles"

### Requirement: Localized Copy Button Tooltip
The copy icon button in the header toolbar SHALL present an accessible localized tooltip corresponding to the copy action.

#### Scenario: Tooltip displayed in English
- **WHEN** the user hovers over or long-presses the copy button in an English locale
- **THEN** the tooltip displays "Copy"

#### Scenario: Tooltip displayed in Spanish
- **WHEN** the user hovers over or long-presses the copy button in a Spanish locale
- **THEN** the tooltip displays "Copiar"

### Requirement: Clean and Active ARB Translation Catalogs
The ARB catalogs (`app_en.arb` and `app_es.arb`) and generated localization classes SHALL contain only active, referenced keys and eliminate dead translation entries.

#### Scenario: Unused keys removed
- **WHEN** inspecting `app_en.arb` and `app_es.arb`
- **THEN** the 9 obsolete keys (`all`, `clearAll`, `filterSearch`, `moreOptions`, `resultsTitle`, `searchAdjective`, `selectedColumns`, `showHideColumns`, `showingAll`) are absent

#### Scenario: New copy key present
- **WHEN** inspecting `app_en.arb` and `app_es.arb`
- **THEN** the `copiedToClipboard` key is defined with appropriate translations in English and Spanish

### Requirement: Material Localization Configuration Guidance
The documentation SHALL guide consumers on configuring `MaterialApp` with `GlobalMaterialLocalizations.delegates` and `DataTableLocalizations.localizationsDelegates` so that native dialogs and custom table elements are properly localized.

#### Scenario: Developer consults i18n instructions in README
- **WHEN** a developer views the `README.md` internationalization section
- **THEN** a runnable Flutter code sample demonstrates setting `localizationsDelegates: DataTableLocalizations.localizationsDelegates` and `supportedLocales: DataTableLocalizations.supportedLocales` in `MaterialApp`

### Requirement: Resilient Clipboard Platform Error Handling
The `CustomDataTable` SHALL handle clipboard platform failures gracefully without throwing unhandled exceptions or presenting false confirmation feedback.

#### Scenario: Graceful handling of clipboard platform exception
- **GIVEN** a table with clipboard copy enabled
- **WHEN** the user invokes the copy action and the platform throws a `PlatformException` (e.g. browser focus or permission restriction)
- **THEN** the exception is captured defensively without breaking the widget tree
- **AND** the confirmation SnackBar is not displayed
