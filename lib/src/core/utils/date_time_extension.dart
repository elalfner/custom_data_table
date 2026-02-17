import 'package:flutter/material.dart';

/// Funciones adicionales al DateTime.
extension DateExtension on DateTime {
  /// Deja la pura fecha y elimina el tiempo.
  DateTime get onlyDate => DateTime(year, month, day);

  DateTime get onlyMonth => DateTime(year, month);

  DateTime get onlyYear => DateTime(year);

  /// Deja solo el tiempo y elimina la fecha.
  DateTime get onlyTime => DateTime(0, 0, 0, hour, minute, second);

  /// Deja solo el tiempo y lo convierte a [TimeOfDay].
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  bool isBetween(DateTime? from, DateTime? to) {
    if (from == null || to == null) return false;

    return from.isBefore(this) && to.isAfter(this);
  }

  bool isBetweenIncluding(DateTime? from, DateTime? to) {
    if (from == null || to == null) return false;

    return from == this ||
        to == this ||
        from.isBefore(this) && to.isAfter(this);
  }

  DateTime get endOfDay => onlyDate
      .add(const Duration(days: 1))
      .subtract(const Duration(milliseconds: 1));

  DateTime get endOfMonth => onlyDate
      .copyWith(month: month + 1)
      .subtract(const Duration(milliseconds: 1));

  DateTime get endOfYear => onlyDate
      .copyWith(year: year + 1)
      .subtract(const Duration(milliseconds: 1));

  DateTime get startOfWeek => onlyDate.subtract(Duration(days: weekday - 1));

  DateTime get endOfWeek => startOfWeek
      .add(const Duration(days: DateTime.daysPerWeek))
      .subtract(const Duration(milliseconds: 1));
}
