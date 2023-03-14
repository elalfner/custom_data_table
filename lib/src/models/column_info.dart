class ColumnInfo {
  final String name;
  final String key;

  final int? flex;
  final double? width;

  final bool canSort;

  ColumnInfo({
    required this.name,
    required this.key,
    this.flex,
    this.width,
    this.canSort = true,
  });
}
