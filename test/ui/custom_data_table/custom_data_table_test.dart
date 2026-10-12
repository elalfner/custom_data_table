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

  group('Widget Tests - Loading Cycle and Pagination Lockdown', () {
    testWidgets(
        'pagination controls (previous, next, and page picker) are disabled during active loading',
        (tester) async {
      bool previousPressed = false;
      bool nextPressed = false;
      bool pageSelected = false;

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
                isLoading: true,
                paginatorInfo: PaginatorInfo(
                  lastPage: 5,
                  currentPage: 2,
                  perPage: 10,
                  total: 50,
                ),
                onPreviousPage: () => previousPressed = true,
                onNextPage: () => nextPressed = true,
                onSelectedPage: (page) => pageSelected = true,
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final prevFinder = find.widgetWithIcon(
        IconButton,
        Icons.arrow_back_ios_new_rounded,
      );
      final nextFinder = find.widgetWithIcon(
        IconButton,
        Icons.arrow_forward_ios_rounded,
      );

      expect(prevFinder, findsOneWidget);
      expect(nextFinder, findsOneWidget);

      final prevButton = tester.widget<IconButton>(prevFinder);
      final nextButton = tester.widget<IconButton>(nextFinder);

      expect(prevButton.onPressed, isNull);
      expect(nextButton.onPressed, isNull);

      // Verify page picker dropdown is disabled
      final pagePickerFinder = find.ancestor(
        of: find.descendant(
          of: find.byType(TablePaginatedCountWidget),
          matching: find.text('2'),
        ),
        matching: find.byType(InkWell),
      );
      expect(pagePickerFinder, findsOneWidget);
      final pagePickerInkWell = tester.widget<InkWell>(pagePickerFinder);
      expect(pagePickerInkWell.onTap, isNull);

      await tester.tap(pagePickerFinder);
      await tester.pump();
      expect(find.byType(SelectPageWidget), findsNothing);
      expect(previousPressed, isFalse);
      expect(nextPressed, isFalse);
      expect(pageSelected, isFalse);
    });

    testWidgets(
        'top LinearProgressIndicator is hidden on initial load and visible on reload',
        (tester) async {
      final columns = createSampleColumns();
      final sampleData = createSampleData();

      // Case 1: Initial load (data == null && isLoading == true)
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
                data: null,
                isLoading: true,
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Case 2: Background reload (data != null && isLoading == true)
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
                isLoading: true,
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('Widget Tests - Empty State Support', () {
    testWidgets(
        'renders default localized empty placeholder when data is empty',
        (tester) async {
      final columns = createSampleColumns();

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
                data: const [],
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets(
        'renders Spanish localized empty placeholder when locale is Spanish',
        (tester) async {
      final columns = createSampleColumns();

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: CustomDataTable<Map<String, String>>(
                columns: columns,
                data: const [],
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No se han encontrado resultados'), findsOneWidget);
    });

    testWidgets('renders custom emptyBuilder when provided and data is empty',
        (tester) async {
      final columns = createSampleColumns();

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
                data: const [],
                emptyBuilder: () =>
                    const Text('Custom Empty State Placeholder'),
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Custom Empty State Placeholder'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets(
        'allocates 160.0 px minimum height for empty state under unbounded vertical constraints',
        (tester) async {
      final columns = createSampleColumns();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: CustomDataTable<Map<String, String>>(
                columns: columns,
                data: const [],
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final emptySizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byIcon(Icons.inbox_outlined),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(emptySizedBox.height, 160.0);
    });
  });

  group('Widget Tests - Transitioning Data to Null', () {
    testWidgets(
        'transitioning data from populated list to null resets content cleanly',
        (tester) async {
      final columns = createSampleColumns();
      final sampleData = createSampleData();

      List<Map<String, String>>? currentData = sampleData;
      bool loading = false;

      late StateSetter setStateCallback;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setStateCallback = setState;
                return SizedBox(
                  width: 800,
                  height: 600,
                  child: CustomDataTable<Map<String, String>>(
                    columns: columns,
                    data: currentData,
                    isLoading: loading,
                    loadingBuilder: () => const Text('Loading Now...'),
                    toMap: (element) => element,
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);

      // Transition data to null and loading to true
      setStateCallback(() {
        currentData = null;
        loading = true;
      });
      await tester.pump();

      expect(find.text('Alice'), findsNothing);
      expect(find.text('Bob'), findsNothing);
      expect(find.text('Loading Now...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
