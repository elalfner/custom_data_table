import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'datatable_theme_data.dart';

class CustomDatatableTheme extends StatelessWidget {
  final Widget child;

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
  CustomDatatableThemeData? get readDataTableTheme {
    try {
      return read<CustomDatatableThemeData>();
    } catch (_) {}
    return null;
  }

  CustomDatatableThemeData? get watchDataTableTheme {
    try {
      return watch<CustomDatatableThemeData>();
    } catch (_) {}
    return null;
  }
}
