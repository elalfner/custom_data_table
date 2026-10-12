import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets up a mock clipboard handler for widget tests.
void setupMockClipboard({bool shouldThrow = false}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    SystemChannels.platform,
    (MethodCall methodCall) async {
      if (methodCall.method == 'Clipboard.setData') {
        if (shouldThrow) {
          throw PlatformException(
            code: 'CLIPBOARD_ERROR',
            message: 'Simulated clipboard error',
          );
        }
        return null;
      }
      return null;
    },
  );
}
