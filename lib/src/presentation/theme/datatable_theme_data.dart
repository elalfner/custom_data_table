import 'package:custom_data_table/src/presentation/theme/row_theme.dart';
import 'package:flutter/material.dart';

export 'row_theme.dart';

/// Theme data for the custom data table.
///
/// It is used to style the custom data table.
class CustomDatatableThemeData {
  /// Data row height.
  final double? dataRowHeight;

  /// Odd row theme.
  ///
  /// It is used to style the odd rows.
  final RowTheme? oddRowTheme;

  /// Even row theme.
  ///
  /// It is used to style the even rows.
  final RowTheme? evenRowTheme;

  /// Divider theme data.
  ///
  /// It is used to style the dividers between data rows.
  final DividerThemeData? dividerThemeData;

  /// Divider height.
  ///
  /// It is used to set the height of the dividers between data rows.
  final double? dividerHeight;

  /// Table decoration.
  ///
  /// It is used to style the container of the table.
  /// Includes the header, the rows and the footer.
  final BoxDecoration? tableDecoration;

  /// Header decoration.
  ///
  /// It is used to style the header of the table.
  /// Includes the buttons of the header and the chips of the filters.
  final BoxDecoration? headerDecoration;

  /// Column header decoration.
  ///
  /// It is used to style the column header of the table.
  /// Includes the title of the column, search input and the sort button.
  final BoxDecoration? columnHeaderDecoration;

  /// Column header height.
  ///
  /// It is used to set the height of the column header of the table.
  /// Height of the title, search input and the sort button.
  final double columnHeaderHeight;

  /// Footer decoration.
  ///
  /// It is used to style the footer of the table.
  /// Includes the buttons of the footer.
  final BoxDecoration? footerDecoration;

  /// Padding of the header.
  ///
  /// It is used to set the padding of the header.
  /// Includes the buttons of the header and the chips of the filters.
  ///
  /// If the table is smaller than the screen width, the padding will be adjusted
  /// in the right side to be inside the horizontal scroll view.
  final EdgeInsets? headerPadding;

  /// Vertical padding of the column header.
  ///
  /// It is used to set the vertical padding of the column header.
  /// The horizontal padding is set by the [rowPadding].
  final EdgeInsets? columnHeaderVerticalPadding;

  /// Padding of the row, and horizontal padding of the column header.
  ///
  /// It is used to set the padding of the data row.
  /// It is used with [columnHeaderVerticalPadding] to set the horizontal padding
  /// of the column header, to align the row content with the column header content.
  final EdgeInsets? rowPadding;

  /// Padding of the footer.
  ///
  /// It is used to set the padding of the footer.
  final EdgeInsets? footerPadding;

  /// Margin of the table.
  ///
  /// It is used to set the margin of the table.
  final EdgeInsets? tableMargin;

  /// Column search input theme.
  ///
  /// It is used to style the search input of the column header.
  ///
  /// If null, the default theme will be used.
  final InputDecorationThemeData? columnSearchInputTheme;

  /// Column title text style.
  ///
  /// It is used to style the title of the column.
  ///
  /// If null, the default theme will be used.
  final TextStyle? columnTitleTextStyle;

  /// Content text style.
  ///
  /// It is used to style the content of the cells.
  ///
  /// If null, the default theme will be used.
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
    this.columnHeaderHeight = 40,
    this.footerDecoration,
    this.headerPadding,
    this.columnHeaderVerticalPadding,
    this.rowPadding,
    this.footerPadding,
    this.columnSearchInputTheme,
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
    double? columnHeaderHeight,
    BoxDecoration? columnSearchDecoration,
    BoxDecoration? footerDecoration,
    EdgeInsets? tablePadding,
    EdgeInsets? headerPadding,
    EdgeInsets? columnHeaderVerticalPadding,
    EdgeInsets? rowPadding,
    EdgeInsets? footerPadding,
    EdgeInsets? tableMargin,
    InputDecorationThemeData? columnSearchInputTheme,
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
        columnHeaderHeight: columnHeaderHeight ?? this.columnHeaderHeight,
        footerDecoration: footerDecoration ?? this.footerDecoration,
        headerPadding: headerPadding ?? this.headerPadding,
        columnHeaderVerticalPadding:
            columnHeaderVerticalPadding ?? this.columnHeaderVerticalPadding,
        rowPadding: rowPadding ?? this.rowPadding,
        footerPadding: footerPadding ?? this.footerPadding,
        tableMargin: tableMargin ?? this.tableMargin,
        columnSearchInputTheme:
            columnSearchInputTheme ?? this.columnSearchInputTheme,
        columnTitleTextStyle: columnTitleTextStyle ?? this.columnTitleTextStyle,
        contentTextStyle: contentTextStyle ?? this.contentTextStyle,
      );
}
