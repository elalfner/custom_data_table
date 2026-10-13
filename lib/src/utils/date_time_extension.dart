import 'package:flutter/material.dart';

/// Extension methods for [DateTime] utilities used internally by table filters.
extension CdtDateExtension on DateTime {
  /// Strips time components and returns only the date portion (midnight).
  DateTime get onlyDate => DateTime(year, month, day);

  /// Strips day and time components, returning only the year and month.
  DateTime get onlyMonth => DateTime(year, month);

  /// Strips month, day, and time components, returning only the year.
  DateTime get onlyYear => DateTime(year);

  /// Converts the time portion into a [TimeOfDay] instance.
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  /// Returns the end of the day (`23:59:59.999`).
  DateTime get endOfDay => onlyDate
      .add(const Duration(days: 1))
      .subtract(const Duration(milliseconds: 1));

  /// Returns the end of the month (`YYYY-MM-lastDay 23:59:59.999`).
  DateTime get endOfMonth => onlyMonth
      .copyWith(month: month + 1)
      .subtract(const Duration(milliseconds: 1));

  /// Returns the end of the year (`YYYY-12-31 23:59:59.999`).
  DateTime get endOfYear => onlyYear
      .copyWith(year: year + 1)
      .subtract(const Duration(milliseconds: 1));

  /// Returns the start of the week (Monday at midnight).
  DateTime get startOfWeek => onlyDate.subtract(Duration(days: weekday - 1));

  /// Returns the end of the week (Sunday at `23:59:59.999`).
  DateTime get endOfWeek => startOfWeek
      .add(const Duration(days: DateTime.daysPerWeek))
      .subtract(const Duration(milliseconds: 1));
}
