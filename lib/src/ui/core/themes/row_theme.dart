import 'package:flutter/material.dart';

/// Theme for the rows of the data table.
class RowTheme {
  /// The decoration of the row.
  final BoxDecoration? decoration;

  /// The margin of the row.
  final EdgeInsets? margin;

  /// The hover color of the row.
  final Color? hoverColor;

  RowTheme({this.decoration, this.margin, this.hoverColor});
}
