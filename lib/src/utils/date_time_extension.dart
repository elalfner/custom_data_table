import 'package:flutter/material.dart';

/// Extension methods for [DateTime] utilities.
extension DateExtension on DateTime {
  /// Strips time components and returns only the date portion (midnight).
  DateTime get onlyDate => DateTime(year, month, day);

  /// Strips day and time components, returning only the year and month.
  DateTime get onlyMonth => DateTime(year, month);

  /// Strips month, day, and time components, returning only the year.
  DateTime get onlyYear => DateTime(year);

  /// Strips date components and returns only the time portion.
  DateTime get onlyTime => DateTime(0, 0, 0, hour, minute, second);

  /// Converts the time portion into a [TimeOfDay] instance.
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  /// Checks if this date falls strictly between [from] and [to].
  ///
  /// Returns `true` if this date is after [from] and before [to].
  bool isBetween(DateTime? from, DateTime? to) {
    if (from == null || to == null) return false;

    return from.isBefore(this) && to.isAfter(this);
  }

  /// Checks if this date falls between [from] and [to], inclusive of boundaries.
  ///
  /// Returns `true` if this date is equal to [from], equal to [to],
  /// or strictly between them.
  bool isBetweenIncluding(DateTime? from, DateTime? to) {
    if (from == null || to == null) return false;

    return from == this ||
        to == this ||
        from.isBefore(this) && to.isAfter(this);
  }

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
