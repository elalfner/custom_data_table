import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/utils/date_time_extension.dart';
import 'package:custom_data_table/src/domain/enums/date_filter_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelection {
  DateFilterType? dateFilterType;

  DateTime? date;
  DateTime? endDate;

  DateSelection({this.dateFilterType, this.date, this.endDate});

  String? label(BuildContext context) {
    if (dateFilterType == DateFilterType.date &&
        date?.onlyDate == DateTime.now().onlyDate) {
      return context.appLocalizations.onlyToday;
    }

    if (dateFilterType == DateFilterType.date &&
        date != null &&
        date?.onlyDate != DateTime.now().onlyDate) {
      return DateFormat.yMd().format(date!);
    }

    if (dateFilterType == DateFilterType.month && date != null) {
      return DateFormat.yMMMM().format(date!);
    }

    if (dateFilterType == DateFilterType.year && date != null) {
      return DateFormat.y().format(date!);
    }

    if (dateFilterType == DateFilterType.period &&
        date != null &&
        endDate != null) {
      return '${DateFormat.yMd().add_Hm().format(date!)} - ${DateFormat.yMd().add_Hm().format(endDate!)}';
    }

    return null;
  }

  bool get isWeek {
    final date = this.date;
    if (date == null) return false;

    return date.startOfWeek == date && date.endOfWeek == endDate;
  }
}
