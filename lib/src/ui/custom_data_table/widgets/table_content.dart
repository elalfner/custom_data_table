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

  /// Whether the table is currently in an error state.
  ///
  /// When specified, explicitly controls error evaluation regardless of [data].
  /// When null (omitted), falls back to legacy evaluation `(data == null && !isLoading)`.
  final bool? hasError;

  /// The error or exception object to pass to [errorBuilder] and [errorBannerBuilder].
  final Object? error;

  /// Custom builder for initial/idle state when data is null, not loading, and not in error.
  final Widget Function()? initialBuilder;

  /// Custom builder for error state receiving [BuildContext] and [error] payload.
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  /// Custom builder for error/empty state when data is null and not loading.
  @Deprecated('Use errorBuilder instead. Will be removed in future versions.')
  final Widget Function()? exceptionBuilder;

  /// Whether to display an error banner above rows when an error occurs while data is loaded.
  final bool showErrorBanner;

  /// Custom builder for the error banner displayed above data rows.
  final Widget Function(BuildContext context, Object? error)?
      errorBannerBuilder;

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
    this.hasError,
    this.error,
    this.initialBuilder,
    this.errorBuilder,
    this.exceptionBuilder,
    this.showErrorBanner = false,
    this.errorBannerBuilder,
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

  bool get _computeHasError =>
      widget.hasError ?? (widget.data == null && !widget.isLoading);

  Widget _buildErrorState(BuildContext context, Object? error) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error);
    }
    // ignore: deprecated_member_use_from_same_package
    if (widget.exceptionBuilder != null) {
      // ignore: deprecated_member_use_from_same_package
      return widget.exceptionBuilder!();
    }
    return const SizedBox();
  }

  Widget _buildDefaultErrorBanner(BuildContext context, Object? error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rowMinHeight = context.watchDataTableTheme?.dataRowHeight ?? 38.0;
    final errorMessage = error != null
        ? error.toString()
        : 'An error occurred while loading data.';

    return Container(
      height: rowMinHeight,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 18,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
    final isError = _computeHasError;

    double? currentContentHeight;
    if (data != null) {
      currentContentHeight = calculateContentHeight(
        itemCount: data.length,
        minRowHeight: rowMinHeight,
        dividerHeight: dividerHeight,
      );
    }

    final isCompactState = (data != null && data.isEmpty) ||
        (data == null && widget.isLoading && !isError);

    final bannerExtraHeight =
        (data != null && isError && widget.showErrorBanner)
            ? rowMinHeight
            : 0.0;

    final tableContentContainer = Container(
      constraints: isCompactState
          ? const BoxConstraints(maxHeight: 100.0)
          : (currentContentHeight == null || (data == null && isError)
              ? null
              : BoxConstraints(
                  maxHeight: currentContentHeight + 10 + bannerExtraHeight,
                )),
      child: Builder(
        builder: (context) {
          if (data == null) {
            if (isError) {
              return _buildErrorState(context, widget.error);
            }
            if (widget.isLoading) {
              return widget.loadingBuilder?.call() ??
                  _buildDefaultLoadingWidget(context);
            }
            return widget.initialBuilder?.call() ?? const SizedBox();
          }

          if (data.isEmpty) {
            return widget.emptyBuilder?.call() ??
                _buildDefaultEmptyWidget(context);
          }

          Widget listView;
          if (widget.constraints.maxWidth > minWidth) {
            listView = Scrollbar(
              controller: _verticalController,
              thumbVisibility: true,
              child: Container(
                constraints: tableConstraints,
                child: _buildListView(data: data, scrollable: false),
              ),
            );
          } else {
            listView = Scrollbar(
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
          }

          if (isError && widget.showErrorBanner) {
            final banner =
                widget.errorBannerBuilder?.call(context, widget.error) ??
                    _buildDefaultErrorBanner(context, widget.error);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                banner,
                Expanded(child: listView),
              ],
            );
          }

          return listView;
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
          height: currentContentHeight + 10 + bannerExtraHeight,
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
