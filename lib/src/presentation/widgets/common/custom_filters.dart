import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/utils/string_extension.dart';
import 'package:custom_data_table/src/domain/entities/date_selection.dart';
import 'package:custom_data_table/src/domain/entities/filter_item.dart';
import 'package:custom_data_table/src/presentation/widgets/common/dates_filter_chip.dart';
import 'package:custom_data_table/src/presentation/widgets/common/select_filters_dialog.dart';
import 'package:custom_data_table/src/presentation/widgets/filter_section_widget.dart';
import 'package:flutter/material.dart';

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
  ///
  /// If `null`, the chip [DatesFilterChip] will be displayed with no date selected.
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
    // Initialize the selected filters.
    selectedFilters = widget.sections ?? [];

    // Initialize the date filter.
    dateFilter = widget.initialDateFilter;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = dateFilter?.label(context);

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
        if (dateLabel != null)
          Chip(
            elevation: 1,
            label: Text(dateLabel),
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
            dateFilter: dateFilter,
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

  /// Shows the [SelectFiltersDialog] to select filters.
  ///
  /// It updates the state and calls the [widget.onChange] callback with the new filters.
  ///
  /// If the user cancels the dialog, it does nothing.
  void showFilters() async {
    // Show the select filters dialog
    final newFilters = await showDialog(
      context: context,
      builder: (context) => SelectFiltersDialog(
        filters: selectedFilters,
      ),
    );

    // Update the state
    setState(() {});

    // If the user cancels the dialog, do nothing
    if (newFilters is! List<FilterSection>) {
      return;
    }

    // Call the onChange callback with the new filters
    widget.onChange?.call(newFilters);
  }

  /// Notifies the [widget.onChangeDateFilter] callback with the new date filter.
  void notifyDateFilterChange() => widget.onChangeDateFilter?.call(dateFilter);
}

/// A widget that displays the selected filters.
///
/// This widget is used to display the selected filters in a list of chips.
/// It contains the buttons to open the filters view and the date filter.
class FiltersView extends StatelessWidget {
  /// The list of filter sections.
  final List<FilterSection> sections;

  /// The callback function that is called when the selected filters are changed.
  final Function(List<FilterSection> sections)? onChange;

  /// Whether to show the title of the filters.
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
