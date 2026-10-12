import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/domain/models/column_info.dart';
import 'package:custom_data_table/src/ui/core/themes/datatable_theme.dart';
import 'package:custom_data_table/src/ui/custom_data_table/widgets/table_row_widget.dart';
import 'package:flutter/material.dart';

/// Calculates the table content height based on item count and row height.
double calculateContentHeight({
  required int itemCount,
  required double minRowHeight,
  required double dividerHeight,
}) {
  if (itemCount == 0) return 0;
  return (minRowHeight * itemCount) + (dividerHeight * (itemCount - 1));
}

/// A widget that manages the data table viewport, handling dual scrollbars
/// (horizontal and vertical), separated row list, loading and exception states,
/// and adaptive height constraints for bounded vs unbounded layouts.
class TableContent<T> extends StatefulWidget {
  /// The layout constraints passed down from parent viewport.
  final BoxConstraints constraints;

  /// The list of visible columns to display.
  final List<ColumnInfo> columns;

  /// The list of items to render in rows. If null, displays loading or exception state.
  final List<T>? data;

  /// Function to convert each row item [element] into a map keyed by column key.
  final Map<String, dynamic> Function(T element) toMap;

  /// Optional custom cell builder.
  final Widget? Function(T element, Map<String, dynamic> map, String key)? cell;

  /// Optional builder to wrap the row widget.
  final Widget Function(T element, Widget widget)? rowBuilder;

  /// Callback invoked when a row is tapped.
  final ValueChanged<T>? onTapRow;

  /// Vertical scroll controller for the row list.
  final ScrollController? verticalScrollController;

  /// Horizontal scroll controller synchronized with table headers.
  final ScrollController? horizontalScrollController;

  /// Whether the table is currently in loading state.
  final bool isLoading;

  /// Custom builder for loading state. Falls back to [CircularProgressIndicator].
  final Widget Function()? loadingBuilder;

  /// Custom builder for error/empty state when data is null and not loading.
  final Widget Function()? exceptionBuilder;

  /// Custom builder for empty state when data is non-null and empty.
  final Widget Function()? emptyBuilder;

  const TableContent({
    super.key,
    required this.constraints,
    required this.columns,
    required this.data,
    required this.toMap,
    this.cell,
    this.rowBuilder,
    this.onTapRow,
    this.verticalScrollController,
    this.horizontalScrollController,
    this.isLoading = false,
    this.loadingBuilder,
    this.exceptionBuilder,
    this.emptyBuilder,
  });

  @override
  State<TableContent<T>> createState() => _TableContentState<T>();
}

class _TableContentState<T> extends State<TableContent<T>> {
  ScrollController? _internalVerticalController;
  ScrollController? _internalHorizontalController;

  ScrollController get _verticalController =>
      widget.verticalScrollController ??
      (_internalVerticalController ??= ScrollController());

  ScrollController get _horizontalController =>
      widget.horizontalScrollController ??
      (_internalHorizontalController ??= ScrollController());

  @override
  void dispose() {
    _internalVerticalController?.dispose();
    _internalHorizontalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataTableTheme = context.watchDataTableTheme;
    final rowPadding = dataTableTheme?.rowPadding;
    final rowMinHeight = dataTableTheme?.dataRowHeight ?? 38;
    final dividerHeight = dataTableTheme?.dividerHeight ?? 0;

    final minWidth = widget.columns.isEmpty
        ? 0.0
        : widget.columns
                .map((e) => e.width)
                .reduce((value, element) => value + element) +
            (rowPadding?.right ?? 0) +
            (rowPadding?.left ?? 0);

    final tableConstraints = BoxConstraints(minWidth: minWidth);

    final data = widget.data;
    final error = data == null && !widget.isLoading;

    double? currentContentHeight;
    if (data != null) {
      currentContentHeight = calculateContentHeight(
        itemCount: data.length,
        minRowHeight: rowMinHeight,
        dividerHeight: dividerHeight,
      );
    }

    final isCompactState =
        (data != null && data.isEmpty) || (data == null && widget.isLoading);

    final tableContentContainer = Container(
      constraints: isCompactState
          ? const BoxConstraints(maxHeight: 100.0)
          : (currentContentHeight == null || error
              ? null
              : BoxConstraints(
                  maxHeight: currentContentHeight + 10,
                )),
      child: Builder(
        builder: (context) {
          if (data == null) {
            if (widget.isLoading) {
              return widget.loadingBuilder?.call() ??
                  _buildDefaultLoadingWidget(context);
            } else {
              return widget.exceptionBuilder?.call() ?? const SizedBox();
            }
          }

          if (data.isEmpty) {
            return widget.emptyBuilder?.call() ??
                _buildDefaultEmptyWidget(context);
          }

          if (widget.constraints.maxWidth > minWidth) {
            return Scrollbar(
              controller: _verticalController,
              thumbVisibility: true,
              child: Container(
                constraints: tableConstraints,
                child: _buildListView(data: data, scrollable: false),
              ),
            );
          }

          return Scrollbar(
            controller: _verticalController,
            notificationPredicate: (notif) => notif.depth == 1,
            thumbVisibility: true,
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: minWidth,
                    child: _buildListView(data: data, scrollable: true),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.constraints.hasBoundedHeight) {
      return Flexible(child: tableContentContainer);
    } else {
      if (isCompactState) {
        return SizedBox(
          height: 100.0,
          child: tableContentContainer,
        );
      }
      if (currentContentHeight != null) {
        return SizedBox(
          height: currentContentHeight + 10,
          child: tableContentContainer,
        );
      }
      return tableContentContainer;
    }
  }

  Widget _buildDefaultLoadingWidget(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }

  Widget _buildDefaultEmptyWidget(BuildContext context) {
    final theme = Theme.of(context);
    final subtleColor =
        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5) ??
            theme.disabledColor;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 30,
            color: subtleColor,
          ),
          const SizedBox(height: 8),
          Text(
            context.appLocalizations.noResultsFound,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subtleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView({
    required List<T> data,
    required bool scrollable,
  }) {
    final dataTableTheme = context.watchDataTableTheme;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: DividerTheme(
        data: dataTableTheme?.dividerThemeData ?? const DividerThemeData(),
        child: ListView.separated(
          controller: _verticalController,
          itemCount: data.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) => TableRowWidget<T>(
            element: data[index],
            index: index,
            columns: widget.columns,
            toMap: widget.toMap,
            cell: widget.cell,
            rowBuilder: widget.rowBuilder,
            onTapRow: widget.onTapRow,
            scrollable: scrollable,
          ),
        ),
      ),
    );
  }
}
