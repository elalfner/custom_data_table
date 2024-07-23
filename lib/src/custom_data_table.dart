import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/utils/debounce.dart';
import 'package:custom_data_table/src/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'package:collection/collection.dart';

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
  }) : super(key: key);

  @override
  State<CustomDataTable<T>> createState() => _CustomDataTableState<T>();
}

class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
  List<ColumnInfo> get columns => widget.columns;

  /// Information of current sort options.
  SortInfo? sortInfo;

  /// Columns selected to show in the table.
  List<ColumnInfo>? columnsSelected;

  /// Gets the columns that have to be displayed in the table.
  ///
  /// If there is no column selected it has to display all columns.
  List<ColumnInfo> get columnsToShow => columnsSelected ?? columns;

  /// Scroll controllers to show ScrollBar.
  late ScrollController _horizontalScrollController;
  late ScrollController _columnsHeaderController;
  late ScrollController _columnsFooterController;
  final ScrollController _verticalScrollController = ScrollController();
  late LinkedScrollControllerGroup _controllers;

  late Map<String, TextEditingController> textControllers;

  final List<TextEditingController> insideControllers = [];

  double get tableMinWidth {
    // Table breakpoint to begin to scroll.
    double tableWidth = 0;

    final columns = columnsToShow;

    // Sum all widths.
    for (final column in columns) {
      tableWidth += column.width;
    }

    return tableWidth;
  }

  DataTableThemeData get dataTableTheme {
    final decoration =
        Theme.of(context).dataTableTheme.decoration as BoxDecoration?;
    final newDecoration = widget.dataTableTheme?.decoration as BoxDecoration?;

    return Theme.of(context).dataTableTheme.copyWith(
          dividerThickness: widget.dataTableTheme?.dividerThickness,
          dataRowColor: widget.dataTableTheme?.dataRowColor,
          decoration: BoxDecoration(
            color: newDecoration?.color ?? decoration?.color,
            borderRadius:
                newDecoration?.borderRadius ?? decoration?.borderRadius,
            shape:
                newDecoration?.shape ?? decoration?.shape ?? BoxShape.rectangle,
            boxShadow: newDecoration?.boxShadow ?? decoration?.boxShadow,
            border: newDecoration?.border ?? decoration?.border,
            backgroundBlendMode: newDecoration?.backgroundBlendMode ??
                decoration?.backgroundBlendMode,
            gradient: newDecoration?.gradient ?? decoration?.gradient,
            image: newDecoration?.image ?? decoration?.image,
          ),
          dataTextStyle: widget.dataTableTheme?.dataTextStyle,
          headingTextStyle: widget.dataTableTheme?.headingTextStyle,
          checkboxHorizontalMargin:
              widget.dataTableTheme?.checkboxHorizontalMargin,
          columnSpacing: widget.dataTableTheme?.columnSpacing,
          dataRowMinHeight: widget.dataTableTheme?.dataRowMinHeight,
          headingRowColor: widget.dataTableTheme?.headingRowColor,
          headingRowHeight: widget.dataTableTheme?.headingRowHeight,
          horizontalMargin: widget.dataTableTheme?.horizontalMargin,
        );
  }

  final debouncer = Debouncer(milliseconds: 500);
  final debouncerIndividual = Debouncer(milliseconds: 500);

  Size? rowSize;

  double? get rowHeight {
    final rowSize = this.rowSize;

    if (rowSize != null) return rowSize.height;

    return context.dataTableTheme?.dataRowMinHeight ??
        dataTableTheme.dataRowMinHeight;
  }

  @override
  void initState() {
    widget.controller?.clearColumnSearchFields = _clearColumnSearchFields;

    _controllers = LinkedScrollControllerGroup();
    _horizontalScrollController = _controllers.addAndGet();
    _columnsHeaderController = _controllers.addAndGet();
    _columnsFooterController = _controllers.addAndGet();

    textControllers = {
      for (final col in columns) col.key: createTextController(col),
    };

    sortInfo = widget.sortInfo;

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
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var context = rowKey.currentContext;
      if (context == null) return;

      final rowSize = context.size;

      if (rowSize != this.rowSize) {
        this.rowSize = rowSize;
        setState(() {});
      }
    });

    final theme = context.dataTableTheme;

    final oddTheme = theme?.oddRowTheme;
    final evenTheme = theme?.evenRowTheme;

    final dividerTheme = theme?.dividerThemeData ??
        DividerThemeData(
          thickness: dataTableTheme.dividerThickness,
          color: Theme.of(context).dividerColor,
          space: 0,
        );

    final tableDecoration = theme?.tableDecoration ??
        dataTableTheme.decoration ??
        BoxDecoration(
          borderRadius: BorderRadius.circular(0),
        );

    final tableBorderRadius =
        (tableDecoration as BoxDecoration?)?.borderRadius ?? BorderRadius.zero;

    final contentPadding = theme?.contentPadding;

    return DividerTheme(
      data: dividerTheme,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final availableWidth = constraints.maxWidth;
          final availableHeight = constraints.maxHeight;

          // `true` if available space is smaller than this value.
          final small = availableWidth < 600;

          double tableHeight;

          final rowHeight = this.rowHeight;

          final perPage = widget.paginatorInfo?.perPage;

          if (rowHeight == null) {
            tableHeight = availableHeight;
          } else {
            if (perPage != null && perPage != 0) {
              tableHeight = rowHeight * perPage + 10;
            } else if (widget.data.isNotEmpty) {
              tableHeight = rowHeight * widget.data.length + 10;
            } else {
              tableHeight = availableHeight;
            }
          }

          // Table layout.
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      decoration: tableDecoration,
                      child: ClipRRect(
                        borderRadius: tableBorderRadius,
                        child: SelectionArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Table title and actions.
                              Theme(
                                data: Theme.of(context).copyWith(
                                  inputDecorationTheme:
                                      theme?.selectColumnsInputTheme,
                                ),
                                child: SelectionContainer.disabled(
                                  child: header(
                                    small: small,
                                    width: availableWidth,
                                  ),
                                ),
                              ),
                              Container(
                                padding: contentPadding,
                                child: ScrollWidget(
                                  scrollController: _columnsHeaderController,
                                  minWidth: tableMinWidth,
                                  width: availableWidth,
                                  child: columnsWidget(),
                                ),
                              ),

                              if (widget.onChangeSearchTextField != null)
                                SelectionContainer.disabled(
                                  child: Container(
                                    padding: contentPadding,
                                    child: ScrollWidget(
                                      scrollController:
                                          _columnsFooterController,
                                      minWidth: tableMinWidth,
                                      width: availableWidth,
                                      child: searchWidget(),
                                    ),
                                  ),
                                ),

                              const Divider(),

                              Flexible(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight: tableHeight + 10,
                                  ),
                                  padding: contentPadding,
                                  child: ScrollWidgetWithBar(
                                    hScrollController:
                                        _horizontalScrollController,
                                    vScrollController:
                                        _verticalScrollController,
                                    minWidth: tableMinWidth,
                                    width: availableWidth,
                                    child: ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(
                                        scrollbars: false,
                                      ),
                                      child: ListView.separated(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        controller: _verticalScrollController,
                                        itemCount: widget.data.length,
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                        itemBuilder: (context, index) {
                                          final element = widget.data[index];

                                          final rowTheme = index.isOdd
                                              ? oddTheme
                                              : evenTheme;

                                          final decoration =
                                              rowTheme?.decoration ??
                                                  BoxDecoration(
                                                    color: index.isOdd
                                                        ? Theme.of(context)
                                                            .dividerColor
                                                            .withOpacity(0.3)
                                                        : Theme.of(context)
                                                            .cardColor,
                                                  );

                                          if (widget.onElementPressed == null) {
                                            return Container(
                                              decoration: decoration,
                                              margin: rowTheme?.margin,
                                              child: rowElementWidget(
                                                element,
                                                index,
                                              ),
                                            );
                                          }

                                          final rowBorderRadius =
                                              decoration.borderRadius ??
                                                  BorderRadius.zero;

                                          final background = Container(
                                            decoration: decoration,
                                            margin: rowTheme?.margin,
                                            child: Material(
                                              color: Colors.transparent,
                                              borderRadius: rowBorderRadius,
                                              child: InkWell(
                                                borderRadius: rowBorderRadius
                                                    .resolve(TextDirection.ltr),
                                                hoverColor:
                                                    rowTheme?.hoverColor,
                                                onTap:
                                                    widget.onElementPressed ==
                                                            null
                                                        ? null
                                                        : () => widget
                                                            .onElementPressed
                                                            ?.call(element),
                                              ),
                                            ),
                                          );

                                          return Stack(
                                            children: [
                                              Positioned.fill(
                                                child: widget.rowBuilder?.call(
                                                        element, background) ??
                                                    background,
                                              ),
                                              rowElementWidget(element, index),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Table pages info.
                              if (widget.paginatorInfo != null)
                                SelectionContainer.disabled(
                                  child: footer(availableWidth: availableWidth),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
        },
      ),
    );
  }

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
  Widget header({required bool small, required double width}) {
    final theme = context.dataTableTheme;

    final headerDecoration = theme?.headerDecoration;

    if (width < 500) {
      return Container(
        // Mark container to take all width possible.
        width: double.infinity,
        decoration: headerDecoration,
        padding: EdgeInsets.symmetric(
                horizontal: dataTableTheme.horizontalMargin ?? 20)
            .copyWith(
          top: 15,
          bottom: 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              width: 150,
              height: 40,
              child: hideShowColumnsWidget(),
            ),
            const SizedBox(width: 5),
            if (widget.onCopy != null ||
                widget.onPrint != null ||
                widget.onExport != null)
              PopupMenuButton(
                tooltip:
                    context.appLocalizations.moreOptions.naturalCapitalized,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                onSelected: (value) {
                  if (value == 0) {}
                },
                itemBuilder: (context) {
                  return [
                    if (widget.onCopy != null)
                      PopupMenuItem(
                        value: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.copy),
                            const SizedBox(width: 5),
                            Text(context
                                .appLocalizations.copy.naturalCapitalized),
                          ],
                        ),
                      ),
                    if (widget.onPrint != null)
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.print),
                            const SizedBox(width: 5),
                            Text(context
                                .appLocalizations.print.naturalCapitalized),
                          ],
                        ),
                      ),
                    if (widget.onExport != null)
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.download),
                            const SizedBox(width: 5),
                            Text(context
                                .appLocalizations.export.naturalCapitalized),
                          ],
                        ),
                      ),
                  ];
                },
              ),
          ],
        ),
      );
    }

    if (width < 600) {
      return Container(
        // Mark container to take all width possible.
        width: double.infinity,
        decoration: headerDecoration,
        padding: EdgeInsets.symmetric(
                horizontal: dataTableTheme.horizontalMargin ?? 20)
            .copyWith(top: 15, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: widget.titleWidget ??
                  Text(
                    widget.title ??
                        context
                            .appLocalizations.resultsTitle.naturalCapitalized,
                    style: theme?.tableTitleTextStyle ??
                        Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
            ),
            SizedBox(
              width: 180,
              height: 40,
              child: hideShowColumnsWidget(),
            ),
            if (widget.onExport != null ||
                widget.onPrint != null ||
                widget.onCopy != null) ...[
              const SizedBox(width: 5),
              PopupMenuButton(
                tooltip:
                    context.appLocalizations.moreOptions.naturalCapitalized,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                onSelected: (value) {
                  if (value == 0) {}
                },
                itemBuilder: (context) {
                  return [
                    if (widget.onCopy != null)
                      PopupMenuItem(
                        value: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.copy),
                            const SizedBox(width: 5),
                            Text(context
                                .appLocalizations.copy.naturalCapitalized),
                          ],
                        ),
                      ),
                    if (widget.onPrint != null)
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.print),
                            const SizedBox(width: 5),
                            Text(context
                                .appLocalizations.print.naturalCapitalized),
                          ],
                        ),
                      ),
                    if (widget.onExport != null)
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.download),
                            const SizedBox(width: 5),
                            Text(context
                                .appLocalizations.export.naturalCapitalized),
                          ],
                        ),
                      ),
                  ];
                },
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      // Mark container to take all width possible.
      width: double.infinity,
      decoration: headerDecoration,
      padding: EdgeInsets.symmetric(
              horizontal: dataTableTheme.horizontalMargin ?? 20)
          .copyWith(top: 15, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: widget.titleWidget ??
                Text(
                  widget.title ??
                      context.appLocalizations.resultsTitle.naturalCapitalized,
                  style: theme?.tableTitleTextStyle ??
                      Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
          ),
          Text(
            '${context.appLocalizations.show.naturalCapitalized}:',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 180,
            height: 40,
            // Only allow to hide column that have name.
            child: hideShowColumnsWidget(),
          ),
          if (widget.onExport != null ||
              widget.onPrint != null ||
              widget.onCopy != null) ...[
            const SizedBox(width: 5),
            Material(
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onCopy != null)
                    IconButton(
                      splashRadius: 20,
                      onPressed: widget.onCopy,
                      icon: const Icon(
                        FeatherIcons.copy,
                      ),
                    ),
                  if (widget.onPrint != null)
                    IconButton(
                      splashRadius: 20,
                      onPressed: widget.onPrint,
                      icon: const Icon(
                        FeatherIcons.printer,
                      ),
                    ),
                  if (widget.onExport != null)
                    IconButton(
                      splashRadius: 20,
                      onPressed: widget.onExport,
                      icon: const Icon(
                        FeatherIcons.download,
                      ),
                    ),
                ],
              ),
            ),
          ],
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
        columnsSelected = values;

        columnsSelected?.addAll(
          widget.columns.where((element) => element.name.isEmpty),
        );

        setState(() {});
      },
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
      dataTableTheme: dataTableTheme,
      onNextPage: widget.onNextPage,
      onPerPageChange: widget.onPerPageChange,
      onPreviousPage: widget.onPreviousPage,
      onSelectedPage: widget.onSelectedPage,
    );
  }

  final rowKey = GlobalKey();

  Widget rowElementWidget(T element, int index) {
    if (index == 0) {}

    final map = widget.toMap(element);

    return Padding(
      key: index == 0 ? rowKey : null,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final column in columnsToShow)
            if (column.flex != null) ...[
              Expanded(
                flex: column.flex ?? 1,
                child: cell(
                  element,
                  map,
                  column,
                  columnsToShow.lastOrNull == column,
                ),
              ),
            ] else ...[
              SizedBox(
                width: column.width,
                child: cell(
                  element,
                  map,
                  column,
                  columnsToShow.lastOrNull == column,
                ),
              ),
            ],
        ],
      ),
    );
  }

  /// Widget that creates all columns titles.
  ///
  /// Creates all columns that are specified in [colums]. Each element of the list
  /// contains the information of hoe much horizontal space it has to take.
  /// If flex is specified, creates an [Expand] widget with that flex. In the other hand
  /// if only width is specified, it creates a [SizedBox] with the size given.
  Widget columnsWidget() {
    final columnHeaderDecoration =
        context.dataTableTheme?.columnHeaderDecoration ??
            BoxDecoration(
              color: dataTableTheme.headingRowColor
                  ?.resolve({WidgetState.selected}),
            );

    return Container(
      decoration: columnHeaderDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final column in columnsToShow)
            if (column.flex != null) ...[
              Expanded(
                flex: column.flex!,
                child: columnWidget(
                    column, column.key == columnsToShow.lastOrNull?.key),
              ),
            ] else ...[
              SizedBox(
                width: column.width,
                child: columnWidget(
                    column, column.key == columnsToShow.lastOrNull?.key),
              ),
            ]
        ],
      ),
    );
  }

  /// Widget that creates one single column title.
  ///
  /// Creates a title with the name of the column. Also, it creates the button to
  /// sort all data of the table by this column. The information of the column is contained in
  /// [column].
  Widget columnWidget(ColumnInfo column, bool lastColumn) {
    final columnTitleTextStyle = context.dataTableTheme?.columnTitleTextStyle ??
        dataTableTheme.headingTextStyle;

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
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name of the column.
                    Flexible(
                      child: Text(
                        '${column.name}${lastColumn ? '\r' : '\t'}',
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: columnTitleTextStyle,
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
        ),
      ],
    );
  }

  Widget searchWidget() {
    final columnSearchDecoration =
        context.dataTableTheme?.columnSearchDecoration ??
            BoxDecoration(
              color: Theme.of(context).cardColor,
            );

    return Container(
      decoration: columnSearchDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final column in columnsToShow)
            if (column.flex != null)
              Expanded(
                flex: column.flex!,
                child: searchField(column),
              )
            else
              SizedBox(
                width: column.width,
                child: searchField(column),
              )
        ],
      ),
    );
  }

  Widget searchField(ColumnInfo column) {
    if (column.name.isEmpty || !column.canSearchInput) return const SizedBox();

    final theme = context.dataTableTheme;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 2),
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
  Widget cell(
      T element, Map<String, dynamic> map, ColumnInfo column, bool lastInRow) {
    // Calls the function to get cell data.
    final cellWidget = widget.cell?.call(element, map, column.key);

    // If data is not specified or child is not given, the cell is displaying the
    // text contained in the map by the column id.
    if (cellWidget == null) {
      final cellText = '${map[column.key] ?? ''}'.replaceAll('\n', ' ');

      final dataRowMinHeight = context.dataTableTheme?.dataRowMinHeight ??
          dataTableTheme.dataRowMinHeight;

      return Container(
        padding: const EdgeInsets.only(left: 5),
        constraints: dataRowMinHeight == null
            ? null
            : BoxConstraints(
                minHeight: dataRowMinHeight,
              ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '$cellText${lastInRow ? '\r' : '\t'}',
            style: dataTableTheme.dataTextStyle,
            maxLines: 1,
          ),
        ),
      );
    }

    // Display widget specified in child if not null.
    return Row(
      children: [
        Expanded(
          child: cellWidget,
        ),
        Text(
          lastInRow ? '\r' : '\t',
          style: const TextStyle(fontSize: 5),
        ),
      ],
    );
  }
}

class ScrollWidget extends StatelessWidget {
  final double minWidth;
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
    if (minWidth < width) return child;

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
  final double minWidth;
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
    if (minWidth < width) {
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
