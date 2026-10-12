import 'package:custom_data_table/src/domain/models/filter_section.dart';
import 'package:flutter/material.dart';

import 'filter_section_widget.dart';

/// A widget that displays the selected filters.
///
/// This widget is used to display the selected filters in a list of chips.
/// It contains the buttons to open the filters view and the date filter.
class FiltersView extends StatelessWidget {
  /// The list of filter sections.
  final List<FilterSection> sections;

  /// The callback function that is called when the selected filters are changed.
  final Function(List<FilterSection> sections)? onChange;

  /// Whether to show the title of the filters.
  final bool showTitle;

  const FiltersView({
    Key? key,
    required this.sections,
    this.onChange,
    this.showTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final section in sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FilterSectionWidget(
              section: section,
              selectedFilters: [
                for (final section in sections) ...section.selectedFilters ?? []
              ],
              showTitle: showTitle,
              onChange: (values) {
                section.selectedFilters = values;

                onChange?.call(sections);
              },
            ),
          ),
      ],
    );
  }
}
