import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/utils/string_extension.dart';
import 'package:custom_data_table/src/domain/entities/filter_item.dart';
import 'package:custom_data_table/src/presentation/widgets/filter_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// A dialog widget for selecting filters.
///
/// This widget is used to display a list of filters that can be selected by the user.
/// It is a modal dialog that can be displayed by calling the [showDialog] method.
class SelectFiltersDialog extends StatelessWidget {
  /// The list of filters to display.
  final List<FilterSection> filters;

  const SelectFiltersDialog({super.key, required this.filters});

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: AlertDialog(
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
              child: Text(
                  context.appLocalizations.clearFilters.naturalCapitalized),
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
                      selectedFilters: section.selectedFilters,
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
      ),
    );
  }
}
