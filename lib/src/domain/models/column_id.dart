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
