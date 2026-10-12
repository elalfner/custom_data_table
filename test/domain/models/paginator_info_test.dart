import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaginatorInfo Unit Tests', () {
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
}
