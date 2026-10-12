import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests - TableColumnsHeader', () {
    final sampleColumns = [
      ColumnInfo(key: 'id', name: 'ID', width: 100),
      ColumnInfo(key: 'name', name: 'Name', width: 200),
      ColumnInfo(key: 'status', name: 'Status', width: 150),
    ];

    testWidgets('renders columns without horizontal scroll when width is wide',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 60,
              child: TableColumnsHeader(
                columns: sampleColumns,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ID'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      // SingleChildScrollView should not be present when maxWidth > minWidth
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets(
        'renders SingleChildScrollView when constrained width is smaller than columns total width',
        (tester) async {
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 250, // total column width is 100 + 200 + 150 = 450 > 250
              height: 60,
              child: TableColumnsHeader(
                columns: sampleColumns,
                scrollController: scrollController,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(scrollController.hasClients, isTrue);
      expect(scrollController.offset, 0.0);

      // Verify scroll interaction
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(-100, 0));
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(0.0));
    });

    testWidgets('forwards sort and search callbacks from column headers',
        (tester) async {
      SortInfo? sortInfo;
      final columns = [
        ColumnInfo(key: 'title', name: 'Title', width: 120, canSort: true),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 60,
              child: TableColumnsHeader(
                columns: columns,
                onSort: (info) => sortInfo = info,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(sortInfo, isNotNull);
      expect(sortInfo!.columnInfo.key, 'title');
    });
  });
}
