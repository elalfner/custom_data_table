class FilterItem<T> {
  final String filterName;
  final T value;

  final String? fieldName;

  FilterItem({
    required this.filterName,
    required this.value,
    this.fieldName,
  });
}
