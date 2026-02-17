import 'package:custom_data_table/custom_data_table.dart';

/// Indicates if a column is marked as sorting column, meaning that the data is
/// sorted by this column.
///
/// Also, it specifies if the column is sorted ascendant or descendant.
class SortInfo {
  /// Column's name to sort data.
  final ColumnInfo columnInfo;

  /// `true` if the column is sorted ascendant. In the other hand, `false` if it
  /// is sorted descendant.
  bool asc;

  SortInfo({
    required this.columnInfo,
    required this.asc,
  });
}
