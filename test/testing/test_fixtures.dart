import 'package:custom_data_table/custom_data_table.dart';

/// Creates sample columns for table testing.
List<ColumnInfo> createSampleColumns() => [
      ColumnInfo(key: 'id', name: 'ID', width: 60),
      ColumnInfo(key: 'name', name: 'Name', width: 120),
    ];

/// Creates sample data rows for table testing.
List<Map<String, String>> createSampleData() => [
      {'id': '1', 'name': 'Alice'},
      {'id': '2', 'name': 'Bob'},
    ];
