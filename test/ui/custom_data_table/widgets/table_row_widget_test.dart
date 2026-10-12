import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests - TableRowWidget', () {
    final columns = [
      ColumnInfo(key: 'id', name: 'ID', width: 60),
      ColumnInfo(key: 'name', name: 'Name', width: 120),
    ];

    testWidgets('applies zebra striping decoration for even and odd rows',
        (tester) async {
      const evenColor = Colors.green;
      const oddColor = Colors.yellow;

      final themeData = CustomDatatableThemeData(
        evenRowTheme: RowTheme(
          decoration: const BoxDecoration(color: evenColor),
        ),
        oddRowTheme: RowTheme(
          decoration: const BoxDecoration(color: oddColor),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDatatableTheme(
              data: themeData,
              child: Column(
                children: [
                  TableRowWidget<Map<String, String>>(
                    element: const {'id': '1', 'name': 'Even'},
                    index: 0,
                    columns: columns,
                    toMap: (element) => element,
                  ),
                  TableRowWidget<Map<String, String>>(
                    element: const {'id': '2', 'name': 'Odd'},
                    index: 1,
                    columns: columns,
                    toMap: (element) => element,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final evenContainer = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Even'),
              matching: find.byType(Container),
            )
            .first,
      );
      final oddContainer = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Odd'),
              matching: find.byType(Container),
            )
            .first,
      );

      expect((evenContainer.decoration as BoxDecoration?)?.color, evenColor);
      expect((oddContainer.decoration as BoxDecoration?)?.color, oddColor);
    });

    testWidgets('triggers onTapRow callback when tapped', (tester) async {
      Map<String, String>? tappedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableRowWidget<Map<String, String>>(
              element: const {'id': '42', 'name': 'Tapped'},
              index: 0,
              columns: columns,
              toMap: (element) => element,
              onTapRow: (element) {
                tappedItem = element;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Tapped'));
      await tester.pumpAndSettle();

      expect(tappedItem, isNotNull);
      expect(tappedItem!['id'], '42');
      expect(tappedItem!['name'], 'Tapped');
    });

    testWidgets('delegates cell rendering to custom cell builder',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableRowWidget<Map<String, String>>(
              element: const {'id': '10', 'name': 'Custom'},
              index: 0,
              columns: columns,
              toMap: (element) => element,
              cell: (element, map, key) {
                if (key == 'name') {
                  return const Chip(
                    key: Key('custom_name_chip'),
                    label: Text('Custom Chip'),
                  );
                }
                return null;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_name_chip')), findsOneWidget);
      expect(find.text('Custom Chip'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('wraps row child when rowBuilder is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableRowWidget<Map<String, String>>(
              element: const {'id': '1', 'name': 'Wrapped'},
              index: 0,
              columns: columns,
              toMap: (element) => element,
              rowBuilder: (element, widget) => Tooltip(
                key: const Key('row_tooltip'),
                message: 'Row tooltip',
                child: widget,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('row_tooltip')), findsOneWidget);
      expect(find.text('Wrapped'), findsOneWidget);
    });
  });
}
