import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/domain/models/column_info.dart';
import 'package:custom_data_table/src/domain/models/date_selection.dart';
import 'package:custom_data_table/src/domain/models/filter_section.dart';
import 'package:custom_data_table/src/ui/core/themes/datatable_theme.dart';
import 'package:custom_data_table/src/ui/core/ui/date_filter/dates_filter_chip.dart';
import 'package:custom_data_table/src/ui/core/ui/filters/select_filters_dialog.dart';
import 'package:custom_data_table/src/ui/core/ui/filters/selected_filters_widget.dart';
import 'package:custom_data_table/src/ui/custom_data_table/widgets/select_columns_dialog.dart';
import 'package:custom_data_table/src/utils/debounce.dart';
import 'package:custom_data_table/src/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Top toolbar widget that encapsulates column visibility selection,
/// action buttons (copy, print, export), filter and date dialog triggers,
/// and debounced general search input.
class TableHeader<T> extends StatefulWidget {
  /// All available columns defined in the table.
  final List<ColumnInfo> columns;

  /// The currently visible columns in the table.
  final List<ColumnInfo> selectedColumns;

  /// Callback invoked when the user updates column visibility in the dialog.
  final ValueChanged<List<ColumnInfo>>? onSelectedColumnsChanged;

  /// Current table data, used for clipboard copying.
  final List<T>? data;

  /// Map converter function for rows, used for clipboard copying.
  final Map<String, dynamic> Function(T element)? toMap;

  /// Filter sections displayed in the filter dialog and chips.
  final List<FilterSection>? filterSections;

  /// Callback invoked when filter sections are updated.
  final ValueChanged<List<FilterSection>>? onChangeFilters;

  /// Initial or current date filter selection.
  final DateSelection? initialDateFilter;

  /// First allowed date for the date range picker.
  final DateTime? firstDate;

  /// Last allowed date for the date range picker.
  final DateTime? lastDate;

  /// Callback invoked when the date filter changes.
  final ChangeDateCallback? onChangeDateFilter;

  /// Callback invoked when the copy button is pressed.
  final VoidCallback? onCopy;

  /// Whether the copy button is enabled when data is available.
  final bool canCopy;

  /// Callback invoked when the print menu item is pressed.
  final VoidCallback? onPrint;

  /// Callback invoked when the export button is pressed.
  final VoidCallback? onExport;

  /// Optional text controller for general search.
  final TextEditingController? generalSearchController;

  /// Callback invoked when general search text changes (debounced).
  final ValueChanged<String>? onChangeGeneralSearch;

  /// Debounce duration for the general search bar.
  final Duration debounceDuration;

  /// Debouncer for the general search bar.
  final TableDebouncer? debouncer;

  const TableHeader({
    super.key,
    required this.columns,
    required this.selectedColumns,
    this.onSelectedColumnsChanged,
    this.data,
    this.toMap,
    this.filterSections,
    this.onChangeFilters,
    this.initialDateFilter,
    this.firstDate,
    this.lastDate,
    this.onChangeDateFilter,
    this.onCopy,
    this.canCopy = true,
    this.onPrint,
    this.onExport,
    this.generalSearchController,
    this.onChangeGeneralSearch,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.debouncer,
  });

  @override
  State<TableHeader<T>> createState() => _TableHeaderState<T>();
}

class _TableHeaderState<T> extends State<TableHeader<T>> {
  final ScrollController _headerScroll = ScrollController();
  late final TableDebouncer _debouncer;
  TextEditingController? _internalSearchController;
  late TextEditingController _searchController;
  bool _searching = false;
  DateSelection? _dateFilter;

  @override
  void initState() {
    super.initState();
    _debouncer = widget.debouncer ??
        TableDebouncer(milliseconds: widget.debounceDuration.inMilliseconds);
    _dateFilter = widget.initialDateFilter;

    if (widget.generalSearchController != null) {
      _searchController = widget.generalSearchController!;
      if (_searchController.text.isNotEmpty) {
        _searching = true;
      }
    } else {
      _internalSearchController = TextEditingController();
      _searchController = _internalSearchController!;
    }
  }

