import 'package:custom_data_table/src/domain/entities/column_info.dart';

/// Represents a section to show in the filter dialog.
class FilterSection<T> {
  /// Column name that the [filters] belong.
  final ColumnId columnInfo;

  /// Available filters to apply.
  final List<FilterItem<T>> filters;

  /// Selected filters.
  ///
  /// This is used to show the selected filters in the filter dialog.
  List<FilterItem<T>>? selectedFilters;

  FilterSection({
    required this.columnInfo,
    required this.filters,
    this.selectedFilters,
  });

  /// Creates a copy of this [FilterSection] with the given fields replaced.
  FilterSection copyWith({
    ColumnId? columnInfo,
    List<FilterItem>? filters,
    List<FilterItem<T>>? selectedFilters,
  }) =>
      FilterSection(
        columnInfo: columnInfo ?? this.columnInfo,
        filters: filters ?? this.filters,
        selectedFilters: selectedFilters ?? this.selectedFilters,
      );
}

/// Filter that can be applied to the table.
class FilterItem<T> {
  /// Filter's name to display.
  final String filterName;

  /// Filter's value to apply.
  final T value;

  FilterItem({
    required this.filterName,
    required this.value,
  });
}
