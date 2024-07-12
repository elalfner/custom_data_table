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
  final TextStyle? tableTitleTextStyle;

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
    this.tableTitleTextStyle,
  });

  CustomDatatableThemeData copyWith({
    RowTheme? oddRowTheme,
    RowTheme? evenRowTheme,
    DividerThemeData? dividerThemeData,
    BoxDecoration? tableDecoration,
    BoxDecoration? columnHeaderDecoration,
    BoxDecoration? headerDecoration,
    BoxDecoration? footerDecoration,
    BoxDecoration? columnSearchDecoration,
    EdgeInsets? contentPadding,
    TextStyle? columnTitleTextStyle,
    double? dataRowMinHeight,
    InputDecorationTheme? selectColumnsInputTheme,
    Widget? selectColumnsInputBackground,
    TextStyle? tableTitleTextStyle,
  }) =>
      CustomDatatableThemeData(
        oddRowTheme: oddRowTheme ?? this.oddRowTheme,
        evenRowTheme: evenRowTheme ?? this.evenRowTheme,
        dividerThemeData: dividerThemeData ?? this.dividerThemeData,
        tableDecoration: tableDecoration ?? this.tableDecoration,
        columnHeaderDecoration:
            columnHeaderDecoration ?? this.columnHeaderDecoration,
        headerDecoration: headerDecoration ?? this.headerDecoration,
        footerDecoration: footerDecoration ?? this.footerDecoration,
        columnSearchDecoration:
            columnSearchDecoration ?? this.columnSearchDecoration,
        contentPadding: contentPadding ?? this.contentPadding,
        columnTitleTextStyle: columnTitleTextStyle ?? this.columnTitleTextStyle,
        dataRowMinHeight: dataRowMinHeight ?? this.dataRowMinHeight,
        selectColumnsInputTheme:
            selectColumnsInputTheme ?? this.selectColumnsInputTheme,
        selectColumnsInputBackground:
            selectColumnsInputBackground ?? this.selectColumnsInputBackground,
        tableTitleTextStyle: tableTitleTextStyle ?? this.tableTitleTextStyle,
      );
}
