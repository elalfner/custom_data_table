import 'package:flutter/material.dart';

/// Information of the column.
///
/// It contains the name that is going to display in the table, and the space that is
/// going to take horizontally.
class ColumnInfo {
  /// Column's key.
  ///
  /// It is used to get the attribute of the row that is going to show in that column.
  final String key;

  /// Column's title to display in the table.
  final String name;

  /// Column's min width.
  ///
  /// If the screen width is smaller than the width of the table, this [width] is the
  /// space that is going to take to make the table scrollable. That is why this property
  /// is required.
  final double width;

  /// Column's relative width compared to other columns.
  ///
  /// If `null`, the column width is represented by [width].
  final int? flex;

  final bool hasFixedWidth;

  /// `true` if the data can be sorted by this column.
  final bool canSort;

  /// `true` if the column can have a search input.
  final bool canSearchInput;

  /// The initial value for the search input.
  final String? initialSearchValue;

  /// The callback that is called when the search input changes.
  ValueChanged<String>? onChangeInput;

  /// The controller that is used to control the search input.
  TextEditingController? controllerInput;

  /// Extra data that can be used to store additional information.
  Map<String, dynamic>? extra;

  ColumnInfo({
    required this.key,
    required this.name,
    required this.width,
    this.hasFixedWidth = false,
    this.flex,
    this.canSort = false,
    this.canSearchInput = false,
    this.initialSearchValue,
    this.onChangeInput,
    this.controllerInput,
    this.extra,
  });
}

/// Represents a column name and key.
class ColumnId {
  /// Column's key.
  ///
  /// It is used to get the attribute of the row that is going to show in that column.
  final String key;

  /// Column's title to display in the table.
  final String name;

  /// `true` if the column can be used to search in the general search input.
  final bool canGeneralSearch;

  ColumnId({
    required this.key,
    required this.name,
    this.canGeneralSearch = false,
  });
}
