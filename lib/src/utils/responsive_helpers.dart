import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Helper utilities to determine device screen sizes and responsive layouts
/// (Mobile, Tablet, Desktop) across different device orientations.

/// Screen width breakpoints for responsive layout detection.
const int largeScreenSize = 1366;
const int mediumScreenSize = 700;
const int smallScreenSize = 360;

/// Represents responsive screen size categories: small, medium, and large.
enum ScreenSize {
  /// Mobile devices.
  small,

  /// Tablets and compact desktop windows.
  medium,

  /// Full desktop screens.
  large,
}

/// Extension methods for [ScreenSize] layout properties.
extension ScreenSizeExtension on ScreenSize {
  /// Returns the recommended screen padding based on device size.
  double get padding {
    switch (this) {
      case ScreenSize.small:
        return 16.0;
      case ScreenSize.medium:
        return 20.0;
      case ScreenSize.large:
        return 40.0;
    }
  }
}

/// Extension methods for responsive queries on [BuildContext].
extension ContextExtension on BuildContext {
  /// Determines the active [ScreenSize] category for this context.
  ScreenSize get screenSize {
    double width = MediaQuery.of(this).size.width;
    double height = MediaQuery.of(this).size.height;

    // If screen width is below medium breakpoint, consider it small.
    // In landscape on mobile, width might exceed mediumScreenSize,
    // so also check height constraints.
    if (width < mediumScreenSize ||
        ((kIsWeb || Platform.isIOS || Platform.isAndroid) && height < 450)) {
      return ScreenSize.small;
    }

    // If screen width is below large breakpoint, consider it medium.
    if (width < largeScreenSize) return ScreenSize.medium;

    // Otherwise, treat as large screen.
    return ScreenSize.large;
  }
}
