class ColumnInfo {
  final String name;
  final String key;

  final int? flex;
  final double width;

  final bool canSort;

  ColumnInfo({
    required this.name,
    required this.key,
    required this.width,
    this.flex,
    this.canSort = true,
  });
}

class ColumnId {
  final String name;
  final String key;

  ColumnId({
    required this.name,
    required this.key,
  });
}
