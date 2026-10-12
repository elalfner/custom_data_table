import 'package:custom_data_table/src/domain/models/column_info.dart';
import 'package:custom_data_table/src/ui/core/themes/datatable_theme.dart';
import 'package:flutter/material.dart';

/// A widget that renders a single table row with zebra striping, hover feedback,
/// and cell builders.
class TableRowWidget<T> extends StatelessWidget {
  /// The element representing the row data.
  final T element;

  /// The zero-based index of this row within the table.
  final int index;

  /// The list of visible columns to render cells for.
  final List<ColumnInfo> columns;

  /// Converts the row [element] into a map keyed by column identifiers.
  final Map<String, dynamic> Function(T element) toMap;

  /// Optional builder to customize individual cell rendering.
  final Widget? Function(T element, Map<String, dynamic> map, String key)? cell;

  /// Optional builder to wrap the entire row widget.
  final Widget Function(T element, Widget widget)? rowBuilder;

  /// Callback invoked when the row is tapped.
  final ValueChanged<T>? onTapRow;

  /// Whether the table row is horizontally scrollable.
  final bool scrollable;

  /// Minimum height for the row. If null, falls back to the theme's [dataRowHeight].
  final double? minHeight;

  const TableRowWidget({
    super.key,
    required this.element,
    required this.index,
    required this.columns,
    required this.toMap,
    this.cell,
    this.rowBuilder,
    this.onTapRow,
    this.scrollable = false,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final dataTableTheme = context.watchDataTableTheme;
    final rowMinHeight = minHeight ?? dataTableTheme?.dataRowHeight ?? 38;

    final anyFlex = columns.any((column) => column.flex != null);
    final map = toMap(element);

    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapRow == null ? null : () => onTapRow!(element),
        child: Padding(
          padding: dataTableTheme?.rowPadding ?? EdgeInsets.zero,
          child: Row(
            children: [
              for (final col in columns)
                Builder(
                  builder: (context) {
                    final width = col.width;
                    final flex = anyFlex ? col.flex : width.toInt();

                    if (scrollable ||
                        flex == null ||
                        col.hasFixedWidth == true) {
                      return SizedBox(
                        width: width,
                        child: _buildCell(context, col, map),
                      );
                    }

                    return Expanded(
                      flex: flex,
                      child: _buildCell(context, col, map),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );

    return Container(
      decoration: index.isEven
          ? dataTableTheme?.evenRowTheme?.decoration
          : dataTableTheme?.oddRowTheme?.decoration,
      height: rowMinHeight,
      child: rowBuilder != null ? rowBuilder!(element, child) : child,
    );
  }

  Widget _buildCell(
    BuildContext context,
    ColumnInfo column,
    Map<String, dynamic> map,
  ) {
    final dataTableTheme = context.watchDataTableTheme;
    final cellWidget = cell?.call(element, map, column.key);

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

    return cellWidget;
  }
}
