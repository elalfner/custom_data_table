import 'dart:async';
import 'dart:ui';

/// Debouncer class to debounce actions.
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 500);
///
/// debouncer.run(() {
///   // Do something
/// });
/// ```
class Debouncer {
  /// The time in milliseconds to wait before executing the action.
  final int milliseconds;

  /// The timer used to debounce the action.
  ///
  /// This timer is reset every time the [run] method is called.
  ///
  /// If the timer is not null, it is canceled.
  Timer? _timer;

  Debouncer({required this.milliseconds});

  /// Runs the action after the specified time.
  ///
  /// [action] The action to run.
  ///
  /// If the function is called again before the specified time, the timer is
  /// reset, and the action is not executed.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
