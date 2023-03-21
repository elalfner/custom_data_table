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

  /// `true` if the data can be sorted by this column.
  final bool canSort;

  /// Creates a new instance of the [ColumnInfo] class.
  ///
  /// [canSort] by default is `true`. Indicating that data can be sorted by this
  /// column by default.
  ColumnInfo({
    required this.key,
    required this.name,
    required this.width,
    this.flex,
    this.canSort = true,
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

  ColumnId({
    required this.key,
    required this.name,
  });
}
