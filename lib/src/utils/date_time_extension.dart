import 'package:flutter/material.dart';

/// Funciones adicionales al DateTime.
extension DateExtension on DateTime {
  /// Deja la pura fecha y elimina el tiempo.
  DateTime get onlyDate => DateTime(year, month, day);

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
}
