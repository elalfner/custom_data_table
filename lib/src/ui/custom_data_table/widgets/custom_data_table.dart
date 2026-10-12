import 'package:custom_data_table/src/domain/models/column_info.dart';
import 'package:custom_data_table/src/domain/models/date_selection.dart';
import 'package:custom_data_table/src/domain/models/filter_section.dart';
import 'package:custom_data_table/src/domain/models/paginator_info.dart';
import 'package:custom_data_table/src/domain/models/search_field_info.dart';
import 'package:custom_data_table/src/domain/models/sort_info.dart';
import 'package:custom_data_table/src/ui/core/themes/datatable_theme.dart';
import 'package:custom_data_table/src/ui/core/ui/date_filter/dates_filter_chip.dart';
import 'package:custom_data_table/src/ui/custom_data_table/view_models/table_controller.dart';
import 'package:custom_data_table/src/ui/custom_data_table/widgets/table_columns_header.dart';
import 'package:custom_data_table/src/ui/custom_data_table/widgets/table_content.dart';
import 'package:custom_data_table/src/ui/custom_data_table/widgets/table_footer.dart';
import 'package:custom_data_table/src/ui/custom_data_table/widgets/table_header.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

export '../view_models/table_controller.dart';
export 'select_columns_dialog.dart';
export 'table_column_header.dart';
export 'table_columns_header.dart';
export 'table_content.dart';
export 'table_footer.dart';
export 'table_header.dart';
export 'table_row_widget.dart';

/// A widget that displays a customizable data table.
///
/// Composes [TableHeader], [TableColumnsHeader], [TableContent], and [TableFooter].
class CustomDataTable<T> extends StatefulWidget {
  /// Controller to interact with the table externally.
  final TableController? controller;

  /// Complete list of columns defined for this table.
  final List<ColumnInfo> columns;

  /// Data to display in the table rows. If null, displays loading or exception state.
  final List<T>? data;

  /// Function to convert row elements into map keyed by column key.
  final Map<String, dynamic> Function(T element) toMap;

  /// Function to build custom cells for a row element and column key.
  final Widget? Function(T element, Map<String, dynamic> map, String key)? cell;

  /// Builder to wrap the entire row widget.
  final Widget Function(T element, Widget widget)? rowBuilder;

  /// Callback when a column sort button is toggled.
  final Function(SortInfo sortInfo)? onSort;

  /// Pagination configuration. If null, table renders in unpaginated state.
  final PaginatorInfo? paginatorInfo;

  /// Callback when previous page button is pressed.
  final VoidCallback? onPreviousPage;

  /// Callback when next page button is pressed.
  final VoidCallback? onNextPage;

  /// Callback when a specific page is selected.
  final Function(int page)? onSelectedPage;

  /// Callback when items per page changes.
  final Function(int perPage)? onPerPageChange;

  /// Callback when copy button is pressed.
  final VoidCallback? onCopy;

  /// Callback when print button is pressed.
  final VoidCallback? onPrint;

  /// Callback when export button is pressed.
  final VoidCallback? onExport;

  /// Callback when any column search field changes.
  final Function(List<SearchFieldInfo> values)? onChangeSearchTextField;

  /// Current sorting information.
  final SortInfo? sortInfo;

  /// Whether the table is currently loading data.
  final bool isLoading;

  /// Callback when general search text changes.
  final ValueChanged<String>? onChangeGeneralSearch;

  /// Filter sections configuration.
  final List<FilterSection>? filterSections;

  /// Callback when filter sections change.
  final Function(List<FilterSection> sections)? onChangeFilters;

  /// Initial date filter selection.
  final DateSelection? initialDateFilter;

  /// First date for the date range picker.
  final DateTime? firstDate;

  /// Last date for the date range picker.
  final DateTime? lastDate;

  /// Callback when the date filter changes.
  final ChangeDateCallback? onChangeDateFilter;

  /// Controller for general search field.
  final TextEditingController? generalSearchController;

  /// Whether the copy button is shown.
  final bool canCopy;

  /// Custom builder for error or empty state.
  final Widget Function()? exceptionBuilder;

  /// Custom builder for loading indicator.
  final Widget Function()? loadingBuilder;

  /// Callback when a row is clicked.
  final Function(T element)? onTapRow;

  const CustomDataTable({
    super.key,
    this.controller,
    required this.columns,
    required this.data,
    required this.toMap,
    this.cell,
    this.rowBuilder,
    this.onSort,
    this.paginatorInfo,
    this.onNextPage,
    this.onPreviousPage,
    this.onSelectedPage,
    this.onPerPageChange,
    this.onCopy,
    this.onPrint,
    this.onExport,
    this.onChangeSearchTextField,
    this.sortInfo,
    this.isLoading = false,
    this.onChangeGeneralSearch,
    this.filterSections,
    this.onChangeFilters,
    this.initialDateFilter,
    this.firstDate,
    this.lastDate,
    this.onChangeDateFilter,
    this.generalSearchController,
    this.canCopy = true,
    this.exceptionBuilder,
    this.loadingBuilder,
    this.onTapRow,
  });

