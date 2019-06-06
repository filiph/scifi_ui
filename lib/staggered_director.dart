import 'dart:async';

class StaggeredDirector {
  static final StaggeredDirector singleton = StaggeredDirector();

  static const Duration delay = Duration(milliseconds: 300);

  static const maxWaiting = 10;

  Timer _timer;

  void dispose() {
    _timer?.cancel();
  }

  List<void Function()> _callbacks = [];

  void register(void Function() callback) {
    _callbacks.add(callback);
    if (_timer == null) _scheduleNext();
  }

  void _scheduleNext() {
    assert(_timer == null || !_timer.isActive);

    // Clear the backlog if it's over a threshold.
    while (_callbacks.length > maxWaiting) {
      _callbacks.first();
      _callbacks.removeAt(0);
    }

    _timer = Timer(delay, _handleNext);
  }

  void _handleNext() {
    _timer = null;

    // Call the callback.
    if (_callbacks.isNotEmpty) {
      _callbacks.first();
      _callbacks.removeAt(0);
    }

    // Schedule next if needed.
    if (_callbacks.isNotEmpty) {
      _scheduleNext();
    }
  }
}
