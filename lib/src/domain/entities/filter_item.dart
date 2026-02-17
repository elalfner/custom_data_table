import 'package:custom_data_table/src/domain/entities/column_info.dart';

/// Represents a section to show in the filter dialog.
class FilterSection<T> {
  /// Column name that the [filters] belong.
  final ColumnId columnInfo;

  /// Available filters to apply.
  final List<FilterItem<T>> filters;

  List<FilterItem<T>>? selectedFilters;

  FilterSection({
    required this.columnInfo,
    required this.filters,
    this.selectedFilters,
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

/// Filter that can be applied to the table.
class FilterItem<T> {
  /// Filter's name to display.
  final String filterName;

  /// Filter's value to apply.
  final T value;

  final dynamic sendValue;

  FilterItem({
    required this.filterName,
    required this.value,
    this.sendValue,
  });
}
