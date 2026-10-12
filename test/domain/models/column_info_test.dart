import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColumnInfo Unit Tests', () {
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

    test('ColumnId initializes correctly with defaults', () {
      final columnId = ColumnId(key: 'user_id', name: 'User ID');

      expect(columnId.key, 'user_id');
      expect(columnId.name, 'User ID');
      expect(columnId.canGeneralSearch, isFalse);
    });
  });
}
