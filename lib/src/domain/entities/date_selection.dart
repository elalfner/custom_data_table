import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/utils/date_time_extension.dart';
import 'package:custom_data_table/src/domain/enums/date_filter_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Represents a date selection with a specific filter type.
///
/// This class holds the selected date(s) and the type of date filter applied.
/// It provides a convenient way to get a formatted label for the selected date(s).
class DateSelection {
  /// The type of date filter applied.
  final DateFilterType dateFilterType;

  /// The selected date.
  final DateTime? date;

  /// The end date of the selected period.
  final DateTime? endDate;

  DateSelection({required this.dateFilterType, this.date, this.endDate});

  /// Returns a formatted label for the selected date(s).
  ///
  /// The label is formatted based on the [dateFilterType] and the selected
  /// [date] and [endDate].
  String? label(BuildContext context) {
    final date = this.date;

    // If the selected date is today, returns "Only today".
    if (dateFilterType == DateFilterType.date &&
        date?.onlyDate == DateTime.now().onlyDate) {
      return context.appLocalizations.onlyToday;
    }

    // If the selected date is not today, returns the formatted date.
    if (dateFilterType == DateFilterType.date &&
        date != null &&
        date.onlyDate != DateTime.now().onlyDate) {
      return DateFormat.yMd().format(date);
    }

    // If the selected date is a month, returns the formatted month.
    if (dateFilterType == DateFilterType.month && date != null) {
      return DateFormat.yMMMM().format(date);
    }

    // If the selected date is a year, returns the formatted year.
    if (dateFilterType == DateFilterType.year && date != null) {
      return DateFormat.y().format(date);
    }

    // If the selected date is a period, returns the formatted period.
    if (dateFilterType == DateFilterType.period &&
        date != null &&
        endDate != null) {
      return '${DateFormat.yMd().add_Hm().format(date)} - ${DateFormat.yMd().add_Hm().format(endDate!)}';
    }

    return null;
  }

  /// Checks if the selected date range represents a week.
  ///
  /// Returns `true` if the [date] is the start of the week and [endDate] is
  /// the end of the week, `false` otherwise.
  bool get isWeek {
    final date = this.date;
    if (date == null) return false;

    return date.startOfWeek == date && date.endOfWeek == endDate;
  }
}
