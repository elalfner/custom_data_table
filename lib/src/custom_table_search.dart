import 'package:collection/collection.dart';
import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';

import 'models/sort_info.dart';

class CustomTableSearch<T> extends StatefulWidget {
  // Search attributes.

  final List<ColumnInfo> columns;
  final List<FilterSection>? filterSections;

  final Function(List<ColumnId> values) onChangeSearchFields;

  final Function(List<FilterItem> values)? onChangeFilters;

  // Table attributes.

  final String? title;

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

  const CustomTableSearch(
      {Key? key,
      required this.columns,
      this.filterSections,
      this.onChangeFilters,
      required this.onChangeSearchFields,
      required this.data,
      required this.cell,
      required this.toMap,
      this.onElementPressed,
      required this.onSort,
      this.paginatorInfo,
      this.onPressedNext,
      this.onPressedLast,
      this.onCopy,
      this.onPrint,
      this.onExport,
      this.title})
      : super(key: key);

  @override
  State<CustomTableSearch<T>> createState() => _CustomTableSearchState<T>();
}

class _CustomTableSearchState<T> extends State<CustomTableSearch<T>> {
  Map<String, List<FilterItem>> selectedFiltersMap = {};

  List<FilterSection> get selectedFilters => selectedFiltersMap.entries
      .map((e) {
        final section = widget.filterSections?.firstWhereOrNull(
          (element) => element.columnInfo.key == e.key,
        );

        final newSection = section?.copyWith(filters: e.value);

        if (newSection == null) return newSection;

        for (final FilterItem filter in newSection.filters) {
          filter.columnInfo = newSection.columnInfo;
        }

        return newSection;
      })
      .where((element) => element != null)
      .map((e) => e!)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: SearchWidget(
            onFilterDeleted: (filterItem) {
              selectedFiltersMap[filterItem.columnInfo?.key]
                  ?.remove(filterItem);
              setState(() {});

              widget.onChangeFilters?.call(selectedFilters
                  .expand((element) => element.filters)
                  .toList());
            },
            onChangeSearchFields: widget.onChangeSearchFields,
            columns: widget.columns
                .map((e) => ColumnId(name: e.name, key: e.key))
                .where((element) => element.name.isNotEmpty == true)
                .toList(),
            filterItems:
                selectedFilters.expand((element) => element.filters).toList(),
            onFilterPressed: widget.filterSections?.isNotEmpty == true
                ? filterPressed
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: CustomDataTable<T>(
            onSort: widget.onSort,
            toMap: widget.toMap,
            data: widget.data,
            cell: widget.cell,
            columns: widget.columns,
            onPrint: widget.onPrint,
            onExport: widget.onExport,
            onCopy: widget.onCopy,
            onElementPressed: widget.onElementPressed,
            title: widget.title,
            onPressedLast: widget.onPressedLast,
            onPressedNext: widget.onPressedNext,
            paginatorInfo: widget.paginatorInfo,
            onFilterPressed: widget.filterSections?.isNotEmpty == true
                ? filterPressed
                : null,
          ),
        ),
      ],
    );
  }

  void filterPressed() {
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(
        maxWidth: 500,
        minWidth: 500,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final FilterSection section in widget.filterSections ?? [])
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: FilterSectionWidget(
                    section: section,
                    selectedFilters: selectedFiltersMap[section.columnInfo.key],
                    onChange: (values) {
                      selectedFiltersMap[section.columnInfo.key] = [...values];

                      setState(() {});

                      widget.onChangeFilters?.call(selectedFilters
                          .expand((element) => element.filters)
                          .toList());
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
