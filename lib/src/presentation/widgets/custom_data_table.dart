import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/utils/debounce.dart';
import 'package:custom_data_table/src/core/utils/string_extension.dart';
import 'package:custom_data_table/src/presentation/widgets/common/select_filters_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

/// A widget that displays a table of data.
///
/// The table theme can be customized using [DataTableTheme].
class CustomDataTable<T> extends StatefulWidget {
  /// Controller to control the table.
  final TableController? controller;

  /// List of columns the table has.
  ///
  /// Each element of the list contains the name of the column, key to identify
  /// it, and the information of the space that is taking (width).
  final List<ColumnInfo> columns;

  /// Data to show in the table.
  final List<T>? data;

  /// Function to convert the row of type Object to Map.
  ///
  /// The map entry key has to match with the key of any column contained in
  /// [columns]. In this way, the table is going to show the value of the entry
  /// in the correct cell.
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

  /// Builder that allows to put another widget as parent of a row.
  ///
  /// Example. To put a gesture detector in row.
  final Widget Function(T element, Widget widget)? rowBuilder;

  /// Callback to notify when a column has pressed to sort by this column.
  ///
  /// [sortInfo] contains the information that tell which column has marked to
  /// be sorted, and if te order is ascendant or descendant.
  final Function(SortInfo sortInfo)? onSort;

  /// Information of pagination.
  ///
  /// It contains for example the page that is displayed, the number of total
  /// pages, elements per page.
  final PaginatorInfo? paginatorInfo;

  /// Callback that notifies when the previous page button is pressed.
  final VoidCallback? onPreviousPage;

  /// Callback that notifies when the next page button is pressed.
  final VoidCallback? onNextPage;

  /// Callback that notifies when the selected page has changed.
  final Function(int page)? onSelectedPage;

  /// Callback that notifies when the number of elements per page has changed.
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

  /// Information of current sort options.
  final SortInfo? sortInfo;

  /// Whether the table is loading.
  ///
  /// If true, it shows a loading indicator.
  final bool isLoading;

  /// Callback that notifies when the general search field has changed.
  final ValueChanged<String>? onChangeGeneralSearch;

  /// Sections of the filters.
  ///
  /// Each element contains the name and id of the column, list of filter
  /// parameters, and the selected filters.
  final List<FilterSection>? filterSections;

  /// Callback that notifies when new filters in search widget are selected.
  ///
  /// If user selects new filters, or deselects filters the Callback is notified.
  final Function(List<FilterSection> sections)? onChangeFilters;

  /// Initial date filter.
  final DateSelection? initialDateFilter;

  /// First date of the date range.
  final DateTime? firstDate;

  /// Last date of the date range.
  final DateTime? lastDate;

  /// Callback that notifies when the date filter has changed.
  final ChangeDateCallback? onChangeDateFilter;

  /// Controller for the general search field.
  final TextEditingController? generalSearchController;

  /// Wether the copy button is displayed.
  final bool canCopy;

  /// Builder to display an exception.
  ///
  /// If not provided, it shows a default exception builder.
  final Widget Function()? exceptionBuilder;

  /// Builder to display a loading indicator.
  ///
  /// If not provided, it shows a [CircularProgressIndicator].
  final Widget Function()? loadingBuilder;

  const CustomDataTable({
    Key? key,
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
  }) : super(key: key);

  @override
  State<CustomDataTable<T>> createState() => _CustomDataTableState<T>();
}

