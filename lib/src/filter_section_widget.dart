import 'package:custom_data_table/src/models/filter_item.dart';
import 'package:flutter/material.dart';

class FilterSectionWidget<T> extends StatefulWidget {
  final FilterSection<T> section;

  final Function(List<FilterItem<T>> values) onChange;

  final List<FilterItem<T>>? selectedFilters;

  final bool showTitle;

  const FilterSectionWidget({
    Key? key,
    required this.section,
    required this.onChange,
    this.selectedFilters,
    this.showTitle = true,
  }) : super(key: key);

  @override
  State<FilterSectionWidget<T>> createState() => _FilterSectionWidgetState<T>();
}

class _FilterSectionWidgetState<T> extends State<FilterSectionWidget<T>> {
  FilterSection<T> get section => widget.section;

  List<FilterItem<T>> get filters => section.filters;

  late Set selected = {};

  List<FilterItem<T>> get selectedFilters => filters
      .where((element) => selected.contains(element.filterName))
      .toList();

  @override
  void initState() {
    selected = {for (final f in widget.selectedFilters ?? []) f.filterName};

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          Text(section.columnInfo.name),
          const SizedBox(height: 5),
        ],
        Wrap(
          runSpacing: 5,
          spacing: 5,
          children: [
            for (final filter in filters) filterWidget(filter),
          ],
        )
      ],
    );
  }

  Widget filterWidget(FilterItem filter) {
    return FilterChip(
      label: Text(filter.filterName),
      selected: selected.contains(filter.filterName),
      onSelected: (value) {
        if (value) {
          selected.add(filter.filterName);
        } else {
          selected.remove(filter.filterName);
        }

        setState(() {});

        widget.onChange(selectedFilters);
      },
    );
  }
}
