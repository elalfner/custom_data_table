import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/utils/debounce.dart';
import 'package:custom_data_table/src/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class CustomDataTable<T> extends StatefulWidget {
  final TableController? controller;

  /// Theme of the table.
  ///
  /// Attributes given will override main datatable theme declared in the material
  /// theme.
  @Deprecated("Use CustomDatatableTheme widget instead")
  final DataTableThemeData? dataTableTheme;

  /// Title of table.
  ///
  /// if `null` shows `Listado` in the title.
  @Deprecated('Title does not show in the table anymore.')
  final String? title;

  final Widget? titleWidget;

  /// List of columns the table has.
  ///
  /// Each element of the list contains the name of the column, key to identify it, and the
  /// information of the space that is taking (width).
  final List<ColumnInfo> columns;

  /// Data to show in the table.
  final List<T> data;

  /// Function to convert the row of type Object to Map.
  ///
  /// The map entry key has to match with the key of any column contained in [columns].
  /// In this way the table is going to show the value of the entry in the correct cell.
  final Map<String, dynamic> Function(T element) toMap;

  /// Function to get the element that is displaying in this cell.
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

  final SortInfo? sortInfo;

  final bool isLoading;

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

  final bool canCopy;

  const CustomDataTable({
    Key? key,
    this.controller,
    this.title,
    this.titleWidget,
    required this.columns,
    required this.data,
    required this.toMap,
    this.cell,
    this.onElementPressed,
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
    this.dataTableTheme,
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
  }) : super(key: key);

  @override
  State<CustomDataTable<T>> createState() => _CustomDataTableState<T>();
}

