import 'package:custom_data_table/custom_data_table.dart';

class FilterSection {
  final ColumnId columnInfo;
  final List<FilterItem> filters;

  FilterSection({
    required this.columnInfo,
    required this.filters,
  });

  FilterSection copyWith({
    ColumnId? columnInfo,
    List<FilterItem>? filters,
  }) =>
      FilterSection(
        columnInfo: columnInfo ?? this.columnInfo,
        filters: filters ?? this.filters,
      );
}

class FilterItem {
  ColumnId? columnInfo;
  final String filterName;
  final dynamic value;

  FilterItem({
    this.columnInfo,
    required this.filterName,
    required this.value,
  });
}
