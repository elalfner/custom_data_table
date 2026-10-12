import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mock_clipboard.dart';

void main() {
  group('Widget Tests - Localization', () {
    testWidgets('SnackBar and Tooltip display correct English text',
        (tester) async {
      setupMockClipboard();
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
      setupMockClipboard();
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
      setupMockClipboard(shouldThrow: true);
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
}
