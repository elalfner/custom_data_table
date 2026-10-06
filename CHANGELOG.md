# Changelog

All notable changes to the `custom_data_table` package will be documented in this file.
This project adheres to [Semantic Versioning](https://semver.org/).

## 3.0.6

Initial public release of `custom_data_table` on pub.dev.

### Key Capabilities
* **Interactive Rows**: Handle row taps via `onTapRow: (element) => ...` with built-in Material ink ripple effects, or customize row layouts using `rowBuilder`.
* **Integrated Column Search**: Search inputs embedded directly inside column headers for instant, per-column filtering.
* **Pre-Populated Search**: Support for pre-filled `generalSearchController` and `ColumnInfo.initialSearchValue` that filters data immediately upon initial render.
* **Smart Date Filtering**: Built-in `DateSelection` dialogs with intelligent range detection (single date, month, year, or custom period).
* **Synchronized Bi-Directional Scrolling**: Smooth horizontal and vertical scrolling with pinned headers for wide datasets.
* **Fully Customizable Theming**: Configure colors, alternating row striping, borders, paddings, and header styles via `DatatableThemeData`.
* **Responsive Pagination Footer**: Built-in footer supporting page navigation, customizable rows-per-page options, and formatted item count summaries.
