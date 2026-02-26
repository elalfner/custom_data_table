import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/utils/date_time_extension.dart';
import 'package:custom_data_table/src/core/utils/string_extension.dart';
import 'package:custom_data_table/src/domain/entities/date_selection.dart';
import 'package:custom_data_table/src/domain/entities/filter_item.dart';
import 'package:custom_data_table/src/domain/enums/date_filter_type.dart';
import 'package:custom_data_table/src/presentation/widgets/common/dates_filter_chip.dart';
import 'package:custom_data_table/src/presentation/widgets/filter_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// A widget that displays the selected filters.
///
/// This widget is used to display the selected filters in a list of chips.
/// It contains the buttons to open the filters view and the date filter.
class CustomFilters extends StatefulWidget {
  /// The list of filter sections.
  final List<FilterSection>? sections;

  /// The callback function that is called when the selected filters are changed.
  final Function(List<FilterSection> sections)? onChange;

  /// The initial date filter.
  final DateSelection? initialDateFilter;

  /// The first date of the date range.
  final DateTime? firstDate;

  /// The last date of the date range.
  final DateTime? lastDate;

  /// The callback function that is called when the date filter is changed.
  ///
  /// If `null`, the chip [DatesFilterChip] will not be displayed.
  final ChangeDateCallback? onChangeDateFilter;

  /// The callback function that is called when the date filter is tapped.
  final VoidCallback? onTapDateFilter;

  const CustomFilters({
    Key? key,
    this.sections,
    this.onChange,
    this.initialDateFilter,
    this.onChangeDateFilter,
    this.onTapDateFilter,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  State<CustomFilters> createState() => _CustomFiltersState();
}

class _CustomFiltersState extends State<CustomFilters> {
  /// The list of filter sections.
  late List<FilterSection> selectedFilters;

  /// The date filter.
  DateSelection? dateFilter;

  @override
  void initState() {
    selectedFilters = widget.sections ?? [];

    dateFilter = widget.initialDateFilter;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dateFilter = this.dateFilter;
    final dateFilterType = dateFilter?.dateFilterType;
    final date = dateFilter?.date;
    final endDate = dateFilter?.endDate;

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
              this.dateFilter = null;
              setState(() {});

              notifyDateFilterChange();
            },
          ),
        if (dateFilterType == DateFilterType.date &&
            date != null &&
            date.onlyDate != DateTime.now().onlyDate)
          Chip(
            elevation: 1,
            label: Text(DateFormat.yMd().format(date)),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () {
              this.dateFilter = null;
              setState(() {});

              notifyDateFilterChange();
            },
          ),
        if (dateFilterType == DateFilterType.month && date != null)
          Chip(
            elevation: 1,
            label: Text(DateFormat.yMMMM().format(date)),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () {
              this.dateFilter = null;
              setState(() {});

              setState(() {});

              notifyDateFilterChange();
            },
          ),
        if (dateFilterType == DateFilterType.year && date != null)
          Chip(
            elevation: 1,
            label: Text(DateFormat.y().format(date)),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () {
              this.dateFilter = null;
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
                '${DateFormat.yMd().add_Hm().format(date)} - ${DateFormat.yMd().add_Hm().format(endDate)}'),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () {
              this.dateFilter = null;
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
            onChangeDateFilter: (dateFilter) {
              this.dateFilter = dateFilter;
              setState(() {});

              widget.onChangeDateFilter?.call(dateFilter);
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
                    context.appLocalizations.clearFilters.naturalCapitalized),
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
    widget.onChangeDateFilter?.call(dateFilter);
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

class SelectFiltersDialog extends StatelessWidget {
  final List<FilterSection> filters;

  final Function(List<FilterSection> selectedFilters)? onChange;

  const SelectFiltersDialog({super.key, required this.filters, this.onChange});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              context.appLocalizations.filter.naturalCapitalized,
              style: Theme.of(context).textTheme.titleLarge,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
          TextButton(
            onPressed: () {
              for (final section in filters) {
                section.selectedFilters = null;
              }
              Navigator.pop(context, filters);
            },
            child:
                Text(context.appLocalizations.clearFilters.naturalCapitalized),
          ),
        ],
      ),
      content: SizedBox(
        width: 350,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final section in filters)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: FilterSectionWidget(
                    section: section,
                    selectedFilters: [
                      for (final section in filters)
                        ...section.selectedFilters ?? []
                    ],
                    onChange: (values) => section.selectedFilters = values,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context, filters),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

class SelectedFiltersWidget extends StatefulWidget {
  final List<FilterSection>? selectedFilters;
  final DateSelection? dateFilters;

  final Function(List<FilterSection> selectedFilters)? onChange;
  final VoidCallback? onDateFilterClear;

  const SelectedFiltersWidget({
    super.key,
    this.selectedFilters,
    this.dateFilters,
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
    final dateFilters = widget.dateFilters;

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
        if (dateFilters != null) ...selectedDatesFilter(dateFilters),
      ],
    );
  }

  List<Widget> selectedDatesFilter(DateSelection dateFilters) {
    final dateFilterType = dateFilters.dateFilterType;
    final date = dateFilters.date;
    final endDate = dateFilters.endDate;

    return [
      if (dateFilterType == DateFilterType.date &&
          date?.onlyDate == DateTime.now().onlyDate)
        Chip(
          elevation: 1,
          label: Text(context.appLocalizations.onlyToday),
          deleteIcon: const Icon(
            Icons.close,
            size: 14,
          ),
          onDeleted: widget.onDateFilterClear,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          padding: EdgeInsets.zero,
        ),
      if (dateFilterType == DateFilterType.date &&
          date != null &&
          date.onlyDate != DateTime.now().onlyDate)
        Chip(
          elevation: 1,
          label: Text(DateFormat.yMd().format(date)),
          deleteIcon: const Icon(
            Icons.close,
            size: 14,
          ),
          onDeleted: widget.onDateFilterClear,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          padding: EdgeInsets.zero,
        ),
      if (dateFilterType == DateFilterType.month && date != null)
        Chip(
          elevation: 1,
          label: Text(DateFormat.yMMMM().format(date)),
          deleteIcon: const Icon(
            Icons.close,
            size: 14,
          ),
          onDeleted: widget.onDateFilterClear,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          padding: EdgeInsets.zero,
        ),
      if (dateFilterType == DateFilterType.year && date != null)
        Chip(
          elevation: 1,
          label: Text(DateFormat.y().format(date)),
          deleteIcon: const Icon(
            Icons.close,
            size: 14,
          ),
          onDeleted: widget.onDateFilterClear,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          padding: EdgeInsets.zero,
        ),
      if (dateFilterType == DateFilterType.period &&
          date != null &&
          endDate != null)
        Chip(
          elevation: 1,
          label: Text(
              '${DateFormat.yMd().add_Hm().format(date)} - ${DateFormat.yMd().add_Hm().format(endDate)}'),
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
