import 'package:custom_data_table/src/domain/models/column_info.dart';
import 'package:custom_data_table/src/domain/models/sort_info.dart';
import 'package:custom_data_table/src/ui/core/themes/datatable_theme.dart';
import 'package:custom_data_table/src/utils/debounce.dart';
import 'package:flutter/material.dart';

/// An atomic widget displaying a single column header cell with its title,
/// optional sort direction toggle, and optional column search input.
class TableColumnHeader extends StatefulWidget {
  /// The column metadata and configuration.
  final ColumnInfo column;

  /// Current sorting state of the table.
  final SortInfo? sortInfo;

  /// Callback invoked when the user toggles sorting for this column.
  final ValueChanged<SortInfo>? onSort;

  /// Optional text editing controller for the column search field.
  final TextEditingController? searchController;

  /// Callback invoked when the column search input changes (debounced).
  final ValueChanged<String>? onSearchChanged;

  /// Debouncer used for the search text field. If null, a default 500ms debouncer is used.
  final Debouncer? debouncer;

  const TableColumnHeader({
    super.key,
    required this.column,
    this.sortInfo,
    this.onSort,
    this.searchController,
    this.onSearchChanged,
    this.debouncer,
  });

  @override
  State<TableColumnHeader> createState() => _TableColumnHeaderState();
}

class _TableColumnHeaderState extends State<TableColumnHeader> {
  late final Debouncer _debouncer;
  TextEditingController? _internalController;

  TextEditingController get _controller =>
      widget.searchController ??
      widget.column.controllerInput ??
      (_internalController ??= TextEditingController(
        text: widget.column.initialSearchValue,
      ));

  @override
  void initState() {
    super.initState();
    _debouncer = widget.debouncer ?? Debouncer(milliseconds: 500);
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataTableTheme = context.watchDataTableTheme;
    final columnTitleTextStyle = dataTableTheme?.columnTitleTextStyle;
    final column = widget.column;
    final sortInfo = widget.sortInfo;

    return Container(
      width: column.width,
      height: dataTableTheme?.columnHeaderHeight,
      padding: column.canSort ? null : const EdgeInsets.only(right: 5),
      child: Row(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                if (column.canSearchInput) {
                  return _buildSearchInput(context);
                }

                return Text(
                  column.name,
                  overflow: TextOverflow.fade,
                  style: columnTitleTextStyle,
                );
              },
            ),
          ),
          if (column.canSort)
            SizedBox(
              width: 30,
              height: 30,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  final SortInfo newSortInfo;
                  if (sortInfo?.columnInfo.key != column.key) {
                    newSortInfo = SortInfo(columnInfo: column, asc: true);
                  } else {
                    newSortInfo = SortInfo(
                      columnInfo: column,
                      asc: !(sortInfo?.asc ?? true),
                    );
                  }

                  widget.onSort?.call(newSortInfo);
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
            ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(BuildContext context) {
    if (widget.column.name.isEmpty) return const SizedBox();

    final dataTableTheme = context.watchDataTableTheme;

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: dataTableTheme?.columnSearchInputTheme,
      ),
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.column.name,
        ),
        style: const TextStyle(
          fontSize: 13,
        ),
        onChanged: (value) => _debouncer.run(
          () {
            widget.column.onChangeInput?.call(value);
            widget.onSearchChanged?.call(value);
          },
        ),
      ),
    );
  }
}
