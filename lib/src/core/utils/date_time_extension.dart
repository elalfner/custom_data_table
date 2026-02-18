import 'package:flutter/material.dart';

/// Funciones adicionales al DateTime.
extension DateExtension on DateTime {
  /// Deja la pura fecha y elimina el tiempo.
  DateTime get onlyDate => DateTime(year, month, day);

  /// Deja solo el mes y año.
  DateTime get onlyMonth => DateTime(year, month);

  /// Deja solo el año.
  DateTime get onlyYear => DateTime(year);

  /// Deja solo el tiempo y elimina la fecha.
  DateTime get onlyTime => DateTime(0, 0, 0, hour, minute, second);

  /// Deja solo el tiempo y lo convierte a [TimeOfDay].
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  /// Comprueba si la fecha proporcionada esta entre dos fechas.
  ///
  /// [from] fecha inicial.
  /// [to] fecha final.
  ///
  /// Devuelve `true` si esta entre las dos fechas.
  bool isBetween(DateTime? from, DateTime? to) {
    if (from == null || to == null) return false;

    return from.isBefore(this) && to.isAfter(this);
  }

  /// Comprueba si la fecha proporcionada esta entre dos fechas incluyendo
  /// las fechas de inicio y fin.
  ///
  /// [from] fecha inicial.
  /// [to] fecha final.
  ///
  /// Devuelve `true` si esta entre las dos fechas incluyendo las fechas de
  /// inicio y fin.
  bool isBetweenIncluding(DateTime? from, DateTime? to) {
    if (from == null || to == null) return false;

    return from == this ||
        to == this ||
        from.isBefore(this) && to.isAfter(this);
  }

  /// Devuelve la fecha final del dia.
  DateTime get endOfDay => onlyDate
      .add(const Duration(days: 1))
      .subtract(const Duration(milliseconds: 1));

  /// Devuelve la fecha final del mes.
  DateTime get endOfMonth => onlyDate
      .copyWith(month: month + 1)
      .subtract(const Duration(milliseconds: 1));

  /// Devuelve la fecha final del año.
  DateTime get endOfYear => onlyDate
      .copyWith(year: year + 1)
      .subtract(const Duration(milliseconds: 1));

  /// Devuelve la fecha inicial de la semana.
  ///
  /// La semana empieza el dia lunes.
  ///
  /// Ejemplo:
  /// ```dart
  /// final date = DateTime(2022, 1, 1);
  /// final startOfWeek = date.startOfWeek;
  /// ```
  ///
  /// Devuelve `DateTime(2022, 1, 1)`.
  ///
  /// Otro ejemplo:
  /// ```dart
  /// final date = DateTime(2022, 1, 2);
  /// final startOfWeek = date.startOfWeek;
  /// ```
  ///
  /// Devuelve `DateTime(2022, 1, 1)`.
  DateTime get startOfWeek => onlyDate.subtract(Duration(days: weekday - 1));

  /// Devuelve la fecha final de la semana.
  ///
  /// La semana termina el dia domingo.
  ///
  /// Ejemplo:
  /// ```dart
  /// final date = DateTime(2022, 1, 1);
  /// final endOfWeek = date.endOfWeek;
  /// ```
  ///
  /// Devuelve `DateTime(2022, 1, 7)`.
  DateTime get endOfWeek => startOfWeek
      .add(const Duration(days: DateTime.daysPerWeek))
      .subtract(const Duration(milliseconds: 1));
}
