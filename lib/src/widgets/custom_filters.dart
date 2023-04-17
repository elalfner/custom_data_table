import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../custom_data_table.dart';
import 'dates_filter_chip.dart';

class CustomFilters extends StatefulWidget {
  final List<FilterSection>? sections;
  final List<FilterSection>? selectedFilters;

  final Function(List<FilterSection> sections)? onChange;

  final bool today;
  final DateTime? selectedMonth;
  final DateTime? startDate;
  final DateTime? endDate;

  final ChangeDateCallback? onChangeDateFilter;

  const CustomFilters({
    Key? key,
    this.sections,
    this.selectedFilters,
    this.onChange,
    this.today = false,
    this.selectedMonth,
    this.startDate,
    this.endDate,
    this.onChangeDateFilter,
  }) : super(key: key);

  factory CustomFilters.dateFilter({
    final bool today = false,
    final DateTime? selectedMonth,
    final DateTime? startDate,
    final DateTime? endDate,
    final ChangeDateCallback? onChangeDateFilter,
  }) =>
      CustomFilters(
        today: today,
        selectedMonth: selectedMonth,
        startDate: startDate,
        endDate: endDate,
        onChangeDateFilter: onChangeDateFilter,
      );

  @override
  State<CustomFilters> createState() => _CustomFiltersState();
}

class _CustomFiltersState extends State<CustomFilters> {
  late List<FilterSection> selectedFilters;

  bool today = false;
  DateTime? selectedMonth;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    selectedFilters = widget.selectedFilters ?? widget.sections ?? [];

    today = widget.today;
    selectedMonth = widget.selectedMonth;
    startDate = widget.startDate;
    endDate = widget.endDate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (final FilterSection section in selectedFilters)
          for (final FilterItem filter in section.selectedFilters ?? [])
            Chip(
              elevation: 1,
              label: Text('${section.columnInfo.name}: ${filter.filterName}'),
              deleteIcon: const Icon(
                Icons.close,
                size: 14,
              ),
              onDeleted: () {
                section.selectedFilters?.remove(filter);

                setState(() {});

                widget.onChange?.call(selectedFilters);
              },
            ),
        if (today)
          Chip(
            elevation: 1,
            label: const Text('Sólo Hoy'),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () {
              setState(() {
                today = false;
              });

              notifyDateFilterChange();
            },
          ),
        if (selectedMonth != null)
          Chip(
            elevation: 1,
            label: Text(DateFormat.yMMMM().format(selectedMonth!)),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () {
              setState(() {
                selectedMonth = null;
              });

              notifyDateFilterChange();
            },
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
            onDeleted: () {
              setState(() {
                startDate = null;
                endDate = null;
              });

              notifyDateFilterChange();
            },
          ),
        if (widget.onChange != null && widget.sections != null)
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
            onPressed: showFilters,
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

  void showFilters() async {
    await showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(
        maxWidth: 500,
        minWidth: 500,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => filtersView(),
    );

    setState(() {});

    widget.onChange?.call(selectedFilters);
  }

  Widget filtersView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final section in selectedFilters)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FilterSectionWidget(
                section: section,
                onChange: (values) => section.selectedFilters = values,
              ),
            ),
        ],
      ),
    );
  }

  void notifyDateFilterChange() {
    widget.onChangeDateFilter?.call(today, selectedMonth, startDate, endDate);
  }
}
