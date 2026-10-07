import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'app_localizations.dart';

extension BuildContextExtension on BuildContext {
  DataTableLocalizations get appLocalizations {
    final languageCode = findAncestorWidgetOfExactType<MaterialApp>()
        ?.locale
        ?.languageCode
        .split('_')
        .firstOrNull;
    try {
      return DataTableLocalizations.of(this) ??
          lookupDataTableLocalizations(
            (languageCode == null ? null : Locale(languageCode)) ??
                const Locale('en'),
          );
    } catch (_) {
      return DataTableLocalizations.of(this) ??
          lookupDataTableLocalizations(
            const Locale('en'),
          );
    }
  }
}
