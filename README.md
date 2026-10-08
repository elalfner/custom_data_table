# CustomDataTable

<p align="center">
  <strong>The ultimate high-performance, enterprise-ready, and deeply customizable DataTable for Flutter.</strong>
</p>

<p align="center">
  <a href="https://pub.dev/packages/custom_data_table"><img src="https://img.shields.io/pub/v/custom_data_table.svg" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/custom_data_table/score"><img src="https://img.shields.io/pub/points/custom_data_table.svg" alt="Pub Points"></a>
  <a href="https://pub.dev/packages/custom_data_table"><img src="https://img.shields.io/pub/likes/custom_data_table.svg" alt="Pub Likes"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
  <img src="https://img.shields.io/badge/platform-flutter%20%7C%20android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-blue.svg" alt="Platforms">
</p>

---

## 🚀 Why CustomDataTable?

Building complex data grids, admin dashboards, and enterprise reporting screens in Flutter can be difficult. Flutter's default `DataTable` and `PaginatedDataTable` often fall short when you need per-column search, pinned headers, smart responsive column weighting, or deep brand theming.

**CustomDataTable** is designed from the ground up to give developers full control over their data presentation with zero compromises:

| Feature | Standard Flutter `DataTable` | **CustomDataTable** |
| :--- | :---: | :---: |
| **Integrated Column Search** | ❌ Build it yourself | ✅ **Live search inputs inside headers** |
| **Synchronized Scrolling** | ❌ Complex / Desynchronized | ✅ **Bi-directional with locked headers** |
| **Responsive Column Weights (`flex`)** | ❌ Rigid pixel widths | ✅ **Proportional `flex` + min-width safeguard** |
| **Fixed Width Columns (`hasFixedWidth`)** | ❌ Limited | ✅ **Lock IDs, checkboxes, or actions in place** |
| **Domain Model Mapping** | ⚠️ Manual cell mapping | ✅ **Generic `CustomDataTable<T>` native support** |
| **100% Custom Cells & Rows** | ⚠️ Rigid data cells | ✅ **Inject any widget (`cell` & `rowBuilder`)** |
| **Excel / Sheets Export** | ❌ Not included | ✅ **One-click tab-separated clipboard copy** |
| **Column Visibility Selector** | ❌ Custom implementation needed | ✅ **Built-in Show/Hide columns modal dialog** |
| **Built-in Search Debounce** | ❌ Manual streams/timers | ✅ **Automatic 500ms debounce protects APIs** |
| **Date & Calendar Filters** | ❌ None | ✅ **Dialogs for Day, Week, Month, Year & Time** |
| **App-Wide Theming** | ⚠️ Basic styling only | ✅ **`CustomDatatableTheme` via Provider** |
| **Internationalization (i18n)** | ❌ Manual boilerplate | ✅ **English & Spanish built-in** |

---

## 📸 Style Showcase & Brand Integration

`CustomDataTable` was architected so it **never looks like an out-of-place third-party widget**. It seamlessly adapts to your application's design system—whether Material 3, Cupertino, clean SaaS minimalism, or high-contrast corporate dark mode:

> *Showcase gallery coming soon: Light Clean, Enterprise Dark, Modern Vibrant, and Compact Dashboard styles!*

---

## 📦 Installation

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

## 💡 Quick Start: Type-Safe Domain Objects

You don't need to manually transform your data into low-level rows and cells. Pass your typed model list (`List<T>`) directly to `CustomDataTable<T>`:

```dart
import 'package:flutter/material.dart';
import 'package:custom_data_table/custom_data_table.dart';

// 1. Define your domain entity
class User {
  final int id;
  final String name;
  final String role;
  final String status;

  const User({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
  });
}

// 2. Render with CustomDataTable<User>
class UsersTablePage extends StatelessWidget {
  const UsersTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      const User(id: 1, name: 'Alice Smith', role: 'Lead Architect', status: 'Active'),
      const User(id: 2, name: 'Bob Jones', role: 'Product Designer', status: 'Pending'),
      const User(id: 3, name: 'Charlie Brown', role: 'DevOps Engineer', status: 'Active'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Team Directory')),
      body: CustomDataTable<User>(
        // Define columns with responsive widths, flex weights, and search capabilities
        columns: [
          ColumnInfo(
            key: 'id',
            name: 'ID',
            width: 70,
            hasFixedWidth: true, // Fixed width: stays exactly 70px
          ),
          ColumnInfo(
            key: 'name',
            name: 'Full Name',
            width: 180,
            flex: 3,              // Flex weight: takes 3x more space proportionally
            canSearchInput: true,  // Adds real-time search input inside header
          ),
          ColumnInfo(
            key: 'role',
            name: 'Role',
            width: 150,
            flex: 2,
          ),
          ColumnInfo(
            key: 'status',
            name: 'Status',
            width: 120,
            flex: 1,
          ),
        ],
        data: users,
        // Map your typed entity properties to column keys
        toMap: (user) => {
          'id': user.id,
          'name': user.name,
          'role': user.role,
          'status': user.status,
        },
        // Interactive row tap callback with Material ripple effect
        onTapRow: (user) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected user: ${user.name}')),
          );
        },
        // Pagination configuration
        paginatorInfo: PaginatorInfo(
          currentPage: 1,
          lastPage: 1,
          perPage: 10,
          total: users.length,
        ),
      ),
    );
  }
}
```

