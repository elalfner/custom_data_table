import 'package:custom_data_table/custom_data_table.dart';

/// Search field information.
///
/// It is used to store the search value for a specific column.
class SearchFieldInfo {
  /// Column information.
  final ColumnInfo columnInfo;

  /// Search value.
  final String searchValue;

  SearchFieldInfo({
    required this.columnInfo,
    required this.searchValue,
  });
}
