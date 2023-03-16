import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/src/models/sort_info.dart';
import 'package:custom_data_table/src/table_paginated_count_widget.dart';
import 'package:flutter/material.dart';

class CustomDataTable<T> extends StatefulWidget {
  final List<ColumnInfo> columns;
  final List<T> data;

  final CellInfo Function(T element, Map<String, dynamic> map, String key) cell;

  final Map<String, dynamic> Function(T element) toMap;

  final Function(T value)? onElementPressed;

  final Function(SortInfo sortInfo) onSort;

  final PaginatorInfo? paginatorInfo;

  final VoidCallback? onPressedNext;
  final VoidCallback? onPressedLast;

  final VoidCallback? onCopy;
  final VoidCallback? onPrint;
  final VoidCallback? onExport;

  final String? title;

  final VoidCallback? onFilterPressed;

  const CustomDataTable({
    Key? key,
    required this.columns,
    required this.data,
    required this.toMap,
    required this.cell,
    required this.onSort,
    this.onElementPressed,
    this.paginatorInfo,
    this.onPressedNext,
    this.onPressedLast,
    this.onCopy,
    this.onPrint,
    this.onExport,
    this.title,
    this.onFilterPressed,
  }) : super(key: key);

  @override
  State<CustomDataTable<T>> createState() => _CustomDataTableState<T>();
}

class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
  SortInfo? sortInfo;

  List<ColumnInfo>? columnsSelected;

  List<ColumnInfo> get columnsToShow => columnsSelected ?? widget.columns;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
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
        child: LayoutBuilder(
          builder: (_, constraints) {
            final availableWidth = constraints.maxWidth;

            final small = availableWidth < 500;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!small)
                        Expanded(
                          child: Text(
                            widget.title ?? 'Listado',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      if (!small) const Text('Mostrar'),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 150,
                        height: 40,
                        child: PopUpField<ColumnInfo>(
                          items: widget.columns
                              .where(
                                  (element) => element.name.isNotEmpty == true)
                              .map(
                                (e) => PopUpMenuItem(
                                    key: e.key, name: e.name, value: e),
                              )
                              .toList(),
                          selectedFields: widget.columns
                              .where(
                                  (element) => element.name.isNotEmpty == true)
                              .map(
                                (e) => PopUpMenuItem(
                                    key: e.key, name: e.name, value: e),
                              )
                              .toList(),
                          onChange: (values) {
                            columnsSelected = values;

                            columnsSelected?.addAll(
                              widget.columns
                                  .where((element) => element.name.isEmpty),
                            );

                            setState(() {});
                          },
                        ),
                      ),
                      if (small) ...[
                        const Spacer(),
                        PopupMenuButton(
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
                                      Icon(
                                        Icons.copy,
                                        color: Colors.grey[800],
                                      ),
                                      const SizedBox(width: 5),
                                      const Text('Copiar'),
                                    ],
                                  ),
                                ),
                              if (widget.onPrint != null)
                                PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.print,
                                        color: Colors.grey[800],
                                      ),
                                      const SizedBox(width: 5),
                                      const Text('Imprimir'),
                                    ],
                                  ),
                                ),
                              if (widget.onExport != null)
                                PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.download,
                                        color: Colors.grey[800],
                                      ),
                                      const SizedBox(width: 5),
                                      const Text('Exportar'),
                                    ],
                                  ),
                                ),
                            ];
                          },
                        ),
                        if (widget.onFilterPressed != null)
                          FloatingActionButton.small(
                            elevation: 0,
                            onPressed: widget.onFilterPressed,
                            heroTag: 'Filter',
                            child: const Icon(Icons.filter_list),
                          ),
                      ] else if (widget.onCopy != null &&
                          widget.onPrint != null &&
                          widget.onExport != null) ...[
                        const SizedBox(width: 20),
                        Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.onCopy != null)
                                IconButton(
                                  splashRadius: 20,
                                  onPressed: widget.onCopy,
                                  icon: Icon(
                                    Icons.copy,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              if (widget.onPrint != null)
                                IconButton(
                                  splashRadius: 20,
                                  onPressed: widget.onPrint,
                                  icon: Icon(
                                    Icons.print,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              if (widget.onExport != null)
                                IconButton(
                                  splashRadius: 20,
                                  onPressed: widget.onExport,
                                  icon: Icon(
                                    Icons.download,
                                    color: Colors.grey[800],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                const Divider(height: 0),
                Expanded(
                  child: Builder(builder: (context) {
                    double tableWidth = 0;

                    for (final column in columnsToShow) {
                      tableWidth += column.width;
                    }

                    if (tableWidth < availableWidth) {
                      return dataTable(small);
                    }

                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .removePadding(removeBottom: true),
                      child: SafeArea(
                        child: Scrollbar(
                          controller: _horizontalScrollController,
                          child: SingleChildScrollView(
                            controller: _horizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: tableWidth,
                              child: dataTable(small),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                if (widget.paginatorInfo != null)
                  Container(
                    color: Colors.white,
                    child: TablePaginatedCountWidget(
                      paginatorInfo: widget.paginatorInfo!,
                      loading: false,
                      onPressedLast: widget.onPressedLast,
                      onPressedNext: widget.onPressedNext,
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget dataTable(bool small) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final column in columnsToShow)
                if (column.flex != null)
                  Expanded(
                    flex: column.flex!,
                    child: title(column),
                  )
                else
                  SizedBox(
                    width: column.width,
                    child: title(column),
                  )
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: _verticalScrollController,
            itemCount: widget.data.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final element = widget.data[index];
              final map = widget.toMap(element);

              return Material(
                color:
                    index.isEven ? Colors.grey.withOpacity(0.04) : Colors.white,
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
                              child: cell(element, map, column, small),
                            )
                          else
                            SizedBox(
                              width: column.width,
                              child: cell(element, map, column, small),
                            ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget title(ColumnInfo column) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () {
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
                  Text(column.name),
                  const SizedBox(width: 5),
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
      ],
    );
  }

  Widget cell(
      T element, Map<String, dynamic> map, ColumnInfo column, bool small) {
    final cellData = widget.cell(element, map, column.key);

    return cellData.child != null
        ? Material(
            color: Colors.transparent,
            child: cellData.child,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 10).copyWith(left: 5),
            child: Text(
              cellData.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
  }
}