---

## 📐 Smart Responsive Column Layout

`CustomDataTable` features an intelligent two-tier responsive sizing algorithm:

1. **Proportional Distribution on Wide Screens**:
   On Desktop, Web, or Tablet screens, columns expand smoothly to fill the container according to their `flex` weight (or `width`).
2. **Fixed Columns (`hasFixedWidth: true`)**:
   Mark columns as fixed when you want precise pixel dimensions that never stretch (e.g., Checkboxes, IDs, Status badges, Action buttons).
3. **Graceful Horizontal Scroll on Mobile**:
   When the screen width becomes narrower than the combined minimum widths of all columns, `CustomDataTable` automatically switches to synchronized horizontal scrolling without truncating content or overflowing the screen.

```dart
// Fixed width column (e.g., actions toolbar)
ColumnInfo(
  key: 'actions',
  name: 'Actions',
  width: 90,
  hasFixedWidth: true, // Remains exactly 90px wide
)

// Flexible column (e.g., description or remarks)
ColumnInfo(
  key: 'description',
  name: 'Description',
  width: 200,
  flex: 4, // Dynamically expands to absorb available space
)
```

---

## 🧩 100% Customizable Cells & Rows: Any Widget You Want

Unlike standard tables where cells are restricted to plain text, `CustomDataTable` lets you inject **any Flutter widget** into any cell or wrap entire rows with zero boilerplate.

### 1. Custom Cell Rendering (`cell`)
Return custom widgets for specific columns, or return `null` to use default styled text:

```dart
CustomDataTable<User>(
  // ...
  cell: (user, map, key) {
    switch (key) {
      // 🟢 Status Badge with dynamic colors
      case 'status':
        final isActive = user.status == 'Active';
        return Chip(
          avatar: Icon(isActive ? Icons.check_circle : Icons.schedule, size: 16),
          label: Text(user.status),
          backgroundColor: isActive ? Colors.green.shade50 : Colors.amber.shade50,
          labelStyle: TextStyle(
            color: isActive ? Colors.green.shade900 : Colors.amber.shade900,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        );

      // 👤 Avatar + User Details in a single cell
      case 'name':
        return Row(
          children: [
            CircleAvatar(
              radius: 14,
              child: Text(user.name[0]),
            ),
            const SizedBox(width: 8),
            Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        );

      // 🔘 Action Buttons
      case 'actions':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => editUser(user),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: () => deleteUser(user),
            ),
          ],
        );

      // Default: return null to let CustomDataTable render the styled text
      default:
        return null;
    }
  },
)
```

### 2. Wrap Entire Rows (`rowBuilder`)
Want swipe-to-delete, right-click desktop menus, or hover tooltips? Wrap the row widget using `rowBuilder`:

```dart
CustomDataTable<User>(
  // ...
  rowBuilder: (user, child) {
    return Dismissible(
      key: ValueKey(user.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => deleteUser(user),
      child: Tooltip(
        message: 'Click row to view profile for ${user.name}',
        child: child, // The pre-styled, interactive row
      ),
    );
  },
)
```

---

## ⚡ Enterprise Features Out-of-the-Box

`CustomDataTable` includes enterprise utilities that would otherwise take weeks to build:

* 📋 **One-Click Copy to Excel & Google Sheets**:
  Clicking the copy button (`canCopy: true`) formats headers and filtered rows separated by tabs (`\t`) and newlines (`\n`). Paste directly into Excel, Google Sheets, or Apple Numbers with perfect column alignment!
* 👁️ **Dynamic Column Visibility (Show / Hide Columns)**:
  Built-in modal dialog allows users to toggle which columns they want visible on the fly.