  @override
  State<CustomDataTable<T>> createState() => _CustomDataTableState<T>();
}

class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
  List<ColumnInfo> get columns => widget.columns;

  SortInfo? _sortInfo;
  late Set<String> _selectedColumns;

  List<ColumnInfo> get _columnsToShow => columns
      .where((element) => _selectedColumns.contains(element.key))
      .toList();

  final ScrollController _verticalScrollController = ScrollController();
  final LinkedScrollControllerGroup _linkedControllers =
      LinkedScrollControllerGroup();
  late final ScrollController _hContentScrollController;
  late final ScrollController _columnsHeaderController;

  late Map<String, TextEditingController> _textControllers;
  final List<TextEditingController> _insideControllers = [];

  @override
  void initState() {
    super.initState();
    widget.controller?.clearColumnSearchFields = _clearColumnSearchFields;

    _hContentScrollController = _linkedControllers.addAndGet();
    _columnsHeaderController = _linkedControllers.addAndGet();

    _textControllers = {
      for (final col in columns) col.key: _createTextController(col),
    };

    _selectedColumns = {for (final c in columns) c.key};
    _sortInfo = widget.sortInfo;
  }

  void _clearColumnSearchFields() {
    for (final textController in _textControllers.entries) {
      try {
        textController.value.clear();
      } catch (_) {}
    }
  }

  TextEditingController _createTextController(ColumnInfo column) {
    var newController = column.controllerInput;
    if (newController == null) {
      newController = TextEditingController();
      _insideControllers.add(newController);
    }
    if (column.initialSearchValue != null) {
      newController.text = column.initialSearchValue!;
    }
    return newController;
  }

  @override
  void dispose() {
    for (final textController in _insideControllers) {
      try {
        textController.dispose();
      } catch (_) {}
    }
    _hContentScrollController.dispose();
    _columnsHeaderController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataTableTheme = context.watchDataTableTheme;
    final tableBorderRadius =
        (dataTableTheme?.tableDecoration)?.borderRadius ?? BorderRadius.zero;

    return Container(
      margin: dataTableTheme?.tableMargin,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: dataTableTheme?.tableDecoration,
            child: ClipRRect(
              borderRadius: tableBorderRadius,
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TableHeader<T>(
                      columns: columns,
                      selectedColumns: _columnsToShow,
                      onSelectedColumnsChanged: (newColumns) {
                        setState(() {
                          _selectedColumns = {
                            for (final col in newColumns) col.key,
                          };
                        });
                      },
                      data: widget.data,
                      toMap: widget.toMap,
                      filterSections: widget.filterSections,
                      onChangeFilters: widget.onChangeFilters,
                      initialDateFilter: widget.initialDateFilter,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                      onChangeDateFilter: widget.onChangeDateFilter,
                      onCopy: widget.onCopy,
                      canCopy: widget.canCopy,
                      onPrint: widget.onPrint,
                      onExport: widget.onExport,
                      generalSearchController: widget.generalSearchController,
                      onChangeGeneralSearch: widget.onChangeGeneralSearch,
                    ),
                    TableColumnsHeader(
                      columns: _columnsToShow,
                      scrollController: _columnsHeaderController,
                      sortInfo: _sortInfo,
                      onSort: (newSortInfo) {
                        setState(() {
                          _sortInfo = newSortInfo;
                        });
                        widget.onSort?.call(newSortInfo);
                      },
                      textControllers: _textControllers,
                      onColumnSearchChanged: (column, value) {
                        widget.onChangeSearchTextField?.call(
                          [
                            for (final e in _textControllers.entries)
                              SearchFieldInfo(
                                columnInfo: columns.firstWhere(
                                  (element) => element.key == e.key,
                                ),
                                searchValue: e.value.text,
                              )
                          ],
                        );
                      },
                    ),
                    TableContent<T>(
                      constraints: constraints,
                      columns: _columnsToShow,
                      data: widget.data,
                      toMap: widget.toMap,
                      cell: widget.cell,
                      rowBuilder: widget.rowBuilder,
                      onTapRow: widget.onTapRow,
                      verticalScrollController: _verticalScrollController,
                      horizontalScrollController: _hContentScrollController,
                      isLoading: widget.isLoading,
                      loadingBuilder: widget.loadingBuilder,
                      exceptionBuilder: widget.exceptionBuilder,
                    ),
                    if (widget.paginatorInfo != null)
                      TableFooter(
                        paginatorInfo: widget.paginatorInfo!,
                        onNextPage: widget.onNextPage,
                        onPerPageChange: widget.onPerPageChange,
                        onPreviousPage: widget.onPreviousPage,
                        onSelectedPage: widget.onSelectedPage,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.isLoading)
            Positioned(
              top: -10,
              right: 0,
              left: 0,
              child: Center(
                child: Container(
                  width: 200,
                  constraints: const BoxConstraints(minWidth: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(200),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
