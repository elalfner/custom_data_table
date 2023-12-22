import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'app_localizations.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get appLocalizations {
    final languageCode = findAncestorWidgetOfExactType<MaterialApp>()
        ?.locale
        ?.languageCode
        .split('_')
        .firstOrNull;
    try {
      return AppLocalizations.of(this) ??
          lookupAppLocalizations(
            (languageCode == null ? null : Locale(languageCode)) ??
                const Locale('en'),
          );
    } catch (_) {
      return AppLocalizations.of(this) ??
          lookupAppLocalizations(
            const Locale('en'),
          );
    }
  }
}