* ⏱️ **Automatic 500ms Search Debounce**:
  Built-in debouncers buffer keystrokes in search inputs, preventing query storms against your backend APIs and databases.
* 🎛️ **Programmatic Table Control (`TableController`)**:
  Reset and clear all column search filters programmatically from external buttons:
  ```dart
  final tableController = TableController();
  // Clear all filters:
  tableController.clearColumnSearchFields();
  ```
* 📅 **Multi-Mode Date & Calendar Pickers (`DateSelection`)**:
  Built-in modal pickers for **Today**, **This Week**, **By Date**, **By Month** (dedicated month picker), **By Year**, and **Period of Time** with start and end times.
* 🏷️ **Faceted Filter Sections (`filterSections`)**:
  Group filters into categories (e.g. Department, Status, Priority). Active filters are displayed as dismissible chips with a "Clear all" action.
* 🌐 **Web-Optimized (`PointerInterceptor`)**:
  Dialogs and popups include pointer interception to avoid Web iframe/HTML element click-through bugs.

---

## 🚀 GraphQL Integration (Pagination, Filters & Sorting)

`CustomDataTable` was architected to pair naturally with standard GraphQL backends (such as **Laravel Lighthouse**, Hasura, or custom GraphQL schemas). Its core entities (`PaginatorInfo`, `SearchFieldInfo`, and `SortInfo`) match GraphQL pagination contracts, dynamic `where` filtering, and `orderBy` sorting conventions.

