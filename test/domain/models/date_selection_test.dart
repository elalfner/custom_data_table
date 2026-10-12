import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateSelection Unit Tests', () {
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
}
