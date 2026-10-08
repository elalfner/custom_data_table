import 'package:flutter_driver/driver_extension.dart';
import 'package:example/main.dart' as app;

/// Entry point enabling Flutter Driver extension for automated UI testing and review.
void main() async {
  enableFlutterDriverExtension();
  app.main();
}
