import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests - TableContent', () {
    final columns = [
      ColumnInfo(key: 'id', name: 'ID', width: 100),
      ColumnInfo(key: 'name', name: 'Name', width: 200),
    ];
    final sampleData = [
      {'id': '1', 'name': 'Item 1'},
      {'id': '2', 'name': 'Item 2'},
    ];

    testWidgets('renders loading state when data is null and isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TableContent<Map<String, String>>(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 300,
                  ),
                  columns: columns,
                  data: null,
                  toMap: (element) => element,
                  isLoading: true,
                  loadingBuilder: () => const Text('Custom Loading Indicator'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Custom Loading Indicator'), findsOneWidget);
    });

    testWidgets(
        'renders exception state when data is null and isLoading is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TableContent<Map<String, String>>(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 300,
                  ),
                  columns: columns,
                  data: null,
                  toMap: (element) => element,
                  isLoading: false,
                  exceptionBuilder: () => const Text('No Data Available'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Data Available'), findsOneWidget);
    });

    testWidgets('renders within Flexible when constraints have bounded height',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              width: 500,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  TableContent<Map<String, String>>(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 350,
                    ),
                    columns: columns,
                    data: sampleData,
                    toMap: (element) => element,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Flexible), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets(
        'adapts height in unbounded vertical constraints without overflow',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    TableContent<Map<String, String>>(
                  constraints:
                      constraints, // unbounded height from SingleChildScrollView
                  columns: columns,
                  data: sampleData,
                  toMap: (element) => element,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'attaches dual scrollbars when viewport width is smaller than columns',
        (tester) async {
      final vController = ScrollController();
      final hController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150, // total column width is 300 > 150
              height: 300,
              child: Column(
                children: [
                  TableContent<Map<String, String>>(
                    constraints: const BoxConstraints(
                      maxWidth: 150,
                      maxHeight: 300,
                    ),
                    columns: columns,
                    data: sampleData,
                    toMap: (element) => element,
                    verticalScrollController: vController,
                    horizontalScrollController: hController,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Dual scrollbars check: finding Scrollbar widgets
      expect(find.byType(Scrollbar), findsAtLeastNWidgets(2));
      expect(vController.hasClients, isTrue);
      expect(hController.hasClients, isTrue);
    });

    testWidgets(
        'renders default empty state when data is empty and emptyBuilder is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 300,
              child: Column(
                children: [
                  TableContent<Map<String, String>>(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 300,
                    ),
                    columns: columns,
                    data: const [],
                    toMap: (element) => element,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.inbox_outlined)).size,
        30.0,
      );
      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('renders custom emptyBuilder when data is empty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 300,
              child: Column(
                children: [
                  TableContent<Map<String, String>>(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 300,
                    ),
                    columns: columns,
                    data: const [],
                    emptyBuilder: () => const Text('Custom Empty Placeholder'),
                    toMap: (element) => element,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Custom Empty Placeholder'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets(
        'allocates 100.0 px height in unbounded vertical constraints when data is empty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    TableContent<Map<String, String>>(
                  constraints: constraints,
                  columns: columns,
                  data: const [],
                  toMap: (element) => element,
                ),
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
        'bounds height to 100.0 px in bounded vertical constraints when data is empty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: DataTableLocalizations.localizationsDelegates,
          supportedLocales: DataTableLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 400,
              child: Column(
                children: [
                  TableContent<Map<String, String>>(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 350,
                    ),
                    columns: columns,
                    data: const [],
                    toMap: (element) => element,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final emptyContainerFinder = find
          .ancestor(
            of: find.byIcon(Icons.inbox_outlined),
            matching: find.byType(Container),
          )
          .first;
      expect(tester.getSize(emptyContainerFinder).height, 100.0);
    });

    testWidgets(
        'renders centered default loading indicator when data is null, isLoading is true, and loadingBuilder is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TableContent<Map<String, String>>(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 300,
                  ),
                  columns: columns,
                  data: null,
                  toMap: (element) => element,
                  isLoading: true,
                ),
              ],
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
    });

    testWidgets(
        'allocates 100.0 px height in unbounded vertical constraints when data is null and isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    TableContent<Map<String, String>>(
                  constraints: constraints,
                  columns: columns,
                  data: null,
                  isLoading: true,
                  toMap: (element) => element,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);

      final height100SizedBoxFinder = find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 100.0,
        ),
      );
      expect(height100SizedBoxFinder, findsOneWidget);
    });

    testWidgets(
        'bounds height to 100.0 px in bounded vertical constraints when data is null and isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 400,
              child: Column(
                children: [
                  TableContent<Map<String, String>>(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 350,
                    ),
                    columns: columns,
                    data: null,
                    isLoading: true,
                    toMap: (element) => element,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);

      final loadingContainerFinder = find
          .ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(Container),
          )
          .first;
      expect(tester.getSize(loadingContainerFinder).height, 100.0);
    });
  });
}
