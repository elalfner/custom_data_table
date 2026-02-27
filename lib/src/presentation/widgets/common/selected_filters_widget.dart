import 'package:custom_data_table/src/domain/entities/date_selection.dart';
import 'package:custom_data_table/src/domain/entities/filter_item.dart';
import 'package:flutter/material.dart';

/// A widget that displays the selected filters.
///
/// This widget is used to display the selected filters in a list of chips.
///
/// It shows custom filters and date filters.
class SelectedFiltersWidget extends StatefulWidget {
  /// The list of selected filters.
  final List<FilterSection>? selectedFilters;

  /// The selected date filter.
  final DateSelection? dateFilter;

  /// The callback function that is called when the selected filters are changed.
  final Function(List<FilterSection> selectedFilters)? onChange;

  /// The callback function that is called when the date filter is cleared.
  final VoidCallback? onDateFilterClear;

  const SelectedFiltersWidget({
    super.key,
    this.selectedFilters,
    this.dateFilter,
    this.onChange,
    this.onDateFilterClear,
  });

  @override
  State<SelectedFiltersWidget> createState() => _SelectedFiltersWidgetState();
}

class _SelectedFiltersWidgetState extends State<SelectedFiltersWidget> {
  @override
  Widget build(BuildContext context) {
    final selectedFilters = widget.selectedFilters;
    final dateFilter = widget.dateFilter;

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        if (selectedFilters != null)
          for (final FilterSection section in selectedFilters)
            for (final FilterItem filter in section.selectedFilters ?? [])
              Chip(
                label: Text('${section.columnInfo.name}: ${filter.filterName}'),
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.only(left: 8),
                deleteIcon: const Icon(
                  Icons.close,
                  size: 14,
                ),
                onDeleted: () {
                  section.selectedFilters?.remove(filter);

                  widget.onChange?.call(selectedFilters);
                },
              ),
        if (dateFilter != null) ...selectedDatesFilter(dateFilter),
      ],
    );
  }

  /// Returns a list of [Chip] widgets representing the selected date filters.
  ///
  /// The [dateFilter] object is used to determine the type of date filter
  /// and the date values to display.
  List<Widget> selectedDatesFilter(DateSelection dateFilter) {
    final dateLabel = dateFilter.label(context);

    return [
      if (dateLabel != null)
        Chip(
          elevation: 1,
          label: Text(dateLabel),
          deleteIcon: const Icon(
            Icons.close,
            size: 14,
          ),
          onDeleted: widget.onDateFilterClear,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          padding: EdgeInsets.zero,
        ),
    ];
  }
}
