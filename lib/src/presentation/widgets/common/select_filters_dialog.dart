import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/utils/string_extension.dart';
import 'package:custom_data_table/src/domain/entities/filter_item.dart';
import 'package:custom_data_table/src/presentation/widgets/filter_section_widget.dart';
import 'package:flutter/material.dart';

class SelectFiltersDialog extends StatelessWidget {
  final List<FilterSection> filters;

  final Function(List<FilterSection> selectedFilters)? onChange;

  const SelectFiltersDialog({super.key, required this.filters, this.onChange});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              context.appLocalizations.filter.naturalCapitalized,
              style: Theme.of(context).textTheme.titleLarge,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
          TextButton(
            onPressed: () {
              for (final section in filters) {
                section.selectedFilters = null;
              }
              Navigator.pop(context, filters);
            },
            child:
                Text(context.appLocalizations.clearFilters.naturalCapitalized),
          ),
        ],
      ),
      content: SizedBox(
        width: 350,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final section in filters)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: FilterSectionWidget(
                    section: section,
                    selectedFilters: [
                      for (final section in filters)
                        ...section.selectedFilters ?? []
                    ],
                    onChange: (values) => section.selectedFilters = values,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context, filters),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
