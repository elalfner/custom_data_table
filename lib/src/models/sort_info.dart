import 'package:custom_data_table/custom_data_table.dart';

class SortInfo {
  final ColumnInfo columnInfo;
  bool asc;

  SortInfo({
    required this.columnInfo,
    required this.asc,
  });
}
