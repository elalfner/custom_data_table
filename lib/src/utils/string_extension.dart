import 'dart:convert';

/// String extension to provide additional string operations.
extension StringExtension on String {
  /// Returns the string with the first letter of each word capitalized.
  ///
  /// Example:
  /// ```dart
  /// final string = "hello world";
  /// final capitalized = string.naturalCapitalized;
  /// print(capitalized); // "Hello World"
  /// ```
  String get naturalCapitalized => toLowerCase().replaceAllMapped(
        RegExp("(^|\\.\\s)(\\w)"),
        (match) => "${match.group(1)}${match.group(2)?.toUpperCase()}",
      );

  /// Returns the string encoded in base64Url.
  ///
  /// Example:
  /// ```dart
  /// final string = "hello world";
  /// final encoded = string.convertStringToCode;
  /// print(encoded); // "aGVsbG8gd29ybGQ="
  /// ```
  String get convertStringToCode => base64Url.encode(utf8.encode(this));

  /// Returns the string decoded from base64Url.
  ///
  /// Example:
  /// ```dart
  /// final string = "aGVsbG8gd29ybGQ=";
  /// final decoded = string.convertCodeToString;
  /// print(decoded); // "hello world"
  /// ```
  String get convertCodeToString => utf8.decode(base64Url.decode(this));

  /// Splits the string at the first occurrence of the pattern.
  ///
  /// Example:
  /// ```dart
  /// final string = "hello world, hi!";
  /// final split = string.splitFirstOccurrence("");
  /// print(split); // ["hello", "world, hi!"]
  /// ```
  List<String> splitFirstOccurrence(Pattern pattern) {
    final index = indexOf(pattern);

    if (index < 0) return [this];

    return [
      substring(0, index),
      substring(index + 1),
    ];
  }
}
