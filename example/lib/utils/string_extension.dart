import 'dart:convert';

extension StringExtension on String {
  String get naturalCapitalized => toLowerCase().replaceAllMapped(
        RegExp("(^|\\.\\s)(\\w)"),
        (match) => "${match.group(1)}${match.group(2)?.toUpperCase()}",
      );

  String? get validatorLeesThan255 {
    final value = this;
    value.trim();
    if (value.isEmpty) {
      return "El campo es obligatorio.";
    }

    if (value.length > 255) {
      return "No debe ser mayor a 255 caracteres.";
    }

    if (RegExp(
      "^[ ]",
    ).hasMatch(this)) {
      return "No se aceptan espacios en blanco al inicio.";
    }

    return null;
  }

  String get convertStringToCode => base64Url.encode(utf8.encode(this));

  String get convertCodeToString => utf8.decode(base64Url.decode(this));

  List<String> splitFirstOccurrence(Pattern pattern) {
    final index = indexOf(pattern);

    if (index < 0) return [this];

    return [
      substring(0, index),
      substring(index + 1),
    ];
  }
}