  @override
  void didUpdateWidget(covariant TableHeader<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDateFilter != oldWidget.initialDateFilter) {
      _dateFilter = widget.initialDateFilter;
    }
    if (widget.generalSearchController != oldWidget.generalSearchController) {
      if (widget.generalSearchController != null) {
        _searchController = widget.generalSearchController!;
      } else {
        _internalSearchController ??= TextEditingController();
        _searchController = _internalSearchController!;
      }
    }
  }

  @override
  void dispose() {
    _headerScroll.dispose();
    _internalSearchController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchDataTableTheme;
    final headerDecoration = theme?.headerDecoration;
    final padding = theme?.headerPadding;
    final filters = widget.filterSections;
    final data = widget.data;

    final showExportButton = widget.onExport != null ||
        widget.onPrint != null ||
        widget.onCopy != null;

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
                            columns: widget.columns,
                            selectedColumns: widget.selectedColumns,
                          ),
                        );

                        if (!mounted) return;

                        if (newSelectedColumns is List<ColumnInfo>) {
                          widget.onSelectedColumnsChanged
                              ?.call(newSelectedColumns);
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

                // Filters, actions, and search bar.
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
                                onPressed: () => _showFilters(filters),
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
                                isLabelVisible: _dateFilter != null,
                                child: TextButton.icon(
                                  style: IconButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  label: Text(context.appLocalizations
                                      .filterDates.naturalCapitalized),
                                  onPressed: _showDateFilters,
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
                              tooltip: context
                                  .appLocalizations.copy.naturalCapitalized,
                              style: IconButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: widget.onCopy ?? _copyToClipboard,
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
                          if (_searching)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: SizedBox(
                                width: 250,
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: context.appLocalizations.search
                                        .naturalCapitalized,
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        setState(() {
                                          _searching = false;
                                        });
                                        _searchController.clear();
                                        widget.onChangeGeneralSearch?.call('');
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) => _debouncer.run(
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
                                  setState(() {
                                    _searching = true;
                                  });
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

          // Selected filters chips.
          if (filters != null || _dateFilter != null)
            Container(
              padding: padding?.copyWith(top: 0, bottom: 0),
              child: SelectedFiltersWidget(
                selectedFilters: filters,
                dateFilter: _dateFilter,
                onChange: widget.onChangeFilters,
                onDateFilterClear: () {
                  setState(() {
                    _dateFilter = null;
                  });
                  widget.onChangeDateFilter?.call(null);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showFilters(List<FilterSection> filters) async {
    final newFilters = await showDialog(
      context: context,
      builder: (context) => SelectFiltersDialog(
        filters: filters,
      ),
    );

    if (!mounted) return;

    if (newFilters is! List<FilterSection>) {
      return;
    }

    widget.onChangeFilters?.call(newFilters);
  }

  void _showDateFilters() async {
    final customDateFilters = await showCustomDateFilters(
      context,
      initialDateFilter: _dateFilter,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (!mounted) return;

    widget.onChangeDateFilter?.call(customDateFilters);
    setState(() {
      _dateFilter = customDateFilters;
    });
  }

  Future<void> _copyToClipboard() async {
    final columnsToShow = widget.selectedColumns;
    final data = widget.data;
    if (data == null || data.isEmpty || widget.toMap == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final appLocalizations = context.appLocalizations;

    final copyValue = [
      [
        for (final column in columnsToShow) column.name,
      ].join('\t'),
      for (final element in data)
        [
          for (final column in columnsToShow)
            '${widget.toMap!(element)[column.key] ?? ''}'.replaceAll('\n', ' '),
        ].join('\t'),
    ].join('\n');

    try {
      await Clipboard.setData(ClipboardData(text: copyValue));
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(appLocalizations.copiedToClipboard),
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('PlatformException during clipboard copy: $e');
    } catch (e) {
      debugPrint('Error during clipboard copy: $e');
    }
  }
}
