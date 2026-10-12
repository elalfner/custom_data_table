/// Filter that can be applied to the table.
class FilterItem<T> {
  /// Filter's name to display.
  final String filterName;

  /// Filter's value to apply.
  final T value;

  FilterItem({
    required this.filterName,
    required this.value,
  });
}
