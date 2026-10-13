import 'dart:async';
import 'dart:ui';

/// Debouncer class to debounce actions within the table components.
///
/// Example:
/// ```dart
/// final debouncer = TableDebouncer(milliseconds: 500);
///
/// debouncer.run(() {
///   // Do something
/// });
/// ```
class TableDebouncer {
  /// The time in milliseconds to wait before executing the action.
  final int milliseconds;

  /// The timer used to debounce the action.
  Timer? _timer;

  TableDebouncer({required this.milliseconds});

  /// Creates a [TableDebouncer] with a [Duration].
  TableDebouncer.duration(Duration duration)
      : milliseconds = duration.inMilliseconds;

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

  /// Cancels any active debounce timer.
  void cancel() {
    _timer?.cancel();
  }
}
