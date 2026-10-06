# Changelog

All notable changes to this project will be documented in this file.

## 3.0.6

* **Pub.dev Readiness**: Added official MIT License, comprehensive documentation, and pub.dev compliant metadata.
* **Continuous Integration**: Added GitHub Actions CI workflow with Flutter 3.38.7 and Pub caching.
* **Testing**: Added widget and unit test suite for `CustomDataTable` and date helper entities.
* **Maintenance**: Sanitized `.gitignore` and aligned repository URLs.

## 3.0.5

* **Feature**: Added `onTapRow` callback to `CustomDataTable`.
* **Fix**: Fixed row builder rendering and alignment.

## 3.0.4

* **Feature**: Initialize `CustomDataTable` search state when `generalSearchController` has initial text.
* **Maintenance**: Version bump and internal fixes.

## 3.0.3

* **Feature**: Added `DateSelection.fromDates` factory for intelligent date range selection.
* **Refactor**: Refined `DateTime` extension methods for accurate month and year end calculations.

## 3.0.2

* **Refactor**: Adjusted table footer's result count display to show total items.
* **Fix**: Fixed typo in `resultsNumberWidget`.

## 3.0.1

* **Refactor**: Internal improvements in theme handling and cell padding adjustments.

## 3.0.0

* **Breaking**: Migrated internal architecture to clean architecture structure.
* **Feature**: Column search inputs integrated directly into table headers.
* **Feature**: Bi-directional synchronized scrolling for extensive datasets.
* **Feature**: Advanced date and month filtering dialogs with `DateSelection`.
* **Feature**: Customizable theming via `DatatableTheme` and `DatatableThemeData`.
* **Feature**: Responsive table footer with pagination support.
