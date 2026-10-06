import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Unit Tests - ColumnInfo & DateSelection', () {
    test('ColumnInfo initializes correctly with defaults', () {
      final column = ColumnInfo(
        key: 'id',
        name: 'Identifier',
        width: 100,
      );

      expect(column.key, 'id');
      expect(column.name, 'Identifier');
      expect(column.width, 100);
      expect(column.canSort, isFalse);
      expect(column.canSearchInput, isFalse);
      expect(column.hasFixedWidth, isFalse);
    });

    test('DateSelection.fromDates handles null dates gracefully', () {
      final selection = DateSelection.fromDates(null, null);

      expect(selection.dateFilterType, DateFilterType.period);
      expect(selection.date, isNull);
      expect(selection.endDate, isNull);
    });

    test('DateSelection.fromDates classifies custom period correctly', () {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 1, 15);
      final selection = DateSelection.fromDates(start, end);

      expect(selection.dateFilterType, DateFilterType.period);
      expect(selection.date, start);
      expect(selection.endDate, end);
    });
  });

  group('Widget Tests - CustomDataTable', () {
    testWidgets('CustomDataTable renders columns and rows properly',
        (tester) async {
      final columns = [
        ColumnInfo(key: 'id', name: 'ID', width: 60),
        ColumnInfo(key: 'name', name: 'Name', width: 120),
      ];

      final sampleData = [
        {'id': '1', 'name': 'Alice'},
        {'id': '2', 'name': 'Bob'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: CustomDataTable<Map<String, String>>(
                columns: columns,
                data: sampleData,
                paginatorInfo: PaginatorInfo(
                  lastPage: 1,
                  currentPage: 1,
                  perPage: 10,
                  total: 2,
                ),
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Column titles are present
      expect(find.text('ID'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);

      // Verify Data cells are present
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });
  });
}
