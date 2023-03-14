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
  }) : super(key: key);

  @override
  State<CustomDataTable<T>> createState() => _CustomDataTableState<T>();
}

class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
  SortInfo? sortInfo;

  List<ColumnInfo>? columnsSelected;

  List<ColumnInfo> get columnsToShow => columnsSelected ?? widget.columns;

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
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.title ?? 'Listado',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Mostrar'),
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
                    ],
                  ),
                  if (widget.onCopy != null &&
                      widget.onPrint != null &&
                      widget.onExport != null)
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
                    )
                ],
              ),
            ),
            const Divider(height: 0),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (final column in columnsToShow)
                    if (column.width != null)
                      SizedBox(
                        width: column.width,
                        child: title(column),
                      )
                    else
                      Expanded(
                        flex: column.flex ?? 1,
                        child: title(column),
                      ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: widget.data.length,
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final element = widget.data[index];
                  final map = widget.toMap(element);

                  return Material(
                    color: index.isEven
                        ? Colors.grey.withOpacity(0.04)
                        : Colors.white,
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
                              if (column.width != null)
                                SizedBox(
                                  width: column.width,
                                  child: cell(element, map, column),
                                )
                              else
                                Expanded(
                                  flex: column.flex ?? 1,
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
        ),
      ),
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

  Widget cell(T element, Map<String, dynamic> map, ColumnInfo column) {
    final cellData = widget.cell(element, map, column.key);

    return cellData.child != null
        ? Material(
            color: Colors.transparent,
            child: cellData.child,
          )
        : Padding(
            padding: const EdgeInsets.only(left: 5, top: 10, bottom: 10),
            child: Text(
              cellData.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
  }
}
