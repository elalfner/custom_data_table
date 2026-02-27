import 'package:custom_data_table/src/domain/entities/filter_item.dart';
import 'package:flutter/material.dart';

/// Widget that displays a section of filters.
///
/// It shows a title and a list of filters as FilterChips. When a filter is
/// selected, it calls the [onChange] callback. And update the state of the
/// widget.
class FilterSectionWidget<T> extends StatefulWidget {
  /// The section of filters to display.
  ///
  /// It contains the column information and the filters.
  final FilterSection<T> section;

  /// The initial selected filters.
  ///
  /// If null, no filters will be selected.
  final List<FilterItem<T>>? selectedFilters;

  /// The callback that is called when a filter is selected.
  final void Function(List<FilterItem<T>> values) onChange;

  /// Whether to show the title.
  final bool showTitle;

  const FilterSectionWidget({
    super.key,
    required this.section,
    this.selectedFilters,
    required this.onChange,
    this.showTitle = true,
  });

  @override
  State<FilterSectionWidget<T>> createState() => _FilterSectionWidgetState<T>();
}

class _FilterSectionWidgetState<T> extends State<FilterSectionWidget<T>> {
  /// The section of filters to display.
  FilterSection<T> get section => widget.section;

  /// The filters to display.
  List<FilterItem<T>> get filters => section.filters;

  /// The selected filters.
  late Set<String> selected = {};

  /// The selected filters.
  ///
  /// It is a list of filters that are selected.
  List<FilterItem<T>> get selectedFilters => filters
      .where((element) => selected.contains(element.filterName))
      .toList();

  @override
  void initState() {
    // Initialize the selected filters.
    final selectedFilters = widget.selectedFilters;

    if (selectedFilters != null) {
      selected = {for (final f in selectedFilters) f.filterName};
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        if (widget.showTitle) Text(section.columnInfo.name),
        Wrap(
          runSpacing: 5,
          spacing: 5,
          children: [
            for (final filter in filters) filterWidget(filter),
          ],
        )
      ],
    );
  }

  /// Widget that displays a filter chip.
  ///
  /// It is a [FilterChip] that displays the filter name and the filter value.
  /// When the filter is selected, it calls the callback.
  Widget filterWidget(FilterItem filter) {
    return FilterChip(
      label: Text(filter.filterName),
      selected: selected.contains(filter.filterName),
      onSelected: (value) {
        if (value) {
          selected.add(filter.filterName);
        } else {
          selected.remove(filter.filterName);
        }

        setState(() {});

        widget.onChange(selectedFilters);
      },
    );
  }
}
