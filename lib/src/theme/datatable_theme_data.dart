import 'package:custom_data_table/src/theme/row_theme.dart';
import 'package:flutter/material.dart';

export 'row_theme.dart';

class CustomDatatableThemeData {
  final RowTheme? oddRowTheme;
  final RowTheme? evenRowTheme;
  final DividerThemeData? dividerThemeData;
  final BoxDecoration? tableDecoration;
  final BoxDecoration? columnHeaderDecoration;
  final BoxDecoration? headerDecoration;
  final BoxDecoration? footerDecoration;
  final BoxDecoration? columnSearchDecoration;
  final EdgeInsets? contentPadding;
  final TextStyle? columnTitleTextStyle;
  final double? dataRowMinHeight;
  final InputDecorationTheme? selectColumnsInputTheme;
  final Widget? selectColumnsInputBackground;

  CustomDatatableThemeData({
    this.oddRowTheme,
    this.evenRowTheme,
    this.dividerThemeData,
    this.tableDecoration,
    this.columnHeaderDecoration,
    this.headerDecoration,
    this.footerDecoration,
    this.columnSearchDecoration,
    this.contentPadding,
    this.columnTitleTextStyle,
    this.dataRowMinHeight,
    this.selectColumnsInputTheme,
    this.selectColumnsInputBackground,
  });
}
