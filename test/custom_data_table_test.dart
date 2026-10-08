import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    test('PaginatorInfo.singlePage initializes correctly', () {
      final info = PaginatorInfo.singlePage(total: 42);

      expect(info.currentPage, 1);
      expect(info.lastPage, 1);
      expect(info.perPage, 42);
      expect(info.total, 42);
      expect(info.count, 42);
      expect(info.hasMorePages, false);
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
  group('Widget Tests - Localization', () {
    testWidgets('SnackBar and Tooltip display correct English text',
        (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            return null;
          }
          return null;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: CustomDataTable<Map<String, String>>(
                columns: [ColumnInfo(key: 'id', name: 'ID', width: 60)],
                data: const [
                  {'id': '1'}
                ],
                paginatorInfo: PaginatorInfo(
                    lastPage: 1, currentPage: 1, perPage: 10, total: 1),
                toMap: (element) => element,
                canCopy: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final copyButton = find.widgetWithIcon(IconButton, Icons.copy);
      expect(copyButton, findsOneWidget);

      final tooltip = tester.widget<IconButton>(copyButton).tooltip;
      expect(tooltip, 'Copy');

      tester.widget<IconButton>(copyButton).onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Copied to clipboard'), findsOneWidget);
    });

    testWidgets('SnackBar and Tooltip display correct Spanish text',
        (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            return null;
          }
          return null;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: CustomDataTable<Map<String, String>>(
                columns: [ColumnInfo(key: 'id', name: 'ID', width: 60)],
                data: const [
                  {'id': '1'}
                ],
                paginatorInfo: PaginatorInfo(
                    lastPage: 1, currentPage: 1, perPage: 10, total: 1),
                toMap: (element) => element,
                canCopy: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final copyButton = find.widgetWithIcon(IconButton, Icons.copy);
      expect(copyButton, findsOneWidget);

      final tooltip = tester.widget<IconButton>(copyButton).tooltip;
      expect(tooltip, 'Copiar');

      tester.widget<IconButton>(copyButton).onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Copiado al portapapeles'), findsOneWidget);
    });
    testWidgets(
        'Platform clipboard exceptions are handled gracefully without unhandled errors',
        (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            throw PlatformException(
                code: 'CLIPBOARD_ERROR', message: 'Simulated clipboard error');
          }
          return null;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: CustomDataTable<Map<String, String>>(
                columns: [ColumnInfo(key: 'id', name: 'ID', width: 60)],
                data: const [
                  {'id': '1'}
                ],
                paginatorInfo: PaginatorInfo(
                    lastPage: 1, currentPage: 1, perPage: 10, total: 1),
                toMap: (element) => element,
                canCopy: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final copyButton = find.widgetWithIcon(IconButton, Icons.copy);
      expect(copyButton, findsOneWidget);

      // Tap should not cause an unhandled exception
      tester.widget<IconButton>(copyButton).onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Copied to clipboard'), findsNothing);
    });
  });

  group('Unit Tests - calculateContentHeight', () {
    test('returns 0 when itemCount is 0', () {
      expect(
        calculateContentHeight(
          itemCount: 0,
          minRowHeight: 40,
          dividerHeight: 1,
        ),
        0,
      );
    });

    test('calculates height correctly for populated list', () {
      expect(
        calculateContentHeight(
          itemCount: 3,
          minRowHeight: 40,
          dividerHeight: 1,
        ),
        122, // (40 * 3) + (1 * 2) = 120 + 2 = 122
      );
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