class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
  List<ColumnInfo> get columns => widget.columns;

  /// Information of current sort options.
  SortInfo? sortInfo;

  /// Columns selected to show in the table.
  late List<ColumnInfo> selectedColumns;

  /// Scroll controllers to show ScrollBar.
  ///
  final ScrollController _verticalScrollController = ScrollController();
  final LinkedScrollControllerGroup _controllers =
      LinkedScrollControllerGroup();
  late ScrollController _hContentScrollController;
  late ScrollController _columnsHeaderController;

  late Map<String, TextEditingController> textControllers;

  final List<TextEditingController> insideControllers = [];

  final debouncer = Debouncer(milliseconds: 500);
  final debouncerIndividual = Debouncer(milliseconds: 500);

  Size? rowSize;

  final contentHeight = ValueNotifier<double?>(null);

  final _defaultContentPadding = const EdgeInsets.only(right: 10, left: 10);

  late double rowMinHeight;

  DateSelection? dateFilter;

  TextEditingController? _newGeneralSearchController;
  late TextEditingController _generalSearchController;

  @override
  void initState() {
    widget.controller?.clearColumnSearchFields = _clearColumnSearchFields;

    _hContentScrollController = _controllers.addAndGet();
    _columnsHeaderController = _controllers.addAndGet();

    textControllers = {
      for (final col in columns) col.key: createTextController(col),
    };

    sortInfo = widget.sortInfo;

    rowMinHeight = context.dataTableTheme?.dataRowHeight ?? 35;

    selectedColumns = [...columns];

    dateFilter = widget.initialDateFilter;

    final generalSearchController = widget.generalSearchController;

    if (generalSearchController != null) {
      _generalSearchController = generalSearchController;
    } else {
      final textController = TextEditingController();

      _newGeneralSearchController = textController;
      _generalSearchController = textController;
    }

    super.initState();
  }

  void _clearColumnSearchFields() {
    for (final textController in textControllers.entries) {
      try {
        textController.value.clear();
      } catch (_) {}
    }
  }

  TextEditingController createTextController(ColumnInfo column) {
    final controllerInput = column.controllerInput;
    if (controllerInput != null) return controllerInput;

    final newController = TextEditingController();

    insideControllers.add(newController);

    return newController;
  }

  @override
  void dispose() {
    for (final textController in insideControllers) {
      try {
        textController.dispose();
      } catch (_) {}
    }

    // Dispose scroll controllers.
    _hContentScrollController.dispose();
    _verticalScrollController.dispose();

    _newGeneralSearchController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tableBorderRadius =
        (context.dataTableTheme?.tableDecoration)?.borderRadius ??
            BorderRadius.zero;

    final dividerHeight = context.dataTableTheme?.dividerHeight;

    contentHeight.value = widget.data.isEmpty
        ? 0
        : (rowMinHeight * widget.data.length +
            ((dividerHeight ?? 0) * (widget.data.length - 1)));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: context.dataTableTheme?.tableDecoration,
          child: ClipRRect(
            borderRadius: tableBorderRadius,
            child: _body(),
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
                constraints: const BoxConstraints(
                  minWidth: 200,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(200),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _body() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return tableWidget(constraints);
      },
    );
  }

  Widget tableWidget(BoxConstraints constraints) {
    final rowPadding =
        context.dataTableTheme?.rowPadding ?? _defaultContentPadding;

    final minWidth = widget.columns
            .map((e) => e.width)
            .reduce((value, element) => value + element) +
        (rowPadding.right) +
        (rowPadding.left);

    final contentHeight = this.contentHeight;

    final tableConstraints = BoxConstraints(
      minWidth: minWidth,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        header(constraints),
        Builder(
          builder: (context) {
            if (constraints.maxWidth > minWidth) {
              return Container(
                constraints: BoxConstraints(
                  minWidth: minWidth,
                ),
                child: Column(
                  children: [
                    columnsWidget(false),
                    columnSearchFieldsWidget(false),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              controller: _columnsHeaderController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableConstraints.minWidth,
                child: Column(
                  children: [
                    columnsWidget(true),
                    columnSearchFieldsWidget(true),
                  ],
                ),
              ),
            );
          },
        ),
        Flexible(
          child: ValueListenableBuilder(
            valueListenable: contentHeight,
            builder: (context, contentHeight, child) {
              return Container(
                constraints: contentHeight == null
                    ? null
                    : BoxConstraints(
                        maxHeight: contentHeight + 10,
                      ),
                child: Builder(
                  builder: (context) {
                    if (constraints.maxWidth > minWidth) {
                      return Scrollbar(
                        controller: _verticalScrollController,
                        thumbVisibility: true,
                        child: Container(
                          constraints: tableConstraints,
                          child: tableContent(constraints, false),
                        ),
                      );
                    }

                    return Scrollbar(
                      controller: _verticalScrollController,
                      notificationPredicate: (notif) => notif.depth == 1,
                      thumbVisibility: true,
                      child: Scrollbar(
                        controller: _hContentScrollController,
                        thumbVisibility: true,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SingleChildScrollView(
                            controller: _hContentScrollController,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: minWidth,
                              child: tableContent(constraints, true),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        footer(availableWidth: constraints.maxWidth),
      ],
    );
  }

  bool searching = false;

  final _headerScroll = ScrollController();

  /// Widget to show table header.
  ///
  /// It shows table title, dropdown of columns to show, and actions to copy, export
  /// and print data.
  /// [small] tells if the available space to display the table is not large enough. If
  /// that is the case, it displays a different layout to fit the same elements. If [small]
  /// the table title is not shown.
  ///
  /// The columns to show dropdown only shows the columns that have name. If a column
  /// does not have name, it cannot be hidden.
  Widget header(BoxConstraints constraints) {
    final theme = context.dataTableTheme;

    final headerDecoration = theme?.headerDecoration;

    final padding = theme?.titlePadding ??
        const EdgeInsets.symmetric(horizontal: 20, vertical: 15);

    final filters = widget.filterSections;

    final selectedColumns = this.selectedColumns;

    final showExportButton = widget.onExport != null ||
        widget.onPrint != null ||
        widget.onCopy != null;

    return Padding(
      padding: padding.copyWith(right: 0, left: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Scrollbar(
            controller: _headerScroll,
            thumbVisibility: true,
            child: Container(
              margin: padding.copyWith(top: 0, bottom: 0),
              width: double.infinity,
              height: 45,
              decoration: headerDecoration,
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () async {
                        final newSelectedColumns = await showDialog(
                          context: context,
                          builder: (context) {
                            return SelectColumnsToShowDialog(
                              columns: columns,
                              selectedColumns: selectedColumns,
                            );
                          },
                        );

                        if (newSelectedColumns is List<ColumnInfo>) {
                          this.selectedColumns = newSelectedColumns;
                          setState(() {});
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.view_column_outlined,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              selectedColumns.length != columns.length
                                  ? context.appLocalizations.selectedColumns
                                      .naturalCapitalized
                                  : context.appLocalizations.showingAll
                                      .naturalCapitalized,
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _headerScroll,
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        children: [
                          if (filters != null)
                            Badge(
                              isLabelVisible: filters.any(
                                (element) =>
                                    element.selectedFilters?.isNotEmpty == true,
                              ),
                              child: TextButton.icon(
                                style: IconButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                label: Text(context.appLocalizations.filter
                                    .naturalCapitalized),
                                onPressed: () => showFilters(filters),
                                icon: const Icon(
                                  Icons.filter_list,
                                  size: 15,
                                ),
                              ),
                            ),
                          if (widget.onChangeDateFilter != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Badge(
                                isLabelVisible: dateFilter != null,
                                child: TextButton.icon(
                                  style: IconButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  label: Text(context.appLocalizations
                                      .filterDates.naturalCapitalized),
                                  onPressed: () => showDateFilters(),
                                  icon: const Icon(
                                    Icons.date_range,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          if (widget.onCopy != null || widget.canCopy)
                            IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: widget.onCopy ??
                                  () async {
                                    final columnsToShow = selectedColumns;

                                    final copyValue = [
                                      [
                                        for (final column in columnsToShow)
                                          column.name,
                                      ].join('\t'),
                                      for (final element in widget.data)
                                        [
                                          for (final column in columnsToShow)
                                            '${widget.toMap(element)[column.key] ?? ''}'
                                                .replaceAll('\n', ' '),
                                        ].join('\t'),
                                    ].join('\n');

                                    await Clipboard.setData(
                                        ClipboardData(text: copyValue));

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Copiado al portapapeles'),
                                      ),
                                    );
                                  },
                              icon: const Icon(
                                Icons.copy,
                                size: 20,
                              ),
                            ),
                          if (showExportButton)
                            MenuAnchor(
                              menuChildren: [
                                if (widget.onPrint != null)
                                  MenuItemButton(
                                    leadingIcon: const Icon(Icons.print),
                                    onPressed: widget.onPrint,
                                    child: Text(context.appLocalizations.print
                                        .naturalCapitalized),
                                  ),
                              ],
                              builder: (context, controller, child) {
                                return FilledButton.icon(
                                  label: Text(context.appLocalizations.export
                                      .naturalCapitalized),
                                  onPressed: () => controller.open(),
                                  icon: const Icon(
                                    Icons.ios_share_outlined,
                                    size: 15,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (searching)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: SizedBox(
                        width: 250,
                        child: TextField(
                          controller: _generalSearchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: context
                                .appLocalizations.search.naturalCapitalized,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                searching = false;
                                setState(() {});

                                _generalSearchController.clear();

                                widget.onChangeGeneralSearch?.call('');
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 25,
                              ),
                            ),
                          ),
                          onChanged: (value) => debouncer.run(
                            () => widget.onChangeGeneralSearch?.call(value),
                          ),
                        ),
                      ),
                    )
                  else if (widget.onChangeGeneralSearch != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: IconButton(
                        onPressed: () {
                          searching = true;
                          setState(() {});
                        },
                        icon: const Icon(Icons.search),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (filters != null || dateFilter != null)
            SelectedFiltersWidget(
              selectedFilters: filters,
              dateFilters: dateFilter,
              onChange: widget.onChangeFilters,
              onDateFilterClear: () {
                dateFilter = null;
                setState(() {});

                widget.onChangeDateFilter?.call(null);
              },
            ),
        ],
      ),
    );
  }

  void showFilters(List<FilterSection> filters) async {
    final newFilters = await showDialog(
      context: context,
      builder: (context) {
        return SelectFiltersDialog(
          filters: filters,
        );
      },
    );

    if (newFilters is! List<FilterSection>) {
      return;
    }

    widget.onChangeFilters?.call(newFilters);
  }

  void showDateFilters() async {
    final customDateFilters = await showCustomDateFilters(
      context,
      initialDateFilter: dateFilter,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    widget.onChangeDateFilter?.call(customDateFilters);

    dateFilter = customDateFilters;
    setState(() {});
  }

  Widget tableContent(BoxConstraints constraints, bool scrollable) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: DividerTheme(
        data: context.dataTableTheme?.dividerThemeData ??
            const DividerThemeData(),
        child: ListView.separated(
          controller: _verticalScrollController,
          itemCount: widget.data.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            return SizedBox(
              child:
                  rowWidget(constraints, widget.data[index], index, scrollable),
            );
          },
        ),
      ),
    );
  }

  Widget rowWidget(
      BoxConstraints constraints, T element, int index, bool scrollable) {
    final columnsToShow = selectedColumns;

    final anyFlex = columnsToShow.any((element) => element.flex != null);

    return Container(
      decoration: index.isEven
          ? context.dataTableTheme?.evenRowTheme?.decoration
          : context.dataTableTheme?.oddRowTheme?.decoration,
      padding: context.dataTableTheme?.rowPadding ?? _defaultContentPadding,
      height: rowMinHeight,
      child: Row(
        children: [
          for (final col in columnsToShow)
            Builder(
              builder: (context) {
                final width = col.width;
                final flex = anyFlex ? col.flex : width.toInt();

                if (scrollable || flex == null || col.hasFixedWidth == true) {
                  return SizedBox(
                    width: width,
                    child: cell(element, widget.toMap(element), col),
                  );
                }

                return Expanded(
                  flex: flex,
                  child: cell(element, widget.toMap(element), col),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget hideShowColumnsWidget() {
    // Only allow to hide column that have name.
    return PopUpField<ColumnInfo>(
      tooltip: context.appLocalizations.showHideColumns,
      items: widget.columns
          .where((element) => element.name.isNotEmpty == true)
          .map(
            (e) => PopUpMenuItem(key: e.key, name: e.name, value: e),
          )
          .toList(),
      selectedFields: widget.columns
          .where((element) => element.name.isNotEmpty == true)
          .map(
            (e) => PopUpMenuItem(key: e.key, name: e.name, value: e),
          )
          .toList(),
      onChange: (values) {
        // Notify new selected items.
        selectedColumns = values;

        selectedColumns.addAll(
          widget.columns.where((element) => element.name.isEmpty),
        );

        setState(() {});
      },
    );
  }

  /// Widget that creates all columns titles.
  ///
  /// Creates all columns that are specified in [colums]. Each element of the list
  /// contains the information of hoe much horizontal space it has to take.
  /// If flex is specified, creates an [Expand] widget with that flex. In the other hand
  /// if only width is specified, it creates a [SizedBox] with the size given.
  Widget columnsWidget(bool scrollable) {
    final columnHeaderDecoration =
        context.dataTableTheme?.columnHeaderDecoration;
    final padding =
        context.dataTableTheme?.columnHeaderPadding ?? _defaultContentPadding;

    final columnsToShow = selectedColumns;

    final anyFlex = columnsToShow.any((element) => element.flex != null);

    return Container(
      decoration: columnHeaderDecoration,
      padding: padding,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final col in columnsToShow)
              Builder(
                builder: (context) {
                  final width = col.width;
                  final flex = anyFlex ? col.flex : width.toInt();

                  if (scrollable || flex == null || col.hasFixedWidth == true) {
                    return SizedBox(
                      width: width,
                      child: columnWidget(col),
                    );
                  }

                  return Expanded(
                    flex: flex,
                    child: columnWidget(col),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Widget that creates one single column title.
  ///
  /// Creates a title with the name of the column. Also, it creates the button to
  /// sort all data of the table by this column. The information of the column is contained in
  /// [column].
  Widget columnWidget(ColumnInfo column) {
    final columnTitleTextStyle = context.dataTableTheme?.columnTitleTextStyle;

    return Row(
      children: [
        Flexible(
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: !column.canSort
                  ? null
                  : () {
                      // Changes the state of sort.
                      // If there is no column marked as sort, this column is marked as
                      // sorting ascendant.

                      if (sortInfo?.columnInfo.key != column.key) {
                        sortInfo = SortInfo(columnInfo: column, asc: true);
                      } else {
                        sortInfo!.asc = !sortInfo!.asc;
                      }

                      widget.onSort?.call(sortInfo!);

                      setState(() {});
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name of the column.
                  Flexible(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        column.name,
                        overflow: TextOverflow.fade,
                        style: columnTitleTextStyle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),

                  // Indicates if the column is sorted asc, desc or if it is not sorted.
                  if (column.key == sortInfo?.columnInfo.key)
                    Icon(
                      sortInfo?.asc == true
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_up_rounded,
                      size: 15,
                    )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Table footer.
  ///
  /// Displays pages info. Contains buttons to navigate between pages.
  /// If paginator info is `null`, the footer is not displayed.
  Widget footer({required double availableWidth}) {
    final paginatorInfo = widget.paginatorInfo;

    if (paginatorInfo == null) return const SizedBox();

    return TableFooter(
      paginatorInfo: paginatorInfo,
      availableWidth: availableWidth,
      onNextPage: widget.onNextPage,
      onPerPageChange: widget.onPerPageChange,
      onPreviousPage: widget.onPreviousPage,
      onSelectedPage: widget.onSelectedPage,
    );
  }

  Widget columnSearchFieldsWidget(bool scrollable) {
    final columnSearchDecoration =
        context.dataTableTheme?.columnSearchDecoration ??
            BoxDecoration(
              color: Theme.of(context).cardColor,
            );

    final columnsToShow = selectedColumns;

    final anyFlex = columnsToShow.any((element) => element.flex != null);

    return Container(
      decoration: columnSearchDecoration,
      padding:
          context.dataTableTheme?.columnSearchPadding ?? _defaultContentPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final col in columnsToShow)
            Builder(
              builder: (context) {
                final width = col.width;
                final flex = anyFlex ? col.flex : width.toInt();

                if (scrollable || flex == null || col.hasFixedWidth == true) {
                  return SizedBox(
                    width: width,
                    child: columnFieldWidget(col),
                  );
                }

                return Expanded(
                  flex: flex,
                  child: columnFieldWidget(col),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget columnFieldWidget(ColumnInfo column) {
    if (column.name.isEmpty || !column.canSearchInput) return const SizedBox();

    final theme = context.dataTableTheme;

    return Container(
      height: 40,
      padding: const EdgeInsets.only(right: 3),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: theme?.columnSearchInputTheme ??
              const InputDecorationTheme(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                hintStyle: TextStyle(
                  fontSize: 13,
                ),
              ),
        ),
        child: TextFormField(
          controller: textControllers[column.key],
          decoration: InputDecoration(
            hintText: column.name,
          ),
          style: const TextStyle(
            fontSize: 13,
          ),
          onChanged: (value) => debouncerIndividual.run(
            () {
              column.onChangeInput?.call(value);

              widget.onChangeSearchTextField?.call(
                [
                  for (final e in textControllers.entries)
                    SearchFieldInfo(
                      columnInfo:
                          columns.firstWhere((element) => element.key == e.key),
                      searchValue: e.value.text,
                    )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Single cell to show row field.
  ///
  /// As it is displaying a table, the cell data is determined by column id and
  /// row element.
  ///
  /// [element] object that represents the row.
  /// [map] is the [element] converted to map.
  /// [columnInfo] contains the column id, it allows us to know which attribute is
  /// displaying in the cell.
  Widget cell(T element, Map<String, dynamic> map, ColumnInfo column) {
    // Calls the function to get cell data.
    final cellWidget = widget.cell?.call(element, map, column.key);

    // If data is not specified or child is not given, the cell is displaying the
    // text contained in the map by the column id.
    if (cellWidget == null) {
      final cellText = '${map[column.key] ?? ''}'.replaceAll('\n', ' ');

      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          cellText,
          style: context.dataTableTheme?.contentTextStyle,
          maxLines: 1,
        ),
      );
    }

    // Display widget specified in child if not null.
    return cellWidget;
  }
}

class ScrollWidget extends StatelessWidget {
  final double? minWidth;
  final double width;

  final Widget child;

  final ScrollController? scrollController;

  const ScrollWidget(
      {Key? key,
      required this.minWidth,
      required this.width,
      required this.child,
      this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minWidth = this.minWidth;

    if (minWidth == null || minWidth < width) return child;

    return MediaQuery(
      data: MediaQuery.of(context).removePadding(
        removeBottom: true,
        removeTop: true,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            // The table width is the value calculated.
            width: minWidth,
            child: child,
          ),
        ),
      ),
    );
  }
}

class ScrollWidgetWithBar extends StatelessWidget {
  final double? minWidth;
  final double width;

  final Widget child;

  final ScrollController? hScrollController;
  final ScrollController? vScrollController;

  const ScrollWidgetWithBar({
    Key? key,
    required this.minWidth,
    required this.width,
    required this.child,
    this.hScrollController,
    this.vScrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minWidth = this.minWidth;

    if (minWidth == null || minWidth < width) {
      return Scrollbar(
        scrollbarOrientation: ScrollbarOrientation.right,
        controller: vScrollController,
        thumbVisibility: true,
        child: child,
      );
    }

    return MediaQuery(
      data: MediaQuery.of(context).removePadding(
        removeBottom: true,
        removeTop: true,
      ),
      child: SafeArea(
        child: Scrollbar(
          scrollbarOrientation: ScrollbarOrientation.right,
          controller: vScrollController,
          thumbVisibility: true,
          notificationPredicate: (notif) => notif.depth == 1,
          child: Scrollbar(
            controller: hScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: hScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                // The table width is the value calculated.
                width: minWidth,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TableController {
  late VoidCallback clearColumnSearchFields;
}

class SelectColumnsToShowDialog extends StatefulWidget {
  final List<ColumnInfo> columns;
  final List<ColumnInfo> selectedColumns;

  const SelectColumnsToShowDialog(
      {super.key, required this.columns, required this.selectedColumns});

  @override
  State<SelectColumnsToShowDialog> createState() =>
      _SelectColumnsToShowDialogState();
}

class _SelectColumnsToShowDialogState extends State<SelectColumnsToShowDialog> {
  late List<ColumnInfo> selectedColumns;

  @override
  void initState() {
    selectedColumns = [...widget.selectedColumns];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final columns = widget.columns;

    return AlertDialog(
      title: Text(
        context.appLocalizations.columnsToShow.naturalCapitalized,
      ),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final col in columns)
            if (col.name.isNotEmpty)
              CheckboxListTile(
                value: selectedColumns.any((element) => element.key == col.key),
                onChanged: (value) {
                  selectedColumns
                      .removeWhere((element) => element.key == col.key);

                  if (value == true) {
                    selectedColumns.add(col);
                  }

                  setState(() {});
                },
                title: Text(col.name),
              ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            final selectedColumns = widget.columns.where(
              (element) {
                return this.selectedColumns.any(
                      (e) => element.key == e.key,
                    );
              },
            ).toList();

            Navigator.of(context).pop(selectedColumns);
          },
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
