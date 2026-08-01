import 'dart:async';

/// Simple singleton bus used to notify UI listeners when an absence
/// is written from outside the ChangeNotifier tree (background
/// AttendanceAutomationService, SyncService restore, etc.).
///
/// Per plan 2.3.1: providers and calendar tab subscribe to this and
/// reload the affected course's absences on event.
class AbsenceChangeBus {
  AbsenceChangeBus._();
  static final AbsenceChangeBus instance = AbsenceChangeBus._();

  final StreamController<String> _controller = StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  void fire(String courseId) {
    if (_controller.isClosed) return;
    _controller.add(courseId);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}