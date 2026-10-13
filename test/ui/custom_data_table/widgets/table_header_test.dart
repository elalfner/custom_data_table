import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/src/utils/debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests - TableHeader', () {
    final columns = [
      ColumnInfo(key: 'id', name: 'ID', width: 60),
      ColumnInfo(key: 'name', name: 'Name', width: 120),
    ];

    Widget buildTestWidget({
      required Widget child,
    }) {
      return MaterialApp(
        localizationsDelegates: DataTableLocalizations.localizationsDelegates,
        supportedLocales: DataTableLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );
    }

    testWidgets('renders columns selector button and opens dialog when tapped',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: TableHeader<Map<String, String>>(
            columns: columns,
            selectedColumns: columns,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final columnsButton = find.text('Columns');
      expect(columnsButton, findsOneWidget);

      await tester.tap(columnsButton);
      await tester.pumpAndSettle();

      expect(find.byType(SelectColumnsToShowDialog), findsOneWidget);
    });

    testWidgets(
        'toggles general search bar and debounces search input with TableDebouncer',
        (tester) async {
      String? searchQuery;
      final debouncer = TableDebouncer(milliseconds: 100);

      await tester.pumpWidget(
        buildTestWidget(
          child: TableHeader<Map<String, String>>(
            columns: columns,
            selectedColumns: columns,
            debouncer: debouncer,
            onChangeGeneralSearch: (value) {
              searchQuery = value;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap search icon to open search input
      final searchIcon = find.widgetWithIcon(IconButton, Icons.search);
      expect(searchIcon, findsOneWidget);
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Antigravity');
      expect(searchQuery, isNull);

      // Advance clock past debouncer
      await tester.pump(const Duration(milliseconds: 150));
      expect(searchQuery, 'Antigravity');

      // Tap clear icon
      final closeIcon = find.widgetWithIcon(IconButton, Icons.close);
      expect(closeIcon, findsOneWidget);
      await tester.tap(closeIcon);
      await tester.pumpAndSettle();

      expect(searchQuery, '');
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('debounces general search input with custom debounceDuration',
        (tester) async {
      String? searchQuery;

      await tester.pumpWidget(
        buildTestWidget(
          child: TableHeader<Map<String, String>>(
            columns: columns,
            selectedColumns: columns,
            debounceDuration: const Duration(milliseconds: 200),
            onChangeGeneralSearch: (value) {
              searchQuery = value;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final searchIcon = find.widgetWithIcon(IconButton, Icons.search);
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'CustomDuration');
      expect(searchQuery, isNull);

      // Advance clock partially (100ms) - should still be null
      await tester.pump(const Duration(milliseconds: 100));
      expect(searchQuery, isNull);

      // Advance clock past 200ms
      await tester.pump(const Duration(milliseconds: 150));
      expect(searchQuery, 'CustomDuration');
    });

    testWidgets('triggers onCopy, onPrint, and filter dialog callbacks',
        (tester) async {
      var copyCalled = false;
      var printCalled = false;

      final filterSections = [
        FilterSection<String>(
          columnInfo: ColumnId(key: 'status', name: 'Status'),
          filters: [
            FilterItem(filterName: 'Active', value: 'active'),
          ],
          selectedFilters: [
            FilterItem(filterName: 'Active', value: 'active'),
          ],
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          child: TableHeader<Map<String, String>>(
            columns: columns,
            selectedColumns: columns,
            data: const [
              {'id': '1', 'name': 'Item'}
            ],
            onCopy: () {
              copyCalled = true;
            },
            onPrint: () {
              printCalled = true;
            },
            filterSections: filterSections,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap copy button
      final copyButton = find.widgetWithIcon(IconButton, Icons.copy);
      expect(copyButton, findsOneWidget);
      await tester.tap(copyButton);
      await tester.pumpAndSettle();
      expect(copyCalled, isTrue);

      // Open export menu and tap print
      final exportButton = find.text('Export');
      expect(exportButton, findsOneWidget);
      await tester.tap(exportButton);
      await tester.pumpAndSettle();

      final printItem = find.text('Print');
      expect(printItem, findsOneWidget);
      await tester.tap(printItem);
      await tester.pumpAndSettle();
      expect(printCalled, isTrue);

      // Filter button
      final filterButton = find.text('Filter');
      expect(filterButton, findsOneWidget);
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      expect(find.byType(SelectFiltersDialog), findsOneWidget);
    });
  });

  group('TableDebouncer Unit Tests', () {
    test('debounces multiple calls to only execute the latest', () async {
      final debouncer = TableDebouncer(milliseconds: 50);
      var executionCount = 0;
      var lastValue = '';

      debouncer.run(() {
        executionCount++;
        lastValue = 'first';
      });
      debouncer.run(() {
        executionCount++;
        lastValue = 'second';
      });

      expect(executionCount, 0);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(executionCount, 1);
      expect(lastValue, 'second');
    });

    test('cancels active timer when cancel is called', () async {
      final debouncer = TableDebouncer(milliseconds: 50);
      var called = false;

      debouncer.run(() {
        called = true;
      });
      debouncer.cancel();

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(called, isFalse);
    });
  });
}
