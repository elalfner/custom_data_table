import 'package:custom_data_table/src/theme/row_theme.dart';
import 'package:flutter/material.dart';

export 'row_theme.dart';

class CustomDatatableThemeData {
  final double? dataRowHeight;

  final RowTheme? oddRowTheme;
  final RowTheme? evenRowTheme;

  final DividerThemeData? dividerThemeData;
  final double? dividerHeight;

  final BoxDecoration? tableDecoration;
  final BoxDecoration? headerDecoration;
  final BoxDecoration? columnHeaderDecoration;
  final BoxDecoration? columnSearchDecoration;
  final BoxDecoration? footerDecoration;

  final EdgeInsets? titlePadding;
  final EdgeInsets? columnHeaderPadding;
  final EdgeInsets? columnSearchPadding;
  final EdgeInsets? rowPadding;
  final EdgeInsets? footerPadding;
  final EdgeInsets? tableMargin;

  final InputDecorationThemeData? selectColumnsInputTheme;
  final InputDecorationThemeData? columnSearchInputTheme;
  final Widget? selectColumnsInputBackground;

  final TextStyle? titleTextStyle;
  final TextStyle? columnTitleTextStyle;
  final TextStyle? contentTextStyle;

  CustomDatatableThemeData({
    this.dataRowHeight,
    this.oddRowTheme,
    this.evenRowTheme,
    this.dividerThemeData,
    this.dividerHeight,
    this.tableDecoration,
    this.headerDecoration,
    this.columnHeaderDecoration,
    this.columnSearchDecoration,
    this.footerDecoration,
    this.titlePadding,
    this.columnHeaderPadding,
    this.columnSearchPadding,
    this.rowPadding,
    this.footerPadding,
    this.selectColumnsInputTheme,
    this.columnSearchInputTheme,
    this.selectColumnsInputBackground,
    this.titleTextStyle,
    this.columnTitleTextStyle,
    this.contentTextStyle,
    this.tableMargin,
  });

  CustomDatatableThemeData copyWith({
    double? dataRowHeight,
    RowTheme? oddRowTheme,
    RowTheme? evenRowTheme,
    DividerThemeData? dividerThemeData,
    double? dividerHeight,
    BoxDecoration? tableDecoration,
    BoxDecoration? headerDecoration,
    BoxDecoration? columnHeaderDecoration,
    BoxDecoration? columnSearchDecoration,
    BoxDecoration? footerDecoration,
    EdgeInsets? tablePadding,
    EdgeInsets? titlePadding,
    EdgeInsets? columnHeaderPadding,
    EdgeInsets? columnSearchPadding,
    EdgeInsets? rowPadding,
    EdgeInsets? footerPadding,
    EdgeInsets? tableMargin,
    InputDecorationThemeData? selectColumnsInputTheme,
    InputDecorationThemeData? columnSearchInputTheme,
    Widget? selectColumnsInputBackground,
    TextStyle? titleTextStyle,
    TextStyle? columnTitleTextStyle,
    TextStyle? contentTextStyle,
  }) =>
      CustomDatatableThemeData(
        dataRowHeight: dataRowHeight ?? this.dataRowHeight,
        oddRowTheme: oddRowTheme ?? this.oddRowTheme,
        evenRowTheme: evenRowTheme ?? this.evenRowTheme,
        dividerThemeData: dividerThemeData ?? this.dividerThemeData,
        dividerHeight: dividerHeight ?? this.dividerHeight,
        tableDecoration: tableDecoration ?? this.tableDecoration,
        headerDecoration: headerDecoration ?? this.headerDecoration,
        columnHeaderDecoration:
            columnHeaderDecoration ?? this.columnHeaderDecoration,
        columnSearchDecoration:
            columnSearchDecoration ?? this.columnSearchDecoration,
        footerDecoration: footerDecoration ?? this.footerDecoration,
        titlePadding: titlePadding ?? this.titlePadding,
        columnHeaderPadding: columnHeaderPadding ?? this.columnHeaderPadding,
        columnSearchPadding: columnSearchPadding ?? this.columnSearchPadding,
        rowPadding: rowPadding ?? this.rowPadding,
        footerPadding: footerPadding ?? this.footerPadding,
        tableMargin: tableMargin ?? this.tableMargin,
        selectColumnsInputTheme:
            selectColumnsInputTheme ?? this.selectColumnsInputTheme,
        columnSearchInputTheme:
            columnSearchInputTheme ?? this.columnSearchInputTheme,
        selectColumnsInputBackground:
            selectColumnsInputBackground ?? this.selectColumnsInputBackground,
        titleTextStyle: titleTextStyle ?? this.titleTextStyle,
        columnTitleTextStyle: columnTitleTextStyle ?? this.columnTitleTextStyle,
        contentTextStyle: contentTextStyle ?? this.contentTextStyle,
      );
}
