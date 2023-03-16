import 'package:custom_data_table/src/models/filter_item.dart';
import 'package:flutter/material.dart';

class FilterSectionWidget extends StatefulWidget {
  final FilterSection section;

  final Function(List<FilterItem> values) onChange;

  final List<FilterItem>? selectedFilters;

  const FilterSectionWidget({
    Key? key,
    required this.section,
    required this.onChange,
    this.selectedFilters,
  }) : super(key: key);

  @override
  State<FilterSectionWidget> createState() => _FilterSectionWidgetState();
}

class _FilterSectionWidgetState extends State<FilterSectionWidget> {
  FilterSection get section => widget.section;

  List<FilterItem> get filters => section.filters;

  late Map<String, bool?> selectedMap = {};

  List<FilterItem> get selectedFilters => filters
      .where((element) => selectedMap[element.filterName] == true)
      .toList();

  @override
  void initState() {
    selectedMap = {
      for (final f in widget.selectedFilters ?? []) f.filterName: true
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.columnInfo.name),
        const SizedBox(height: 5),
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
    final selected = selectedMap[filter.filterName] == true;

    return Material(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          selectedMap[filter.filterName] = !selected;
          setState(() {});

          widget.onChange(selectedFilters);
        },
        child: Container(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: selected,
                onChanged: (value) {
                  selectedMap[filter.filterName] = value;
                  setState(() {});

                  widget.onChange(selectedFilters);
                },
              ),
              Text(filter.filterName),
            ],
          ),
        ),
      ),
    );
  }
}
