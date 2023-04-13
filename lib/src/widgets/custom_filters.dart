import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/filter_item.dart';
import 'dates_filter_chip.dart';

class CustomFilters extends StatefulWidget {
  /// List of applied filters.
  final List<FilterItem>? filterItems;

  /// Callback to notify when a filter element has been pressed to be removed from the filters list.
  ///
  /// [filterItem] item to be removed from the list.
  final Function(FilterItem filterItem) onFilterDeleted;

  /// Builder that creates the view that is displaying when filter button is pressed.
  ///
  /// If not provided, the filter Chip Button is not displayed.
  final WidgetBuilder? filterBuilder;

  /// Callback to notify when date filter button is pressed.
  ///
  /// If not provided, the date filter Chip Button is not displayed.
  final Function(
          bool today, DateTime? month, DateTime? startDate, DateTime? endDate)?
      onChangeDateFilter;

  const CustomFilters(
      {Key? key,
      this.filterItems,
      required this.onFilterDeleted,
      this.filterBuilder,
      this.onChangeDateFilter})
      : super(key: key);

  @override
  State<CustomFilters> createState() => _CustomFiltersState();
}

class _CustomFiltersState extends State<CustomFilters> {
  bool today = false;
  DateTime? selectedMonth;
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (final filter in widget.filterItems ?? [])
          Chip(
            elevation: 1,
            label:
                Text('${filter.columnInfo?.name ?? ''}: ${filter.filterName}'),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () => widget.onFilterDeleted(filter),
          ),
        if (today)
          Chip(
            elevation: 1,
            label: const Text('Sólo Hoy'),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () => setState(() {
              today = false;
            }),
          ),
        if (selectedMonth != null)
          Chip(
            elevation: 1,
            label: Text(DateFormat.yMMMM().format(selectedMonth!)),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () => setState(() {
              selectedMonth = null;
            }),
          ),
        if (startDate != null && endDate != null)
          Chip(
            elevation: 1,
            label: Text(
                '${DateFormat.yMd().add_Hm().format(startDate!)} - ${DateFormat.yMd().add_Hm().format(endDate!)}'),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () => setState(() {
              startDate = null;
              endDate = null;
            }),
          ),
        if (widget.filterBuilder != null)
          ActionChip(
            elevation: 1,
            label: Text(
              'Más filtros',
              style: TextStyle(
                color:
                    Theme.of(context).floatingActionButtonTheme.foregroundColor,
              ),
            ),
            avatar: Icon(
              Icons.filter_list,
              color:
                  Theme.of(context).floatingActionButtonTheme.foregroundColor,
            ),
            backgroundColor:
                Theme.of(context).floatingActionButtonTheme.backgroundColor,
            onPressed: filterPressed,
          ),
        if (widget.onChangeDateFilter != null)
          DatesFilterChip(
            today: today,
            selectedMonth: selectedMonth,
            startDate: startDate,
            endDate: endDate,
            onChangeDateFilter: (today, month, startDate, endDate) {
              this.today = today;
              selectedMonth = month;
              this.startDate = startDate;
              this.endDate = endDate;

              widget.onChangeDateFilter?.call(
                today,
                selectedMonth,
                startDate,
                endDate,
              );

              setState(() {});
            },
          ),
      ],
    );
  }

  void filterPressed() {
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(
        maxWidth: 500,
        minWidth: 500,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: widget.filterBuilder!,
    );
  }
}
