import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/domain/models/date_selection.dart';
import 'package:custom_data_table/src/utils/string_extension.dart';
import 'package:flutter/material.dart';

import 'date_filter_dialog.dart';

export 'date_filter_dialog.dart' show showCustomDateFilters, DateFilterDialog;

/// Callback function that is called when the date filter is changed.
typedef ChangeDateCallback = void Function(DateSelection? dateFilter);

/// A widget that displays a chip to filter dates.
///
/// This widget is used to display a chip to filter dates.
class DatesFilterChip extends StatelessWidget {
  /// The date filter.
  final DateSelection? dateFilter;

  /// The first date to filter.
  final DateTime? firstDate;

  /// The last date to filter.
  final DateTime? lastDate;

  /// The callback function that is called when the date filter is changed.
  final ChangeDateCallback? onChangeDateFilter;

  /// The callback function that is called when the date filter is tapped.
  final VoidCallback? onTapDateFilter;

  const DatesFilterChip({
    Key? key,
    this.dateFilter,
    this.onChangeDateFilter,
    this.onTapDateFilter,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      elevation: 1,
      label: Text(
        context.appLocalizations.filterDates.naturalCapitalized,
        style: TextStyle(
          color: Theme.of(context).floatingActionButtonTheme.foregroundColor,
        ),
      ),
      avatar: Icon(
        Icons.calendar_month,
        color: Theme.of(context).floatingActionButtonTheme.foregroundColor,
      ),
      backgroundColor:
          Theme.of(context).floatingActionButtonTheme.backgroundColor,
      onPressed: () async {
        onTapDateFilter?.call();

        final customDateFilters = await showCustomDateFilters(
          context,
          initialDateFilter: dateFilter,
          firstDate: firstDate,
          lastDate: lastDate,
        );

        onChangeDateFilter?.call(customDateFilters);
      },
    );
  }
}
