import 'column_id.dart';
import 'filter_item.dart';

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
