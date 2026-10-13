import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/src/utils/debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests - TableColumnHeader', () {
    testWidgets('renders column title and sort icons correctly',
        (tester) async {
      final column = ColumnInfo(
        key: 'name',
        name: 'Full Name',
        width: 150,
        canSort: true,
      );

      SortInfo? emittedSortInfo;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableColumnHeader(
              column: column,
              sortInfo: null,
              onSort: (info) {
                emittedSortInfo = info;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.byIcon(Icons.unfold_more), findsOneWidget);

      // Tap sort button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(emittedSortInfo, isNotNull);
      expect(emittedSortInfo!.columnInfo.key, 'name');
      expect(emittedSortInfo!.asc, isTrue);
    });

    testWidgets('toggles sort direction from ascending to descending',
        (tester) async {
      final column = ColumnInfo(
        key: 'age',
        name: 'Age',
        width: 80,
        canSort: true,
      );

      SortInfo? emittedSortInfo;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableColumnHeader(
              column: column,
              sortInfo: SortInfo(columnInfo: column, asc: true),
              onSort: (info) {
                emittedSortInfo = info;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(emittedSortInfo, isNotNull);
      expect(emittedSortInfo!.columnInfo.key, 'age');
      expect(emittedSortInfo!.asc, isFalse);
    });

    testWidgets(
        'debounces input when canSearchInput is true with TableDebouncer',
        (tester) async {
      String? changedSearch;
      String? columnInputSearch;

      final column = ColumnInfo(
        key: 'email',
        name: 'Email Address',
        width: 200,
        canSearchInput: true,
        onChangeInput: (val) {
          columnInputSearch = val;
        },
      );

      final debouncer = TableDebouncer(milliseconds: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableColumnHeader(
              column: column,
              debouncer: debouncer,
              onSearchChanged: (val) {
                changedSearch = val;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      // Before debouncer completes
      expect(changedSearch, isNull);

      // Advance clock past debouncer
      await tester.pump(const Duration(milliseconds: 150));

      expect(changedSearch, 'test@example.com');
      expect(columnInputSearch, 'test@example.com');
    });

    testWidgets('debounces input with custom debounceDuration', (tester) async {
      String? changedSearch;

      final column = ColumnInfo(
        key: 'phone',
        name: 'Phone',
        width: 150,
        canSearchInput: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableColumnHeader(
              column: column,
              debounceDuration: const Duration(milliseconds: 200),
              onSearchChanged: (val) {
                changedSearch = val;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '123456');
      expect(changedSearch, isNull);

      // Advance clock partially (100ms)
      await tester.pump(const Duration(milliseconds: 100));
      expect(changedSearch, isNull);

      // Advance clock past 200ms
      await tester.pump(const Duration(milliseconds: 150));
      expect(changedSearch, '123456');
    });
  });
}
