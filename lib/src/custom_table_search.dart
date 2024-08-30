import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/src/widgets/dates_filter_chip.dart';
import 'package:flutter/material.dart';

import 'models/sort_info.dart';

@Deprecated('Use CustomDataTable instead')
class CustomTableSearch<T> extends StatefulWidget {
  final TableController? controller;

  /// Theme of the table.
  ///
  /// Attributes given will override main datatable theme declared in the material
  /// theme.
  final DataTableThemeData? dataTableTheme;

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

  /// Builder that allows to put another widget as parent of a row.
  ///
  /// Example. To put a gesture detector in row.
  final Widget Function(T element, Widget widget)? rowBuilder;

  /// Callback to notify when a column has pressed to sort by this column.
  ///
  /// [sortInfo] contains the information that tell which column has marked to be
  /// sorted, and if te order is ascendant or descendant.
  final Function(SortInfo sortInfo)? onSort;

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

  final Function(int perPage)? onPerPageChange;

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
  final Function(List<ColumnId> values)? onChangeSearchFilter;

  final ValueChanged<String>? onChangeGeneralSearch;

  /// Sections of the filters.
  ///
  /// Each element contains the name and id of the column, and list of filter parameters.
  final List<FilterSection>? filterSections;

  /// Callback that notifies when new filters in search widget are selected.
  ///
  /// If user selects new filters, or deselects filters the Callback is notified.
  final Function(List<FilterSection> sections)? onChangeFilters;

  final DateSelection? initialDateFilter;

  final DateTime? firstDate;
  final DateTime? lastDate;

  final ChangeDateCallback? onChangeDateFilter;

  final TextEditingController? generalSearchController;

  final InputDecoration? generalSearchDecoration;

  final SortInfo? sortInfo;

  final bool isLoading;

  const CustomTableSearch({
    Key? key,
    this.controller,
    this.title,
    required this.columns,
    required this.data,
    required this.toMap,
    this.onSort,
    this.cell,
    this.onChangeSearchFilter,
    this.filterSections,
    this.onChangeFilters,
    this.onElementPressed,
    this.rowBuilder,
    this.paginatorInfo,
    this.onPreviousPage,
    this.onNextPage,
    this.onSelectedPage,
    this.onPerPageChange,
    this.onCopy,
    this.onPrint,
    this.onExport,
    this.onChangeSearchTextField,
    this.onChangeGeneralSearch,
    this.dataTableTheme,
    this.generalSearchController,
    this.generalSearchDecoration,
    this.initialDateFilter,
    this.firstDate,
    this.lastDate,
    this.onChangeDateFilter,
    this.sortInfo,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CustomTableSearch<T>> createState() => _CustomTableSearchState<T>();
}

class _CustomTableSearchState<T> extends State<CustomTableSearch<T>> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SizedBox to tell the widget to take all available width.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 10),
          child: SearchWidget(
            onChangeSearchFilter:
                widget.onChangeSearchFilter ?? (List<ColumnId> values) {},
            columns: widget.columns
                .map((e) =>
                    ColumnId(name: e.name, key: e.key, canSearch: e.canSearch))
                .where((element) => element.name.isNotEmpty == true)
                .toList(),
            filterSections: widget.filterSections,
            onChangeFilters: widget.onChangeFilters,
            initialDateFilter: widget.initialDateFilter,
            lastDate: widget.lastDate,
            firstDate: widget.firstDate,
            onChangeDateFilter: widget.onChangeDateFilter,
            onChangeGeneralSearch: widget.onChangeGeneralSearch,
            generalSearchController: widget.generalSearchController,
            decoration: widget.generalSearchDecoration,
          ),
        ),
        Flexible(
          child: CustomDataTable<T>(
            controller: widget.controller,
            onSort: widget.onSort,
            toMap: widget.toMap,
            data: widget.data,
            cell: widget.cell,
            columns: widget.columns,
            onPrint: widget.onPrint,
            onExport: widget.onExport,
            onCopy: widget.onCopy,
            onElementPressed: widget.onElementPressed,
            rowBuilder: widget.rowBuilder,
            title: widget.title,
            onPreviousPage: widget.onPreviousPage,
            onNextPage: widget.onNextPage,
            onSelectedPage: widget.onSelectedPage,
            onPerPageChange: widget.onPerPageChange,
            paginatorInfo: widget.paginatorInfo,
            onChangeSearchTextField: widget.onChangeSearchTextField,
            dataTableTheme: widget.dataTableTheme,
            sortInfo: widget.sortInfo,
            isLoading: widget.isLoading,
            initialDateFilter: widget.initialDateFilter,
          ),
        ),
      ],
    );
  }
}
