/// String extension providing internal table string operations.
extension CdtStringExtension on String {
  /// Returns the string with the first letter of each word capitalized.
  ///
  /// Example:
  /// ```dart
  /// final string = "hello world";
  /// final capitalized = string.naturalCapitalized;
  /// print(capitalized); // "Hello World"
  /// ```
  String get naturalCapitalized => toLowerCase().replaceAllMapped(
        RegExp(r'(^|\.\s)(\w)'),
        (match) => '${match.group(1)}${match.group(2)?.toUpperCase()}',
      );
}
