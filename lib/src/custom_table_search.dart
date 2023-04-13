import 'package:collection/collection.dart';
import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';

import 'filter_section_widget.dart';
import 'models/sort_info.dart';

class CustomTableSearch<T> extends StatefulWidget {
  /// List of columns the table has.
  ///
  /// Each element of the list contains the name of the column, key to identify it, and the
  /// information of the space that is taking (width).
  final List<ColumnInfo> columns;

  // Table attributes.

  /// Title of table.
  ///
  /// if `null` shows `Listado` in the title.
  final String? title;

  /// Data to show in the table.
  final List<T> data;

  /// Function to convert the row of type Object to Map.
  ///
  /// The map entry key has to match with the key of any column contained in [columns].
  /// In this way the table is going to show the value of the entry in the correct cell.
  final Map<String, dynamic> Function(T element) toMap;

  /// Function to get the widget that is displaying in this cell.
  ///
  /// To know which cell is displaying, the parameters are:
  /// [key] of the column,
  /// [element] object to display in row.
  /// [map] contains the [element] converted to map.
  ///
  /// If not provided or returned `null`, then the cell is displaying a [Text]
  /// with the value that contains the map entry in the [key] as text.
  final Widget? Function(T element, Map<String, dynamic> map, String key)? cell;

  /// Callback to notify when a Row of table is pressed.
  ///
  /// If not provided the rows cannot be pressed.
  final Function(T value)? onElementPressed;

  /// Callback to notify when a column has pressed to sort by this column.
  ///
  /// [sortInfo] contains the information that tell which column has marked to be
  /// sorted, and if te order is ascendant or descendant.
  final Function(SortInfo sortInfo) onSort;

  /// Information of pagination.
  ///
  /// It contains for example the page that is displayed, the number of total pages,
  /// elements per page.
  final PaginatorInfo? paginatorInfo;

  /// Callback that notifies when the previous page button is pressed.
  final VoidCallback? onPreviousPage;

  /// Callback that notifies when the next page button is pressed.
  final VoidCallback? onNextPage;

  final Function(int page)? onSelectedPage;

  /// Callback that notifies when the copy button has been pressed.
  ///
  /// If not provided, the copy button is not shown.
  final VoidCallback? onCopy;

  /// Callback that notifies when the print button has been pressed.
  ///
  /// If not provided, the print button is not shown.
  final VoidCallback? onPrint;

  /// Callback that notifies when the export button has been pressed.
  ///
  /// If not provided, the export button is not shown.
  final VoidCallback? onExport;

  /// Callback to notify that any column search field has changed.
  ///
  /// Sends the value of all text fields.
  /// If not provided, it does not show the search fields.
  final Function(List<SearchFieldInfo> values)? onChangeSearchTextField;

  // Search attributes.

  /// Callback to notify when search fields dropdown has changed.
  ///
  /// Notifies the new search fields to search.
  final Function(List<ColumnId> values)? onChangeSearchFields;

  /// Sections of the filters.
  ///
  /// Each element contains the name and id of the column, and list of filter parameters.
  final List<FilterSection>? filterSections;

  /// Callback that notifies when new filters in search widget are selected.
  ///
  /// If user selects new filters, or deselects filters the Callback is notified.
  final Function(List<FilterItem> values)? onChangeFilters;

  final Function(
          bool today, DateTime? month, DateTime? startDate, DateTime? endDate)?
      onChangeDateFilter;

  const CustomTableSearch({
    Key? key,
    this.title,
    required this.columns,
    required this.data,
    required this.toMap,
    required this.onSort,
    this.cell,
    this.onChangeSearchFields,
    this.filterSections,
    this.onChangeFilters,
    this.onElementPressed,
    this.paginatorInfo,
    this.onPreviousPage,
    this.onNextPage,
    this.onSelectedPage,
    this.onCopy,
    this.onPrint,
    this.onExport,
    this.onChangeSearchTextField,
    this.onChangeDateFilter,
  }) : super(key: key);

  @override
  State<CustomTableSearch<T>> createState() => _CustomTableSearchState<T>();
}

class _CustomTableSearchState<T> extends State<CustomTableSearch<T>> {
  /// Keeps the filters that are selected.
  /// As it is a map, the key is given by the key of the column to filter. And the
  /// value, is a list of filters that are applied to that column.
  ValueNotifier<Map<String, List<FilterItem>>> selectedFiltersMap =
      ValueNotifier({});

  /// Converts [selectedFiltersMap] to list of filter sections to get filters applied
  /// grouped by section.
  List<FilterSection> get selectedFilters => selectedFiltersMap.value.entries
      .map((e) {
        final section = widget.filterSections?.firstWhereOrNull(
          (element) => element.columnInfo.key == e.key,
        );

        final newSection = section?.copyWith(filters: e.value);

        if (newSection == null) return newSection;

        for (final FilterItem filter in newSection.filters) {
          filter.columnInfo = newSection.columnInfo;
        }

        return newSection;
      })
      .where((element) => element != null)
      .map((e) => e!)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SizedBox to tell the widget to take all available width.
        SizedBox(
          width: double.infinity,
          child: ValueListenableBuilder<Map<String, List<FilterItem>>>(
            valueListenable: selectedFiltersMap,
            builder: (context, value, child) => SearchWidget(
              // Removes the filter that was selected previously.
              onFilterDeleted: (filterItem) {
                value[filterItem.columnInfo?.key]?.remove(filterItem);

                selectedFiltersMap.value = {...value};

                widget.onChangeFilters?.call(selectedFilters
                    .expand((element) => element.filters)
                    .toList());
              },
              onChangeSearchFields:
                  widget.onChangeSearchFields ?? (List<ColumnId> values) {},
              columns: widget.columns
                  .map((e) => ColumnId(name: e.name, key: e.key))
                  .where((element) => element.name.isNotEmpty == true)
                  .toList(),
              filterItems:
                  selectedFilters.expand((element) => element.filters).toList(),
              filterBuilder: widget.filterSections?.isNotEmpty == true
                  ? filterWidget
                  : null,
              onChangeDateFilter: widget.onChangeDateFilter,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: CustomDataTable<T>(
            onSort: widget.onSort,
            toMap: widget.toMap,
            data: widget.data,
            cell: widget.cell,
            columns: widget.columns,
            onPrint: widget.onPrint,
            onExport: widget.onExport,
            onCopy: widget.onCopy,
            onElementPressed: widget.onElementPressed,
            title: widget.title,
            onPreviousPage: widget.onPreviousPage,
            onNextPage: widget.onNextPage,
            onSelectedPage: widget.onSelectedPage,
            paginatorInfo: widget.paginatorInfo,
            onChangeSearchTextField: widget.onChangeSearchTextField,
          ),
        ),
      ],
    );
  }

  Widget filterWidget(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final FilterSection section in widget.filterSections ?? [])
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: ValueListenableBuilder<Map<String, List<FilterItem>>>(
                    valueListenable: selectedFiltersMap,
                    builder: (context, value, child) {
                      return FilterSectionWidget(
                        section: section,
                        selectedFilters: value[section.columnInfo.key],
                        onChange: (values) {
                          value[section.columnInfo.key] = [...values];

                          selectedFiltersMap.value = {...value};

                          widget.onChangeFilters?.call(selectedFilters
                              .expand((element) => element.filters)
                              .toList());
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
