# CustomDataTable

[![pub package](https://img.shields.io/pub/v/custom_data_table.svg)](https://pub.dev/packages/custom_data_table)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A powerful, customizable, and responsive Flutter DataTable designed to handle large datasets effortlessly. Features synchronized bi-directional scrolling, column search inputs, multi-range date and month filtering, pagination, and complete theme customization.

---

## Features

- ↔️ **Bi-directional Synchronized Scrolling**: Smooth horizontal and vertical scrolling for wide tables with frozen or synchronized headers.
- 🔍 **Integrated Column Search**: Search inputs embedded directly in each column header with real-time filtering callbacks.
- 📅 **Advanced Date & Month Pickers**: Built-in dialogs for single date, date ranges, and month picker filtering.
- 📄 **Pagination & Footer Controls**: Customizable table footer displaying total count, current page, and page selector.
- 🎨 **Extensive Theming (`DatatableThemeData`)**: Full control over header background, row striping, borders, typography, and padding.
- 🌐 **Localization Ready**: Built-in support for English and Spanish formats and date localizations.

---

## Getting Started

Add `custom_data_table` to your `pubspec.yaml`:

```yaml
dependencies:
  custom_data_table: ^3.0.6
```

Then run:

```bash
flutter pub get
```

---

## Usage

Here is a minimal example showing how to set up `CustomDataTable`:

```dart
import 'package:flutter/material.dart';
import 'package:custom_data_table/custom_data_table.dart';

class SimpleTablePage extends StatelessWidget {
  const SimpleTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomDataTable Demo')),
      body: CustomDataTable<Map<String, String>>(
        columns: [
          ColumnInfo(
            key: 'id',
            name: 'ID',
            width: 80,
          ),
          ColumnInfo(
            key: 'name',
            name: 'Name',
            width: 180,
            canSearchInput: true,
          ),
          ColumnInfo(
            key: 'role',
            name: 'Role',
            width: 150,
          ),
        ],
        data: const [
          {'id': '1', 'name': 'Alice', 'role': 'Admin'},
          {'id': '2', 'name': 'Bob', 'role': 'Member'},
        ],
        paginatorInfo: PaginatorInfo(
          lastPage: 1,
          currentPage: 1,
          perPage: 10,
          total: 2,
        ),
        toMap: (element) => element,
        onTapRow: (element) {
          debugPrint('Tapped row: $element');
        },
      ),
    );
  }
}
```

---

## Theming

Wrap `CustomDataTable` or your app root with `DatatableTheme` to customize colors, fonts, and dimensions:

```dart
DatatableTheme(
  data: DatatableThemeData(
    headerColor: const Color(0xFF1E293B),
    headerTextColor: Colors.white,
    rowColor1: Colors.white,
    rowColor2: const Color(0xFFF8FAFC),
    columnHeaderHeight: 48,
  ),
  child: CustomDataTable(
    // ...
  ),
)
```

---

## Example App

For a full working demonstration with mock user data, filter dialogs, date range selections, and pagination, check out the [`example/`](https://github.com/elalfner/custom_data_table/tree/main/example) directory included in the repository.

To run the example locally:

```bash
cd example
flutter pub get
flutter run
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
