import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/src/models/sort_info.dart';
import 'package:custom_data_table/src/table_paginated_count_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class CustomDataTable<T> extends StatefulWidget {
  /// Title of table.
  ///
  /// if `null` shows `Listado` in the title.
  final String? title;

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

  /// Callback that notifies when the next page button is pressed.
  final VoidCallback? onNextPage;

  /// Callback that notifies when the previous page button is pressed.
  final VoidCallback? onPreviousPage;

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

  final Widget? searchBar;

  const CustomDataTable({
    Key? key,
    this.title,
    required this.columns,
    required this.data,
    required this.toMap,
    this.cell,
    this.onElementPressed,
    required this.onSort,
    this.paginatorInfo,
    this.onNextPage,
    this.onPreviousPage,
    this.onCopy,
    this.onPrint,
    this.onExport,
    this.onChangeSearchTextField,
    this.searchBar,
  }) : super(key: key);

  @override
  State<CustomDataTable<T>> createState() => _CustomDataTableState<T>();
}

class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
  late List<ColumnInfo> columns;

  /// Information of current sort options.
  SortInfo? sortInfo;

  /// Columns selected to show in the table.
  List<ColumnInfo>? columnsSelected;

  /// Gets the columns that have to be displayed in the table.
  ///
  /// If there is no column selected it has to display all columns.
  List<ColumnInfo> get columnsToShow => columnsSelected ?? columns;

  /// Scroll controllers to show ScrollBar.
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  late Map<String, TextEditingController> textControllers;

  @override
  void initState() {
    columns = widget.columns;

    textControllers = {
      for (final col in columns) col.key: createTextController(),
    };

    super.initState();
  }

  TextEditingController createTextController() => TextEditingController()
    ..addListener(
      () {
        widget.onChangeSearchTextField?.call(textControllers.entries
            .map(
              (e) => SearchFieldInfo(
                columnInfo:
                    columns.firstWhere((element) => element.key == e.key),
                searchValue: e.value.text,
              ),
            )
            .toList());
      },
    );

  @override
  void dispose() {
    // Dispose scroll controllers.

    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff364258).withOpacity(0.03),
            blurRadius: 9.0,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),

        // Listen to screen size changes to adapt to large and small screens.
        child: LayoutBuilder(
          builder: (_, constraints) {
            final availableWidth = constraints.maxWidth;

            // `true` if available space is smaller than this value.
            final small = availableWidth < 600;

            // Table layout.
            return Column(
              children: [
                // Table title and actions.
                header(small: small, width: availableWidth),
                // Table content, including columns and rows.
                Expanded(
                  child: content(small: small, availableWidth: availableWidth),
                ),

                // Table pages info.
                footer(),
              ],
            );
          },
        ),
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
    if (width < 700) {
      return Container(
        // Mark container to take all width possible.
        width: double.infinity,
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              width: 150,
              height: 40,
              // Only allow to hide column that have name.
              child: PopUpField<ColumnInfo>(
                tooltip: 'Mostrar/Ocultar columnas',
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
              ),
            ),
            const SizedBox(width: 5),
            if (widget.onCopy != null ||
                widget.onPrint != null ||
                widget.onExport != null)
              PopupMenuButton(
                tooltip: 'Más opciones',
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
                          children: const [
                            Icon(Icons.copy),
                            SizedBox(width: 5),
                            Text('Copiar'),
                          ],
                        ),
                      ),
                    if (widget.onPrint != null)
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.print),
                            SizedBox(width: 5),
                            Text('Imprimir'),
                          ],
                        ),
                      ),
                    if (widget.onExport != null)
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.download),
                            SizedBox(width: 5),
                            Text('Exportar'),
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

    if (width < 1000) {
      return Container(
        // Mark container to take all width possible.
        width: double.infinity,
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.title ?? 'Listado',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(
              width: 130,
              height: 40,
              // Only allow to hide column that have name.
              child: PopUpField<ColumnInfo>(
                tooltip: 'Mostrar/Ocultar columnas',
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
              ),
            ),
            if (widget.onExport != null ||
                widget.onPrint != null ||
                widget.onCopy != null) ...[
              const SizedBox(width: 5),
              PopupMenuButton(
                tooltip: 'Más opciones',
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
                          children: const [
                            Icon(Icons.copy),
                            SizedBox(width: 5),
                            Text('Copiar'),
                          ],
                        ),
                      ),
                    if (widget.onPrint != null)
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.print),
                            SizedBox(width: 5),
                            Text('Imprimir'),
                          ],
                        ),
                      ),
                    if (widget.onExport != null)
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.download),
                            SizedBox(width: 5),
                            Text('Exportar'),
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
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              widget.title ?? 'Listado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            'Mostrar:',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 130,
            height: 40,
            // Only allow to hide column that have name.
            child: PopUpField<ColumnInfo>(
              tooltip: 'Mostrar/Ocultar columnas',
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
            ),
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

  /// Table content.
  ///
  /// Widget that calculates min width of table and creates a scroll horizontal if
  /// the table does not fit the available space.
  ///
  /// [small] tells if the available space to display the table is not large enough.
  /// [availableWidth] max width that the table has to draw. If [availableWidth] is
  /// smaller than table min width, the table can be scrolled horizontally.
  ///
  /// To calculate table min width, we sum all columns width. That would be the table
  /// breakpoint, where the table begins to scroll.
  Widget content({required bool small, required double availableWidth}) {
    // Table breakpoint to begin to scroll.
    double tableWidth = 0;

    // Sum all widths.
    for (final column in columnsToShow) {
      tableWidth += column.width;
    }

    // If table width fits in available space, the table displays just like it is.
    if (tableWidth < availableWidth) {
      return dataTable(small);
    }

    // If table width is bigger than available space, then it is surrounded by a
    // horizontal scroll.
    return MediaQuery(
      data: MediaQuery.of(context).removePadding(removeBottom: true),
      child: SafeArea(
        child: Scrollbar(
          controller: _horizontalScrollController,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              // The table width is the value calculated.
              width: tableWidth,
              child: dataTable(small),
            ),
          ),
        ),
      ),
    );
  }

  /// Table footer.
  ///
  /// Displays pages info. Contains buttons to navigate between pages.
  /// If paginator info is `null`, the footer is not displayed.
  Widget footer() {
    if (widget.paginatorInfo == null) return const SizedBox();

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(bottom: 15),
      child: TablePaginatedCountWidget(
        paginatorInfo: widget.paginatorInfo!,
        loading: false,
        onPressedLast: widget.onPreviousPage,
        onPressedNext: widget.onNextPage,
      ),
    );
  }

  /// Content of table.
  ///
  /// Widget that displays columns and rows, and the data that has to be displayed
  /// in those cells.
  /// [small] tells if the available space to display the table is not large enough.
  Widget dataTable(bool small) {
    return Column(
      children: [
        columnsWidget(),
        Expanded(
          child: ListView.separated(
            controller: _verticalScrollController,
            itemCount: widget.data.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final element = widget.data[index];
              final map = widget.toMap(element);

              return Material(
                color: index.isEven
                    ? Colors.grey.withOpacity(0.04)
                    : Theme.of(context).cardColor,
                child: InkWell(
                  hoverColor: Colors.black12,
                  onTap: widget.onElementPressed == null
                      ? null
                      : () => widget.onElementPressed?.call(element),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (final column in columnsToShow)
                          if (column.flex != null)
                            Expanded(
                              flex: column.flex ?? 1,
                              child: cell(element, map, column),
                            )
                          else
                            SizedBox(
                              width: column.width,
                              child: cell(element, map, column),
                            ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.onChangeSearchTextField != null)
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.only(bottom: 15),
            child: searchWidget(),
          )
        else
          Container(
            color: Theme.of(context).cardColor,
            height: 10,
          ),
      ],
    );
  }

  /// Widget that creates all columns titles.
  ///
  /// Creates all columns that are specified in [colums]. Each element of the list
  /// contains the information of hoe much horizontal space it has to take.
  /// If flex is specified, creates an [Expand] widget with that flex. In the other hand
  /// if only width is specified, it creates a [SizedBox] with the size given.
  Widget columnsWidget() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final column in columnsToShow)
            if (column.flex != null)
              Expanded(
                flex: column.flex!,
                child: columnWidget(column),
              )
            else
              SizedBox(
                width: column.width,
                child: columnWidget(column),
              )
        ],
      ),
    );
  }

  /// Widget that creates one single column title.
  ///
  /// Creates a title with the name of the column. Also, it creates the button to
  /// sort all data of the table by this column. The information of the column is contained in
  /// [column].
  Widget columnWidget(ColumnInfo column) {
    if (column.name.isEmpty) return const SizedBox();

    return Row(
      children: [
        Flexible(
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () {
                // Changes the state of sort.
                // If there is no column marked as sort, this column is marked as
                // sorting ascendant.

                if (sortInfo?.columnInfo != column) {
                  sortInfo = SortInfo(columnInfo: column, asc: true);
                } else {
                  sortInfo!.asc = !sortInfo!.asc;
                }

                widget.onSort(sortInfo!);

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
                        column.name,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style:
                            Theme.of(context).dataTableTheme.headingTextStyle,
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Indicates if the column is sorted asc, desc or if it is not sorted.
                    if (column == sortInfo?.columnInfo)
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
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
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
    if (column.name.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextFormField(
        controller: textControllers[column.key],
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          hintText: column.name,
          hintStyle: const TextStyle(
            fontSize: 14,
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5).copyWith(left: 5),
        child: Text(
          '${map[column.key] ?? ''}',
          style: Theme.of(context).dataTableTheme.dataTextStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    // Display widget specified in child if not null.
    return Material(
      color: Colors.transparent,
      child: cellWidget,
    );
  }
}
