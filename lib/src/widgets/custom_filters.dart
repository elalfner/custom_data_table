import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/utils/date_time_extension.dart';
import 'package:custom_data_table/src/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../custom_data_table.dart';
import 'dates_filter_chip.dart';

class CustomFilters extends StatefulWidget {
  final List<FilterSection>? sections;

  final Function(List<FilterSection> sections)? onChange;

  final DateFilterType? dateFilterType;
  final DateTime? date;
  final DateTime? endDate;

  final DateTime? firstDate;
  final DateTime? lastDate;

  final ChangeDateCallback? onChangeDateFilter;

  final VoidCallback? onTapDateFilter;

  const CustomFilters({
    Key? key,
    this.sections,
    this.onChange,
    this.dateFilterType,
    this.date,
    this.endDate,
    this.onChangeDateFilter,
    this.onTapDateFilter,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  factory CustomFilters.dateFilter({
    final DateFilterType? dateFilterType,
    final DateTime? date,
    final DateTime? endDate,
    final ChangeDateCallback? onChangeDateFilter,
  }) =>
      CustomFilters(
        dateFilterType: dateFilterType,
        date: date,
        endDate: endDate,
        onChangeDateFilter: onChangeDateFilter,
      );

  @override
  State<CustomFilters> createState() => _CustomFiltersState();
}

class _CustomFiltersState extends State<CustomFilters> {
  late List<FilterSection> selectedFilters;

  DateFilterType? dateFilterType;
  DateTime? date;
  DateTime? endDate;

  @override
  void initState() {
    selectedFilters = widget.sections ?? [];

    dateFilterType = widget.dateFilterType;
    date = widget.date;
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
        if (dateFilterType == DateFilterType.date &&
            date?.onlyDate == DateTime.now().onlyDate)
          Chip(
            elevation: 1,
            label: Text(context.appLocalizations.onlyToday),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () {
              dateFilterType = null;

              date = null;
              endDate = null;

              setState(() {});

              notifyDateFilterChange();
            },
          ),
        if (dateFilterType == DateFilterType.date &&
            date != null &&
            date?.onlyDate != DateTime.now().onlyDate)
          Chip(
            elevation: 1,
            label: Text(DateFormat.yMd().format(date!)),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () {
              dateFilterType = null;

              date = null;
              endDate = null;

              setState(() {});

              notifyDateFilterChange();
            },
          ),
        if (dateFilterType == DateFilterType.month && date != null)
          Chip(
            elevation: 1,
            label: Text(DateFormat.yMMMM().format(date!)),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () {
              dateFilterType = null;

              date = null;
              endDate = null;

              setState(() {});

              notifyDateFilterChange();
            },
          ),
        if (dateFilterType == DateFilterType.year && date != null)
          Chip(
            elevation: 1,
            label: Text(DateFormat.y().format(date!)),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () {
              dateFilterType = null;

              date = null;
              endDate = null;

              setState(() {});

              notifyDateFilterChange();
            },
          ),
        if (dateFilterType == DateFilterType.period &&
            date != null &&
            endDate != null)
          Chip(
            elevation: 1,
            label: Text(
                '${DateFormat.yMd().add_Hm().format(date!)} - ${DateFormat.yMd().add_Hm().format(endDate!)}'),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () {
              dateFilterType = null;

              date = null;
              endDate = null;

              setState(() {});

              notifyDateFilterChange();
            },
          ),
        if (widget.onChange != null && widget.sections != null)
          ActionChip(
            elevation: 1,
            label: Text(
              context.appLocalizations.moreFilters.naturalCapitalized,
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
            dateFilterType: dateFilterType,
            date: date,
            endDate: endDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            onTapDateFilter: widget.onTapDateFilter,
            onChangeDateFilter: (dateFilterType, date, endDate) {
              this.dateFilterType = dateFilterType;
              this.date = date;
              this.endDate = endDate;

              widget.onChangeDateFilter?.call(dateFilterType, date, endDate);

              setState(() {});
            },
          ),
      ],
    );
  }

  void showFilters() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => PointerInterceptor(
        child: filtersView(),
      ),
    );

    setState(() {});

    widget.onChange?.call(selectedFilters);
  }

  Widget filtersView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(20).copyWith(bottom: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.appLocalizations.moreFilters.naturalCapitalized,
                  style: Theme.of(context).textTheme.titleLarge,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
              TextButton(
                onPressed: () {
                  for (final section in selectedFilters) {
                    section.selectedFilters = null;
                  }
                  Navigator.pop(context);
                },
                child: Text(
                    context.appLocalizations.cleanFilters.naturalCapitalized),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        ),
        Flexible(
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20).copyWith(top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final section in selectedFilters)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: FilterSectionWidget(
                        section: section,
                        selectedFilters: [
                          for (final section in selectedFilters)
                            ...section.selectedFilters ?? []
                        ],
                        onChange: (values) => section.selectedFilters = values,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void notifyDateFilterChange() {
    widget.onChangeDateFilter?.call(dateFilterType, date, endDate);
  }
}

class FiltersView extends StatelessWidget {
  final List<FilterSection> sections;
  final Function(List<FilterSection> sections)? onChange;

  final bool showTitle;

  const FiltersView({
    Key? key,
    required this.sections,
    this.onChange,
    this.showTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final section in sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FilterSectionWidget(
              section: section,
              selectedFilters: [
                for (final section in sections) ...section.selectedFilters ?? []
              ],
              showTitle: showTitle,
              onChange: (values) {
                section.selectedFilters = values;

                onChange?.call(sections);
              },
            ),
          ),
      ],
    );
  }
}