class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
  List<ColumnInfo> get columns => widget.columns;

  /// Information of current sort options.
  SortInfo? sortInfo;

  /// Columns selected to show in the table.
  late Set<String> selectedColumns;

  /// Columns to show in the table.
  List<ColumnInfo> get columnsToShow => columns
      .where(
        (element) => selectedColumns.contains(element.key),
      )
      .toList();

  /// Scroll controllers to control the vertical scroll of the table.
  final ScrollController _verticalScrollController = ScrollController();

  /// Scroll controllers to control the horizontal scroll of the table.
  ///
  /// It is used to link the horizontal scroll of the content and the columns
  /// header.
  final LinkedScrollControllerGroup _controllers =
      LinkedScrollControllerGroup();

  /// Scroll controller to control the horizontal scroll of the content.
  late ScrollController _hContentScrollController;

  /// Scroll controller to control the horizontal scroll of the columns header.
  late ScrollController _columnsHeaderController;

  /// Controllers for the text fields of the columns.
  ///
  /// It is used to control the text fields of the columns.
  late Map<String, TextEditingController> textControllers;

  /// List of controllers for the text fields declared in the widget.
  ///
  /// It is used to dispose the controllers when the widget is disposed.
  final List<TextEditingController> insideControllers = [];

  /// Debouncer to debounce the search fields.
  final debouncer = Debouncer(milliseconds: 500);

  /// Debouncer to debounce the column search fields.
  final debouncerIndividual = Debouncer(milliseconds: 500);

  /// Notifies when the content height changes.
  final contentHeight = ValueNotifier<double?>(null);

  /// Minimum height of a row.
  double get rowMinHeight => context.readDataTableTheme?.dataRowHeight ?? 38;

  /// Initial date filter.
  DateSelection? dateFilter;

  /// Controller for the general search field.
  TextEditingController? _newGeneralSearchController;

  /// Controller for the general search field.
  late TextEditingController _generalSearchController;

  /// Boolean to know if the table is searching.
  bool searching = false;

  /// Scroll controller to show Scrollbar.
  final _headerScroll = ScrollController();

  @override
  void initState() {
    widget.controller?.clearColumnSearchFields = _clearColumnSearchFields;

    // Initialize scroll controllers.
    _hContentScrollController = _controllers.addAndGet();
    _columnsHeaderController = _controllers.addAndGet();

    final columns = widget.columns;

    // Initialize text controllers.
    textControllers = {
      for (final col in columns) col.key: createTextController(col),
    };

    // Initialize selected columns. All columns are selected by default.
    selectedColumns = {for (final c in columns) c.key};

    // Initialize sort info.
    sortInfo = widget.sortInfo;

    // Initialize date filter.
    dateFilter = widget.initialDateFilter;

    // Initialize general search controller.
    final generalSearchController = widget.generalSearchController;

    // Initialize general search controller.
    // If a controller is provided, it is used. Otherwise, a new controller is
    // created.
    if (generalSearchController != null) {
      _generalSearchController = generalSearchController;
    } else {
      final textController = TextEditingController();

      _newGeneralSearchController = textController;
      _generalSearchController = textController;
    }

    super.initState();
  }

  /// Clears the text of all column search fields.
  void _clearColumnSearchFields() {
    for (final textController in textControllers.entries) {
      try {
        textController.value.clear();
      } catch (_) {}
    }
  }

  /// Creates a text controller for a column.
  TextEditingController createTextController(ColumnInfo column) {
    var newController = column.controllerInput;

    if (newController == null) {
      newController = TextEditingController();
      // Add the new controller to the list of inside controllers.
      insideControllers.add(newController);
    }

    if (column.initialSearchValue != null) {
      newController.text = column.initialSearchValue!;
    }

    return newController;
  }

  @override
  void dispose() {
    // Dispose text controllers.
    for (final textController in insideControllers) {
      try {
        textController.dispose();
      } catch (_) {}
    }

    // Dispose general search controller.
    _newGeneralSearchController?.dispose();

    // Dispose scroll controllers.
    _hContentScrollController.dispose();
    _verticalScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataTableTheme = context.watchDataTableTheme;

    final tableBorderRadius =
        (dataTableTheme?.tableDecoration)?.borderRadius ?? BorderRadius.zero;

    final dividerHeight = dataTableTheme?.dividerHeight;

    final data = widget.data;

    if (data != null) {
      contentHeight.value = data.isEmpty
          ? 0
          : (rowMinHeight * data.length +
              ((dividerHeight ?? 0) * (data.length - 1)));
    }

    return Container(
      margin: dataTableTheme?.tableMargin,
      child: Stack(
        // ClipBehavior.none is used to avoid the table to be cut in negative
        // positions.
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: dataTableTheme?.tableDecoration,
            child: ClipRRect(
              borderRadius: tableBorderRadius,
              child: _body(),
            ),
          ),
          // Positioned loading indicator.
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
      ),
    );
  }

  /// Returns the body of the table.
  Widget _body() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return tableWidget(constraints);
      },
    );
  }

  /// Returns the table widget.
  ///
  /// This widget is used to display the table.
  /// [constraints] are the constraints of the table.
  Widget tableWidget(BoxConstraints constraints) {
    final dataTableTheme = context.watchDataTableTheme;

    final rowPadding = dataTableTheme?.rowPadding;

    final minWidth = widget.columns
            .map((e) => e.width)
            .reduce((value, element) => value + element) +
        (rowPadding?.right ?? 0) +
        (rowPadding?.left ?? 0);

    // BoxConstraints for the table.
    final tableConstraints = BoxConstraints(
      minWidth: minWidth,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header of the table.
        header(),
        // Builder to handle the columns widget.
        Builder(
          builder: (context) {
            // If the width of the table is greater than the minimum width,
            //the columns widget is displayed without scrolling.
            if (constraints.maxWidth > minWidth) {
              return columnsWidget(false);
            }

            // If the width of the table is less than the minimum width,
            //the columns widget is displayed with scrolling.
            return SingleChildScrollView(
              controller: _columnsHeaderController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableConstraints.minWidth,
                child: columnsWidget(true),
              ),
            );
          },
        ),
        // Flexible to handle the content of the table.
        Flexible(
          child: ValueListenableBuilder(
            valueListenable: contentHeight,
            builder: (context, contentHeight, child) {
              final data = widget.data;
              final paginator = widget.paginatorInfo;

              final error =
                  (data == null || paginator == null) && !widget.isLoading;

              return Container(
                constraints: contentHeight == null || error
                    ? null
                    : BoxConstraints(
                        maxHeight: contentHeight + 10,
                      ),
                child: Builder(
                  builder: (context) {
                    final data = widget.data;
                    final paginator = widget.paginatorInfo;

                    // If the data or paginator is null, the loading or exception
                    // builder is displayed.
                    if (data == null || paginator == null) {
                      // If the data or paginator is null and the table is
                      // loading, the loading builder is displayed.
                      if (widget.isLoading) {
                        return widget.loadingBuilder?.call() ??
                            const CircularProgressIndicator();
                      } else {
                        return widget.exceptionBuilder?.call() ??
                            const SizedBox();
                      }
                    }

                    // If the width of the table is greater than the minimum
                    // width, the table content is displayed without scrolling.
                    if (constraints.maxWidth > minWidth) {
                      return Scrollbar(
                        controller: _verticalScrollController,
                        thumbVisibility: true,
                        child: Container(
                          constraints: tableConstraints,
                          child: tableContent(
                            data: data,
                            scrollable: false,
                          ),
                        ),
                      );
                    }

                    // If the width of the table is less than the minimum width,
                    // the table content is displayed with scrolling.
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
                              child: tableContent(
                                scrollable: true,
                                data: data,
                              ),
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
        // Footer of the table.
        footer(),
      ],
    );
  }

  /// Widget to show table header.
  ///
  /// It shows a dropdown of columns to show, and actions to copy, export
  /// and print data, as well as the filters of data.
  ///
  /// The columns to show dropdown only shows the columns that have name. If a column
  /// does not have name, it cannot be hidden.
  Widget header() {
    final theme = context.watchDataTableTheme;

    final headerDecoration = theme?.headerDecoration;

    final padding = theme?.headerPadding;

    final filters = widget.filterSections;

    final showExportButton = widget.onExport != null ||
        widget.onPrint != null ||
        widget.onCopy != null;

    final data = widget.data;

    return Container(
      padding: padding?.copyWith(right: 0, left: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 45,
            decoration: headerDecoration,
            child: Row(
              children: [
                // Columns to show dropdown.
                Container(
                  padding: padding == null
                      ? null
                      : EdgeInsets.only(left: padding.left),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () async {
                        final newSelectedColumns = await showDialog(
                          context: context,
                          builder: (context) => SelectColumnsToShowDialog(
                            columns: columns,
                            selectedColumns: columnsToShow,
                          ),
                        );

                        if (newSelectedColumns is List<ColumnInfo>) {
                          selectedColumns = {
                            for (final c in newSelectedColumns) c.key,
                          };
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
                              context
                                  .appLocalizations.columns.naturalCapitalized,
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
                ),

                // Filters and search bar.
                Expanded(
                  child: Scrollbar(
                    controller: _headerScroll,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _headerScroll,
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      padding: padding?.copyWith(top: 0, bottom: 0),
                      child: Row(
                        children: [
                          // Filters button.
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

                          // Date filter button.
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

                          // Copy button.
                          if ((widget.onCopy != null || widget.canCopy) &&
                              data != null &&
                              data.isNotEmpty)
                            IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: widget.onCopy ??
                                  () async {
                                    // Columns to show. Only this columns are copied.
                                    final columnsToShow = this.columnsToShow;

                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);

                                    // Copy value.
                                    // First row is the column names.
                                    // Then each row is a row of data.
                                    // Each column is separated by a tab.
                                    // Each row is separated by a newline.
                                    final copyValue = [
                                      [
                                        for (final column in columnsToShow)
                                          column.name,
                                      ].join('\t'),
                                      for (final element in data)
                                        [
                                          for (final column in columnsToShow)
                                            '${widget.toMap(element)[column.key] ?? ''}'
                                                .replaceAll('\n', ' '),
                                        ].join('\t'),
                                    ].join('\n');

                                    // Copy to clipboard.
                                    await Clipboard.setData(
                                        ClipboardData(text: copyValue));

                                    scaffoldMessenger.showSnackBar(
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

                          // Export button.
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
                              builder: (context, controller, child) =>
                                  FilledButton.icon(
                                label: Text(context.appLocalizations.export
                                    .naturalCapitalized),
                                onPressed: () => controller.open(),
                                icon: const Icon(
                                  Icons.ios_share_outlined,
                                  size: 15,
                                ),
                              ),
                            ),

                          // Search bar.
                          // Only show if searching is true.
                          // Debouncer is used to prevent the search from being called too often.
                          // searching is true when the user presses the search icon.
                          if (searching)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: SizedBox(
                                width: 250,
                                child: TextField(
                                  controller: _generalSearchController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: context.appLocalizations.search
                                        .naturalCapitalized,
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
                                    () => widget.onChangeGeneralSearch
                                        ?.call(value),
                                  ),
                                ),
                              ),
                            )
                          else if (widget.onChangeGeneralSearch != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
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
                ),
              ],
            ),
          ),

          // Selected filters.
          if (filters != null || dateFilter != null)
            Container(
              padding: padding?.copyWith(top: 0, bottom: 0),
              child: SelectedFiltersWidget(
                selectedFilters: filters,
                dateFilter: dateFilter,
                onChange: widget.onChangeFilters,
                onDateFilterClear: () {
                  dateFilter = null;
                  setState(() {});

                  widget.onChangeDateFilter?.call(null);
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Show the filters dialog.
  ///
  /// [filters] are the filters to show in the dialog.
  ///
  /// Notifies [widget.onChangeFilters] when the filters are changed.
  /// If the dialog is closed without saving, the filters will not be changed.
  void showFilters(List<FilterSection> filters) async {
    final newFilters = await showDialog(
      context: context,
      builder: (context) => SelectFiltersDialog(
        filters: filters,
      ),
    );

    // If the dialog is closed without saving, the filters will not be changed.
    if (newFilters is! List<FilterSection>) {
      return;
    }

    // Notifies [widget.onChangeFilters] when the filters are changed.
    widget.onChangeFilters?.call(newFilters);
  }

  /// Show the date filters dialog.
  ///
  /// Notifies [widget.onChangeDateFilter] when the date filter is changed.
  void showDateFilters() async {
    final customDateFilters = await showCustomDateFilters(
      context,
      initialDateFilter: dateFilter,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    // Notifies when the date filter is changed.
    widget.onChangeDateFilter?.call(customDateFilters);

    dateFilter = customDateFilters;
    setState(() {});
  }

  /// Build the table content.
  ///
  /// [data] is the data to show in the table.
  /// [scrollable] is whether the table should be scrollable.
  Widget tableContent({required data, required bool scrollable}) {
    final dataTableTheme = context.watchDataTableTheme;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: DividerTheme(
        data: dataTableTheme?.dividerThemeData ?? const DividerThemeData(),
        child: ListView.separated(
          controller: _verticalScrollController,
          itemCount: data.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) =>
              rowWidget(data[index], index, scrollable),
        ),
      ),
    );
  }

  /// Build a row widget.
  ///
  /// [element] is the element to show in the row.
  /// [index] is the index of the row.
  /// [scrollable] is whether the row should be scrollable.
  Widget rowWidget(T element, int index, bool scrollable) {
    final dataTableTheme = context.watchDataTableTheme;

    final columnsToShow = this.columnsToShow;

    // Whether any column has a flex. If there is no flex, all columns will have
    // flex of its width.
    final anyFlex = columnsToShow.any((element) => element.flex != null);

    final child = Container(
      decoration: index.isEven
          ? dataTableTheme?.evenRowTheme?.decoration
          : dataTableTheme?.oddRowTheme?.decoration,
      padding: dataTableTheme?.rowPadding,
      height: rowMinHeight,
      child: Row(
        children: [
          for (final col in columnsToShow)
            Builder(
              builder: (context) {
                final width = col.width;
                final flex = anyFlex ? col.flex : width.toInt();

                // If the row is scrollable, or the column has no flex, or the
                // column has a fixed width, it will have a fixed width with the
                // specified width.
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

    // If a row builder is specified, it will be used to build the row.
    final rowBuilder = widget.rowBuilder;

    if (rowBuilder != null) {
      return rowBuilder(element, child);
    }

    return child;
  }

  /// Widget that creates all columns titles.
  ///
  /// Creates all columns that are specified in [columns]. Each element of the list
  /// contains the information of how much horizontal space it has to take.
  /// If flex is specified, creates an [Expand] widget with that flex. In the other
  /// hand, if only width is specified, it creates a [SizedBox] with the size given.
  ///
  /// [scrollable] is whether the table is scrollable.
  Widget columnsWidget(bool scrollable) {
    final dataTableTheme = context.watchDataTableTheme;

    final columnHeaderDecoration = dataTableTheme?.columnHeaderDecoration;

    final verticalPadding = dataTableTheme?.columnHeaderVerticalPadding;
    final horizontalPadding = dataTableTheme?.rowPadding;

    // The padding of the column header. It is the vertical padding of the column
    // header and the horizontal padding of the row.
    final padding = EdgeInsets.only(
      top: verticalPadding?.top ?? 0,
      bottom: verticalPadding?.bottom ?? 0,
      left: horizontalPadding?.left ?? 0,
      right: horizontalPadding?.right ?? 0,
    );

    // The columns to show. It is the list of columns that are specified in
    // [columns] and are not hidden.
    final columnsToShow = this.columnsToShow;

    // Whether any column has a flex. If there is no flex, all columns will have
    // flex of its width.
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

                  // If the table is scrollable, or the column has no flex, or the
                  // column has a fixed width, it will have a fixed width with the
                  // specified width.
                  if (scrollable || flex == null || col.hasFixedWidth == true) {
                    return SizedBox(
                      width: width,
                      child: columnWidget(col),
                    );
                  }

                  // Otherwise, it will have a flex of the specified flex.
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
    final dataTableTheme = context.watchDataTableTheme;

    final columnTitleTextStyle = dataTableTheme?.columnTitleTextStyle;

    return Container(
      width: column.width,
      height: dataTableTheme?.columnHeaderHeight,
      padding: column.canSort ? null : const EdgeInsets.only(right: 5),
      child: Row(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Name of the column.
          Expanded(
            child: Builder(builder: (context) {
              if (column.canSearchInput) {
                return columnFieldWidget(column);
              }

              return Text(
                column.name,
                overflow: TextOverflow.fade,
                style: columnTitleTextStyle,
              );
            }),
          ),

          // Indicates if the column is sorted asc, desc or if it is not sorted.
          if (column.canSort)
            SizedBox(
              width: 30,
              height: 30,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
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
                icon: Icon(
                  column.key != sortInfo?.columnInfo.key
                      ? Icons.unfold_more
                      : sortInfo?.asc == true
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                  size: 15,
                ),
              ),
            )
        ],
      ),
    );
  }

  /// Table footer.
  ///
  /// Displays pages info. Contains buttons to navigate between pages.
  /// If paginator info is `null`, the footer is not displayed.
  Widget footer() {
    final paginatorInfo = widget.paginatorInfo;

    if (paginatorInfo == null) return const SizedBox();

    return TableFooter(
      paginatorInfo: paginatorInfo,
      onNextPage: widget.onNextPage,
      onPerPageChange: widget.onPerPageChange,
      onPreviousPage: widget.onPreviousPage,
      onSelectedPage: widget.onSelectedPage,
    );
  }

  /// Widget that creates the search input for a column.
  ///
  /// [column] is the column to create the search input for.
  Widget columnFieldWidget(ColumnInfo column) {
    if (column.name.isEmpty) return const SizedBox();

    final dataTableTheme = context.watchDataTableTheme;

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: dataTableTheme?.columnSearchInputTheme,
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
    final dataTableTheme = context.watchDataTableTheme;

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
          style: dataTableTheme?.contentTextStyle,
          maxLines: 1,
        ),
      );
    }

    // Display widget specified in child if not null.
    return cellWidget;
  }
}

/// Controller for the table.
class TableController {
  /// Clears the search fields of the table.
  late VoidCallback clearColumnSearchFields;
}

/// Dialog to select columns to show.
class SelectColumnsToShowDialog extends StatefulWidget {
  /// List of columns to show.
  final List<ColumnInfo> columns;

  /// List of selected columns.
  final List<ColumnInfo> selectedColumns;

  const SelectColumnsToShowDialog(
      {super.key, required this.columns, required this.selectedColumns});

  @override
  State<SelectColumnsToShowDialog> createState() =>
      _SelectColumnsToShowDialogState();
}

class _SelectColumnsToShowDialogState extends State<SelectColumnsToShowDialog> {
  /// List of selected columns.
  late List<ColumnInfo> selectedColumns;

  @override
  void initState() {
    // Initializes the selected columns.
    selectedColumns = [...widget.selectedColumns];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // List of columns to show.
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
            // Returns the selected columns.
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
