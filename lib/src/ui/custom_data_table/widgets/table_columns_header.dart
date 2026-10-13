import 'package:custom_data_table/src/domain/models/column_info.dart';
import 'package:custom_data_table/src/domain/models/sort_info.dart';
import 'package:custom_data_table/src/ui/core/themes/datatable_theme.dart';
import 'package:custom_data_table/src/ui/custom_data_table/widgets/table_column_header.dart';
import 'package:custom_data_table/src/utils/debounce.dart';
import 'package:flutter/material.dart';

/// A horizontal container widget that lays out [TableColumnHeader] cells
/// according to their width or flex, synchronizing horizontal scrolling.
class TableColumnsHeader extends StatelessWidget {
  /// The list of visible columns to display.
  final List<ColumnInfo> columns;

  /// Injected scroll controller for horizontal scroll synchronization.
  final ScrollController? scrollController;

  /// Current sorting information.
  final SortInfo? sortInfo;

  /// Callback when a column header toggles sort.
  final ValueChanged<SortInfo>? onSort;

  /// Map of text controllers for each column search field keyed by column key.
  final Map<String, TextEditingController>? textControllers;

  /// Callback invoked when any column search field changes.
  final void Function(ColumnInfo column, String value)? onColumnSearchChanged;

  /// Debounce duration for column search fields.
  final Duration debounceDuration;

  /// Optional debouncer for column search fields.
  final TableDebouncer? debouncer;

  const TableColumnsHeader({
    super.key,
    required this.columns,
    this.scrollController,
    this.sortInfo,
    this.onSort,
    this.textControllers,
    this.onColumnSearchChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.debouncer,
  });

  @override
  Widget build(BuildContext context) {
    final dataTableTheme = context.watchDataTableTheme;
    final rowPadding = dataTableTheme?.rowPadding;

    final minWidth = columns.isEmpty
        ? 0.0
        : columns
                .map((e) => e.width)
                .reduce((value, element) => value + element) +
            (rowPadding?.right ?? 0) +
            (rowPadding?.left ?? 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > minWidth) {
          return _buildRow(context, scrollable: false);
        }

        return SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: minWidth,
            child: _buildRow(context, scrollable: true),
          ),
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, {required bool scrollable}) {
    final dataTableTheme = context.watchDataTableTheme;

    final columnHeaderDecoration = dataTableTheme?.columnHeaderDecoration;
    final verticalPadding = dataTableTheme?.columnHeaderVerticalPadding;
    final horizontalPadding = dataTableTheme?.rowPadding;

    final padding = EdgeInsets.only(
      top: verticalPadding?.top ?? 0,
      bottom: verticalPadding?.bottom ?? 0,
      left: horizontalPadding?.left ?? 0,
      right: horizontalPadding?.right ?? 0,
    );

    final anyFlex = columns.any((element) => element.flex != null);

    return Container(
      decoration: columnHeaderDecoration,
      padding: padding,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final col in columns)
              Builder(
                builder: (context) {
                  final width = col.width;
                  final flex = anyFlex ? col.flex : width.toInt();

                  final headerCell = TableColumnHeader(
                    column: col,
                    sortInfo: sortInfo,
                    onSort: onSort,
                    searchController: textControllers?[col.key],
                    onSearchChanged: onColumnSearchChanged != null
                        ? (value) => onColumnSearchChanged!(col, value)
                        : null,
                    debounceDuration: debounceDuration,
                    debouncer: debouncer,
                  );

                  if (scrollable || flex == null || col.hasFixedWidth == true) {
                    return SizedBox(
                      width: width,
                      child: headerCell,
                    );
                  }

                  return Expanded(
                    flex: flex,
                    child: headerCell,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
