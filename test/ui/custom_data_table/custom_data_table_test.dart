import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/test_fixtures.dart';

void main() {
  group('Widget Tests - CustomDataTable', () {
    testWidgets('CustomDataTable renders columns and rows properly',
        (tester) async {
      final columns = createSampleColumns();
      final sampleData = createSampleData();

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

      // Verify TableFooter is rendered when paginatorInfo is present
      expect(find.byType(TableFooter), findsOneWidget);
    });

    testWidgets(
        'CustomDataTable renders columns and rows without TableFooter when paginatorInfo is null',
        (tester) async {
      final columns = [
        ColumnInfo(key: 'id', name: 'ID', width: 60),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomDataTable<Map<String, String>>(
              columns: columns,
              data: const [
                {'id': '1'}
              ],
              paginatorInfo: null,
              toMap: (element) => element,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ID'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.byType(TableFooter), findsNothing);
    });

    testWidgets(
        'CustomDataTable renders loadingBuilder when data is null and isLoading is true',
        (tester) async {
      final columns = [
        ColumnInfo(key: 'id', name: 'ID', width: 60),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomDataTable<Map<String, String>>(
              columns: columns,
              data: null,
              isLoading: true,
              loadingBuilder: () => const Text('Custom Loading...'),
              toMap: (element) => element,
            ),
          ),
        ),
      );

      expect(find.text('Custom Loading...'), findsOneWidget);
    });

    testWidgets(
        'CustomDataTable renders exceptionBuilder when data is null and isLoading is false',
        (tester) async {
      final columns = [
        ColumnInfo(key: 'id', name: 'ID', width: 60),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomDataTable<Map<String, String>>(
              columns: columns,
              data: null,
              isLoading: false,
              exceptionBuilder: () => const Text('Custom Exception...'),
              toMap: (element) => element,
            ),
          ),
        ),
      );

      expect(find.text('Custom Exception...'), findsOneWidget);
    });
  });

  group('Widget Tests - Bounded and Unbounded Constraints', () {
    testWidgets('CustomDataTable renders properly inside bounded height',
        (tester) async {
      final columns = [
        ColumnInfo(key: 'id', name: 'ID', width: 60),
      ];

      final sampleData = [
        {'id': '1'},
        {'id': '2'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: CustomDataTable<Map<String, String>>(
                columns: columns,
                data: sampleData,
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('ID'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets(
        'CustomDataTable renders properly inside unbounded vertical viewport',
        (tester) async {
      final columns = [
        ColumnInfo(key: 'id', name: 'ID', width: 60),
      ];

      final sampleData = [
        {'id': '1'},
        {'id': '2'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: CustomDataTable<Map<String, String>>(
                columns: columns,
                data: sampleData,
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('ID'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