When combined with [`graphql_flutter`](https://pub.dev/packages/graphql_flutter) and [`graphql_codegen`](https://pub.dev/packages/graphql_codegen), you get a fully type-safe, reactive table workflow with automated query updates, keystroke debouncing, and server-side state coordination.

```
┌─────────────────────────────────────────┐               GraphQL Query (Variables)              ┌─────────────────────────────────────────┐
│             CustomDataTable             │ ────────────────────────────────────────────────────▶ │             GraphQL Server              │
│                                         │                                                       │          (Laravel Lighthouse)           │
│ • Real-time column search inputs        │                                                       │                                         │
│ • Server-side column sorting (ASC/DESC) │ ◀──────────────────────────────────────────────────── │ • Paginated record items                │
│ • Page navigation & per-page selection  │             PaginatorInfo & Items Data                │ • PaginatorInfo pagination metadata     │
└─────────────────────────────────────────┘                                                       └─────────────────────────────────────────┘
```

### 1. GraphQL Pagination Fragment (`base.graphql`)

Define a reusable fragment matching standard GraphQL `PaginatorInfo` output. Any paginated query can spread this fragment:

```graphql
# lib/graphql/base.graphql
fragment Paginator on PaginatorInfo {
  perPage
  total
  lastPage
  hasMorePages
  currentPage
}
```

Include it in your entity query file:

```graphql
# lib/graphql/users/users.graphql
# import '../base.graphql'

query users(
  $first: Int!
  $page: Int
  $search: String
  $where: QueryUsersWhereWhereConditions
  $orderBy: [QueryUsersOrderByOrderByClause!]
) {
  users(first: $first, page: $page, search: $search, where: $where, orderBy: $orderBy) {
    data {
      id
      name
      email
      role
      status
    }
    paginatorInfo {
      ...Paginator
    }
  }
}
```

### 2. Model Adapter Extension (`Fragment$Paginator`)

Because `custom_data_table`'s `PaginatorInfo` entity matches the exact field names generated by `graphql_codegen` (`perPage`, `total`, `lastPage`, `hasMorePages`, `currentPage`), you can convert the generated codegen type into `PaginatorInfo` in a single line:

```dart
// lib/graphql/base_extension.dart
import 'package:custom_data_table/custom_data_table.dart';
import 'base.graphql.dart';

extension Fragment$PaginatorExtension on Fragment$Paginator {
  /// Maps the codegen GraphQL fragment directly to CustomDataTable's PaginatorInfo
  PaginatorInfo get paginatorInfo => PaginatorInfo.fromJson(toJson());
}
```

### 3. Reusable Pagination Mixin (`DatatableGraphQL`)

A lightweight mixin reduces boilerplate across screens by encapsulating state transitions for pagination, search, and sorting:

```dart
// lib/core/mixins/datatable_graphql_mixin.dart
import 'package:custom_data_table/custom_data_table.dart';

mixin DatatableGraphQL<Variables> {
  PaginatorInfo? paginator;
  late Variables variables;

  /// Triggered when the user selects a specific page number
  void onSelectPage(int page);

  /// Helper to advance to the next page safely
  void onNextPage(PaginatorInfo paginator) {
    onSelectPage((paginator.currentPage ?? 0) + 1);
  }

  /// Helper to return to the previous page safely
  void onPreviousPage(PaginatorInfo paginator) {
    onSelectPage((paginator.currentPage ?? 2) - 1);
  }

  /// Optional hooks to be overridden in your screen state
  void onPerPageChange(int perPage) {}
  void onSearch(String value) {}
  void onIndividualSearch(List<SearchFieldInfo> searchFieldInfo) {}
  void onSort(SortInfo sortInfo) {}
}
```

### 4. Per-Column Search & Filtering (`SearchFieldInfo`)

Enable live search fields inside table headers by setting `canSearchInput: true` on `ColumnInfo`. Keystrokes are buffered by `CustomDataTable`'s **built-in 500ms debounce**, protecting your GraphQL server from query storms.

1. **Configure Column**:
   ```dart
   ColumnInfo(
     key: 'name',
     name: 'Full Name',
     flex: 2,
     canSearchInput: true, // Activates real-time search input inside header
   )
   ```

2. **Connect Callback**:
   ```dart
   CustomDataTable(
     // ...
     onChangeSearchTextField: (values) => onIndividualSearch(values),
   )
   ```

3. **Map to GraphQL `where` Clause**:
   ```dart
   import 'package:collection/collection.dart';

   @override
   void onIndividualSearch(List<SearchFieldInfo> searchFieldInfo) {
     final nameValue = searchFieldInfo
         .firstWhereOrNull((e) => e.columnInfo.key == 'name')
         ?.searchValue;

     variables = variables.copyWith(
       page: 1, // Reset to first page upon new filter
       where: Input$QueryUsersWhereWhereConditions(
         column: Enum$QueryUsersWhereColumn.NAME,
         operator: Enum$SQLOperator.LIKE,
         value: nameValue != null && nameValue.isNotEmpty ? "%$nameValue%" : null,
       ),
     );
     setState(() {});
   }
   ```

### 5. Server-Side Sorting (`SortInfo`)

Enable header sort indicators with `canSort: true`. When a header is tapped, `CustomDataTable` triggers `onSort` with a `SortInfo` object containing the column key and sort direction (`asc: true | false`).

1. **Configure Column**:
   ```dart
   ColumnInfo(
     key: 'created_at',
     name: 'Created Date',
     canSort: true, // Displays interactive sort indicator
   )
   ```

2. **Connect Callback**:
   ```dart
   CustomDataTable(
     // ...
     onSort: (sortInfo) => onSort(sortInfo),
   )
   ```

3. **Map to GraphQL `orderBy` Clause**:
   ```dart
   @override
   void onSort(SortInfo sortInfo) {
     variables = variables.copyWith(
       page: 1, // Reset to first page on new sort
       orderBy: [
         Input$QueryUsersOrderByClause(
           column: Enum$QueryUsersOrderByColumn.fromJson(
             sortInfo.columnInfo.key.toUpperCase(),
           ),
           order: sortInfo.asc ? Enum$SortOrder.ASC : Enum$SortOrder.DESC,
         ),
       ],
     );
     setState(() {});
   }
   ```

### 6. Full Working Screen Example (`Query$Widget`)

Here is a production-grade, copy-paste ready Flutter screen integrating `graphql_flutter`, `graphql_codegen`, and `CustomDataTable`:

```dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:custom_data_table/custom_data_table.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// Codegen and extension imports:
// import 'package:my_app/graphql/base_extension.dart';
// import 'package:my_app/graphql/users/users.graphql.dart';
// import 'package:my_app/core/mixins/datatable_graphql_mixin.dart';

class UsersTableScreen extends StatefulWidget {
  const UsersTableScreen({super.key});

  @override
  State<UsersTableScreen> createState() => _UsersTableScreenState();
}

class _UsersTableScreenState extends State<UsersTableScreen>
    with DatatableGraphQL<Variables$Query$users> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Variables$Query$users variables = Variables$Query$users(first: 20, page: 1);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Query$users$Widget(
        options: Options$Query$users(variables: variables),
        builder: (result, {fetchMore, refetch}) {
          final data = result.parsedData;
          final users = data?.users.data;

          // Maintain pagination metadata across network refetches
          final newPaginator = data?.users.paginatorInfo;
          if (newPaginator != null) {
            paginator = newPaginator.paginatorInfo;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (result.hasException && users == null)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: refetch,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry connection'),
                    ),
                  )
                else
                  Expanded(
                    child: CustomDataTable(
                      isLoading: result.isLoading && users == null,
                      data: users ?? [],
                      columns: [
                        ColumnInfo(
                          key: 'id',
                          name: 'ID',
                          width: 80,
                          hasFixedWidth: true,
                        ),
                        ColumnInfo(
                          key: 'name',
                          name: 'Name',
                          flex: 2,
                          canSearchInput: true, // Live column search
                          canSort: true,         // Sort by name
                        ),
                        ColumnInfo(
                          key: 'email',
                          name: 'Email',
                          flex: 3,
                          canSearchInput: true,
                        ),
                        ColumnInfo(
                          key: 'role',
                          name: 'Role',
                          width: 140,
                          canSort: true,
                        ),
                        ColumnInfo(
                          key: 'created_at',
                          name: 'Created',
                          width: 160,
                          canSort: true,
                        ),
                      ],
                      toMap: (user) => {
                        'id': user.id,
                        'name': user.name,
                        'email': user.email,
                        'role': user.role,
                        'created_at': user.createdAt,
                      },
                      // Global search input controller
                      generalSearchController: _searchController,
                      onChangeGeneralSearch: (value) => onSearch(value),

                      // Column search callback (protected by built-in 500ms debounce)
                      onChangeSearchTextField: (values) => onIndividualSearch(values),

                      // Server-side sort callback
                      onSort: (sortInfo) => onSort(sortInfo),

                      // Server-side pagination wiring
                      paginatorInfo: paginator,
                      onSelectedPage: paginator == null ? null : (page) => onSelectPage(page),
                      onNextPage: paginator == null ? null : () => onNextPage(paginator!),
                      onPreviousPage: paginator == null ? null : () => onPreviousPage(paginator!),
                      onPerPageChange: (perPage) => onPerPageChange(perPage),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // Pagination, Filter & Sort Handlers
  // ==========================================

  @override
  void onSelectPage(int page) {
    variables = variables.copyWith(page: page);
    setState(() {}); // Updates variables and triggers automatic refetch
  }

  @override
  void onPerPageChange(int perPage) {
    variables = variables.copyWith(first: perPage, page: 1);
    setState(() {});
  }

  @override
  void onSearch(String value) {
    variables = variables.copyWith(
      page: 1,
      search: value.isNotEmpty ? value : null,
    );
    setState(() {});
  }

  @override
  void onIndividualSearch(List<SearchFieldInfo> searchFieldInfo) {
    final nameSearch = searchFieldInfo
        .firstWhereOrNull((f) => f.columnInfo.key == 'name')
        ?.searchValue;

    variables = variables.copyWith(
      page: 1,
      where: nameSearch != null && nameSearch.isNotEmpty
          ? Input$QueryUsersWhereWhereConditions(
              column: Enum$QueryUsersWhereColumn.NAME,
              operator: Enum$SQLOperator.LIKE,
              value: '%$nameSearch%',
            )
          : null,
    );
    setState(() {});
  }

  @override
  void onSort(SortInfo sortInfo) {
    variables = variables.copyWith(
      page: 1,
      orderBy: [
        Input$QueryUsersOrderByClause(
          column: Enum$QueryUsersOrderByColumn.fromJson(
            sortInfo.columnInfo.key.toUpperCase(),
          ),
          order: sortInfo.asc ? Enum$SortOrder.ASC : Enum$SortOrder.DESC,
        ),
      ],
    );
    setState(() {});
  }
}
```

### 7. Unpaginated / Single-Page Tables

If your data is not paginated or you want to display all results on a single page, you can omit the paginator entirely or use the `singlePage` factory constructor to show the total count without navigation controls:

```dart
// Option A: No pagination footer at all
CustomDataTable(
  columns: [...],
  data: myData,
  paginatorInfo: null, // Hides the TableFooter completely
  toMap: (e) => e.toMap(),
)

// Option B: Show footer with item count, but no page navigation
CustomDataTable(
  columns: [...],
  data: myData,
  paginatorInfo: PaginatorInfo.singlePage(total: myData.length),
  toMap: (e) => e.toMap(),
)
```

---

## 🎨 Global & Local Theming

### Option 1: Global App-Wide Theme (Recommended)
Define your table styling once at the root of your application. All `CustomDataTable` instances throughout your app will automatically inherit your branding:

```dart
MaterialApp(
  builder: (context, child) {
    return CustomDatatableTheme(
      data: CustomDatatableThemeData(
        columnHeaderHeight: 48,
        tableDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        headerDecoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Slate 800
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        columnTitleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        evenRowTheme: RowTheme(
          decoration: const BoxDecoration(color: Colors.white),
        ),
        oddRowTheme: RowTheme(
          decoration: BoxDecoration(color: Colors.grey.shade50), // Alternating zebra striping
        ),
        rowPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: child!,
    );
  },
  home: const UsersTablePage(),
);
```

### Option 2: Local Table Override
Override styling for an individual table by wrapping it in a local `CustomDatatableTheme`:

```dart
CustomDatatableTheme(
  data: Theme.of(context).readDataTableTheme?.copyWith(
    columnHeaderHeight: 56,
  ) ?? CustomDatatableThemeData(),
  child: CustomDataTable(...),
)
```

---

## 💡 Layout Guidelines & Best Practices

To ensure smooth rendering and avoid common Flutter layout constraints pitfalls, keep these guidelines in mind:

### 1. Bounded Height Constraints (`RenderFlex` & Dashboards)
Like standard Flutter scrollable views and data grids, `CustomDataTable` uses vertical scroll virtualization internally. It requires bounded vertical constraints:

* **Inside a `Column` (Admin Dashboards / Full Screens):** Wrap `CustomDataTable` in an `Expanded` or `Flexible`:
  ```dart
  Column(
    children: [
      const DashboardHeader(),
      Expanded(
        child: CustomDataTable<User>(...),
      ),
    ],
  )
  ```

* **Inside a vertically scrolling page (`SingleChildScrollView` / `ListView`):** Give the table a defined boundary:
  ```dart
  SingleChildScrollView(
    child: Column(
      children: [
        const SummaryCards(),
        SizedBox(
          height: 600, // Explicit height boundary
          child: CustomDataTable<User>(...),
        ),
      ],
    ),
  )
  ```

### 2. Multi-line Cells & Custom Row Heights
By default, standard row height is calibrated for single-line text (`38px`). If your cells contain multi-line text, avatar groups, or tall badge chips, set `dataRowHeight` in your theme to match your design:

```dart
CustomDatatableTheme(
  data: CustomDatatableThemeData(
    dataRowHeight: 64, // Accommodates multi-line content or avatars
  ),
  child: CustomDataTable<User>(...),
)
```

### 3. Locking vs. Flexing Columns
* **Fixed Width (`hasFixedWidth: true`):** Use for ID columns, checkbox selectors, status indicators, and action button toolbars that should remain exactly at their assigned pixel width.
* **Proportional Weight (`flex: N`):** Use for text-heavy columns (Names, Descriptions, Emails) so they expand proportionally to fill available space on wide screens.

---

## 🌍 Internationalization (i18n)

`CustomDataTable` includes native localization out of the box:
* 🇺🇸 **English (`en`)**
* 🇪🇸 **Spanish (`es`)**

All pagination summaries (*"showing 1 to 10 of 100 results"*), search inputs, date dialogs (*"today"*, *"this week"*, *"select date"*), and column options automatically adapt to the active app `Locale`.

To enable these translations in your app, add the `DataTableLocalizations.localizationsDelegates` to your `MaterialApp`'s `localizationsDelegates` list, along with the standard `GlobalMaterialLocalizations.delegates`:

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:custom_data_table/custom_data_table.dart';

MaterialApp(
  localizationsDelegates: const [
    ...GlobalMaterialLocalizations.delegates,
    ...DataTableLocalizations.localizationsDelegates,
  ],
  supportedLocales: const [
    Locale('en'), // English
    Locale('es'), // Spanish
  ],
  home: const MyHomePage(),
);
```

> *Want to add French, German, or Portuguese? Translations are easy to add in `lib/l10n/`. Community contributions are welcome!*

---

## 🤝 Contributing, Bugs & Feature Requests

We welcome feedback, suggestions, and contributions!

* **Found a bug?** Open an issue using our [Bug Report Template](https://github.com/elalfner/custom_data_table/issues/new?template=bug_report.md).
* **Need a feature?** Propose ideas via our [Feature Request Template](https://github.com/elalfner/custom_data_table/issues/new?template=feature_request.md).
* **Want to contribute code?** Check out our [Contributing Guide (CONTRIBUTING.md)](CONTRIBUTING.md) to learn about our Git Flow and verification standards.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
