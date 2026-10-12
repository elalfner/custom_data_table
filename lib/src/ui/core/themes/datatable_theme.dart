import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'datatable_theme_data.dart';

/// A widget that provides [CustomDatatableThemeData] to its descendants.
///
/// This widget is used to style the data table.
class CustomDatatableTheme extends StatelessWidget {
  /// The child widget.
  final Widget child;

  /// The data table theme data.
  final CustomDatatableThemeData data;

  const CustomDatatableTheme(
      {super.key, required this.child, required this.data});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: data,
      child: child,
    );
  }
}

extension BuildContextExtension on BuildContext {
  /// Reads the [CustomDatatableThemeData] from the nearest [CustomDatatableTheme] widget.
  ///
  /// If no [CustomDatatableTheme] widget is found, it returns `null`.
  CustomDatatableThemeData? get readDataTableTheme {
    try {
      return read<CustomDatatableThemeData>();
    } catch (_) {}
    return null;
  }

  /// Watches the [CustomDatatableThemeData] from the nearest [CustomDatatableTheme] widget.
  ///
  /// If no [CustomDatatableTheme] widget is found, it returns `null`.
  CustomDatatableThemeData? get watchDataTableTheme {
    try {
      return watch<CustomDatatableThemeData>();
    } catch (_) {}
    return null;
  }
}
