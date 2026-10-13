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
        'CustomDataTable renders centered default CircularProgressIndicator with compact height when data is null and isLoading is true',
        (tester) async {
      final columns = [
        ColumnInfo(key: 'id', name: 'ID', width: 60),
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
                data: null,
                isLoading: true,
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final indicatorFinder = find.byType(CircularProgressIndicator);
      expect(indicatorFinder, findsOneWidget);

      final indicator =
          tester.widget<CircularProgressIndicator>(indicatorFinder);
      expect(indicator.strokeWidth, 3.0);

      final centerFinder = find.ancestor(
        of: indicatorFinder,
        matching: find.byType(Center),
      );
      expect(centerFinder, findsWidgets);

      final sizedBoxFinder = find.ancestor(
        of: indicatorFinder,
        matching: find.byType(SizedBox),
      );
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder.first);
      expect(sizedBox.width, 30.0);
      expect(sizedBox.height, 30.0);

      final loadingContainerFinder = find
          .ancestor(
            of: indicatorFinder,
            matching: find.byType(Container),
          )
          .first;
      expect(tester.getSize(loadingContainerFinder).height, 100.0);
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

      // Verify dropdown icon remains in the tree during loading and uses disabledColor
      final dropdownIconFinder = find.descendant(
        of: find.byType(TablePaginatedCountWidget),
        matching: find.byIcon(Icons.keyboard_arrow_down_rounded),
      );
      expect(dropdownIconFinder, findsOneWidget);

      final BuildContext context = tester.element(dropdownIconFinder);
      final expectedDisabledColor = Theme.of(context).disabledColor;

      final dropdownIcon = tester.widget<Icon>(dropdownIconFinder);
      expect(dropdownIcon.color, expectedDisabledColor);

      // Verify page number text gracefully dims with disabledColor
      final pageText = tester.widget<Text>(
        find.descendant(
          of: find.byType(TablePaginatedCountWidget),
          matching: find.text('2'),
        ),
      );
      expect(pageText.style?.color, expectedDisabledColor);

      // Verify Material background color is preserved during loading
      final materialFinder = find.ancestor(
        of: pagePickerFinder,
        matching: find.byType(Material),
      );
      final materialWidget = tester.widget<Material>(materialFinder.first);
      expect(
        materialWidget.color,
        Theme.of(context).inputDecorationTheme.fillColor,
      );

      await tester.tap(pagePickerFinder);
      await tester.pump();
      expect(find.byType(SelectPageWidget), findsNothing);
      expect(previousPressed, isFalse);
      expect(nextPressed, isFalse);
      expect(pageSelected, isFalse);
    });

    testWidgets(
        'page selector maintains identical dimensions and switches color between idle and loading',
        (tester) async {
      final columns = createSampleColumns();
      final sampleData = createSampleData();
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
                    data: sampleData,
                    isLoading: loading,
                    paginatorInfo: PaginatorInfo(
                      lastPage: 5,
                      currentPage: 2,
                      perPage: 10,
                      total: 50,
                    ),
                    onSelectedPage: (page) {},
                    toMap: (element) => element,
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final pagePickerFinder = find.ancestor(
        of: find.descendant(
          of: find.byType(TablePaginatedCountWidget),
          matching: find.text('2'),
        ),
        matching: find.byType(InkWell),
      );
      final initialSize = tester.getSize(pagePickerFinder);

      final iconFinder = find.descendant(
        of: find.byType(TablePaginatedCountWidget),
        matching: find.byIcon(Icons.keyboard_arrow_down_rounded),
      );
      expect(iconFinder, findsOneWidget);

      final context = tester.element(iconFinder);
      final activeColor = Theme.of(context).textTheme.bodySmall?.color;
      final disabledColor = Theme.of(context).disabledColor;

      expect(tester.widget<Icon>(iconFinder).color, activeColor);
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byType(TablePaginatedCountWidget),
                matching: find.text('2'),
              ),
            )
            .style
            ?.color,
        activeColor,
      );

      // Switch to loading
      setStateCallback(() {
        loading = true;
      });
      await tester.pump();

      // Zero shift: size is strictly identical
      expect(tester.getSize(pagePickerFinder), initialSize);
      expect(iconFinder, findsOneWidget);
      expect(tester.widget<Icon>(iconFinder).color, disabledColor);
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byType(TablePaginatedCountWidget),
                matching: find.text('2'),
              ),
            )
            .style
            ?.color,
        disabledColor,
      );
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
        'allocates 100.0 px minimum height for empty state under unbounded vertical constraints',
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
      expect(emptySizedBox.height, 100.0);
    });

    testWidgets(
        'bounds empty state to 100.0 px height under bounded vertical constraints',
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
      expect(tester.takeException(), isNull);

      final emptyContainer = find
          .ancestor(
            of: find.byIcon(Icons.inbox_outlined),
            matching: find.byType(Container),
          )
          .first;
      expect(tester.getSize(emptyContainer).height, 100.0);
    });
  });

  group('Widget Tests - Review Iteration Visual Polish', () {
    testWidgets(
        'single-page table retains fillColor on page number button and omits dropdown icon',
        (tester) async {
      final columns = createSampleColumns();
      final sampleData = createSampleData();
      const testFillColor = Color(0xFFE0E0E0);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
              fillColor: testFillColor,
            ),
          ),
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: CustomDataTable<Map<String, String>>(
                columns: columns,
                data: sampleData,
                paginatorInfo: PaginatorInfo.singlePage(total: 2),
                onSelectedPage: (page) {},
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final materialFinder = find
          .ancestor(
            of: find.descendant(
              of: find.byType(TablePaginatedCountWidget),
              matching: find.text('1'),
            ),
            matching: find.byType(Material),
          )
          .first;
      expect(tester.widget<Material>(materialFinder).color, testFillColor);

      // Verify dropdown arrow icon is omitted on single-page table
      final arrowFinder = find.descendant(
        of: find.byType(TablePaginatedCountWidget),
        matching: find.byIcon(Icons.keyboard_arrow_down_rounded),
      );
      expect(arrowFinder, findsNothing);

      // Verify InkWell is inert (onTap == null)
      final inkWellFinder = find
          .ancestor(
            of: find.descendant(
              of: find.byType(TablePaginatedCountWidget),
              matching: find.text('1'),
            ),
            matching: find.byType(InkWell),
          )
          .first;
      expect(tester.widget<InkWell>(inkWellFinder).onTap, isNull);
    });

    testWidgets(
        'TableFooter with total == 0 displays 0 results cleanly without showing 1 to 0 range',
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
                paginatorInfo: PaginatorInfo.singlePage(total: 0),
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final zeroResultsRichTextFinder = find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('0 results.'),
      );
      expect(zeroResultsRichTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(zeroResultsRichTextFinder);
      final fullText = richText.text.toPlainText();

      expect(fullText, '0 results.');
      expect(fullText, isNot(contains('1 to 0')));
      expect(fullText, isNot(contains('to')));
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

  group('Widget Tests - Explicit Error and Initial States (CDT-30)', () {
    testWidgets(
        'renders initialBuilder when data is null, isLoading is false, and hasError is false',
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
                data: null,
                isLoading: false,
                hasError: false,
                initialBuilder: () =>
                    const Text('Initial Search Idle State - CustomDataTable'),
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Initial Search Idle State - CustomDataTable'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
        'renders SizedBox when data is null, isLoading is false, hasError is false, and initialBuilder is null',
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
                data: null,
                isLoading: false,
                hasError: false,
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'falls back to legacy error state when hasError is omitted (null)',
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
                data: null,
                isLoading: false,
                // hasError is null
                errorBuilder: (context, error) =>
                    const Text('Legacy Omitted Error Fallback'),
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Legacy Omitted Error Fallback'), findsOneWidget);
    });

    testWidgets(
        'renders errorBuilder immediately when hasError is true even if isLoading is true',
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
                data: null,
                isLoading: true,
                hasError: true,
                error: 'Server Fatal 500',
                errorBuilder: (context, error) => Text('Error: $error'),
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error: Server Fatal 500'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
        'prioritizes errorBuilder over deprecated exceptionBuilder in CustomDataTable',
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
                data: null,
                isLoading: false,
                hasError: true,
                error: 'API Error',
                errorBuilder: (context, error) =>
                    const Text('Canonical Error Builder In CustomDataTable'),
                // ignore: deprecated_member_use_from_same_package
                exceptionBuilder: () =>
                    const Text('Legacy Exception Builder In CustomDataTable'),
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Canonical Error Builder In CustomDataTable'),
        findsOneWidget,
      );
      expect(
        find.text('Legacy Exception Builder In CustomDataTable'),
        findsNothing,
      );
    });

    testWidgets(
        'falls back to deprecated exceptionBuilder when errorBuilder is omitted',
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
                data: null,
                isLoading: false,
                hasError: true,
                // ignore: deprecated_member_use_from_same_package
                exceptionBuilder: () =>
                    const Text('ExceptionBuilder Fallback Verified'),
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ExceptionBuilder Fallback Verified'), findsOneWidget);
    });

    testWidgets(
        'displays default error banner and preserves table rows when data is populated, hasError is true, and showErrorBanner is true',
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
                hasError: true,
                error: 'Background refetch failed',
                showErrorBanner: true,
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Data rows remain rendered and intact
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);

      // Default error banner is rendered
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Background refetch failed'), findsOneWidget);
    });

    testWidgets(
        'displays custom errorBannerBuilder and preserves rows when showErrorBanner is true',
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
                hasError: true,
                error: '503 Service Unavailable',
                showErrorBanner: true,
                errorBannerBuilder: (context, error) => Container(
                  key: const Key('custom_cdt_banner'),
                  child: Text('Custom Alert: $error'),
                ),
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.byKey(const Key('custom_cdt_banner')), findsOneWidget);
      expect(
        find.text('Custom Alert: 503 Service Unavailable'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets(
        'does not display error banner when hasError is true and showErrorBanner is false',
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
                hasError: true,
                error: 'Background error',
                showErrorBanner: false,
                toMap: (element) => element,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Data rows remain intact
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });
}
